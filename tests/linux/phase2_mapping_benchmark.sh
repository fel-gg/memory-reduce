#!/usr/bin/env bash
set -euo pipefail

# Real Linux process_madvise mapping-grid evidence. All processes and files
# belong to this script and are cleaned up on every exit. Unsupported or
# permission-denied capabilities remain explicit in the raw report.
output_path="${1:?Usage: phase2_mapping_benchmark.sh OUTPUT_PATH}"
repeat_count="${PHASE2_MAPPING_REPEATS:-1}"
case_seconds="${PHASE2_MAPPING_SECONDS:-3}"
script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd -- "${script_directory}/../.." && pwd)"
fixture="${script_directory}/phase2_mapping_fixture.py"
native="${repository_root}/linux/native/reduce-memory-native"
mkdir -p -- "$(dirname -- "${output_path}")"
if [[ ! "${repeat_count}" =~ ^[1-9][0-9]*$ || "${repeat_count}" -gt 10 ]]; then
  printf 'PHASE2_MAPPING_REPEATS must be an integer in 1..10\n' >&2
  exit 2
fi

cases=(anonymous-private anonymous-with-swap anonymous-without-swap clean-file dirty-file shared-file mixed-cow thp sparse-file many-small)
tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/reduce-memory-phase2-grid.XXXXXX")"
active_pid=""
cleanup() {
  if [[ -n "${active_pid}" ]] && kill -0 "${active_pid}" 2>/dev/null; then
    kill "${active_pid}" 2>/dev/null || true
    wait "${active_pid}" 2>/dev/null || true
  fi
  rm -rf -- "${tmp_root}"
}
trap cleanup EXIT INT TERM

source_commit="$(git -C "${repository_root}" rev-parse HEAD)"
source_dirty="$(git -C "${repository_root}" status --porcelain | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
printf 'schema=phase2-linux-mapping-grid-v1\nsource_commit=%s\nsource_dirty=%s\n' "${source_commit}" "${source_dirty}" >"${output_path}"
printf 'host_architecture=%s\n' "$(uname -m)" >>"${output_path}"
printf 'captured_utc=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"${output_path}"
printf 'repeats=%s\n' "${repeat_count}" >>"${output_path}"

for case_name in "${cases[@]}"; do
  for repeat in $(seq 1 "${repeat_count}"); do
    ready="${tmp_root}/${case_name}-${repeat}.ready"
    log="${tmp_root}/${case_name}-${repeat}.log"
    python3 "${fixture}" --case "${case_name}" --ready "${ready}" --seconds "${case_seconds}" >"${log}" 2>&1 &
    active_pid=$!
    for _ in $(seq 1 300); do
      [[ -f "${ready}" ]] && break
      if ! kill -0 "${active_pid}" 2>/dev/null; then break; fi
      sleep 0.1
    done
    if [[ ! -f "${ready}" ]]; then
      printf 'case=%s repeat=%s status=fixture_not_ready pid=%s\n' "${case_name}" "${repeat}" "${active_pid}" >>"${output_path}"
      cat "${log}" >&2 || true
      wait "${active_pid}" 2>/dev/null || true
      active_pid=""
      continue
    fi
    rss_before="$(awk '/^VmRSS:/ { print $2; exit }' "/proc/${active_pid}/status" 2>/dev/null || printf unknown)"
    native_output=""
    native_exit=0
    native_output="$(sudo "${native}" pageout --protocol 2 --session "phase2-${case_name}-${repeat}" --pid "${active_pid}" --min-rss-mb 1 --min-mapping-kb 4 --activity-ms 0 --settle-ms 100 --deadline-ms 5000 2>&1)" || native_exit=$?
    rss_after="$(awk '/^VmRSS:/ { print $2; exit }' "/proc/${active_pid}/status" 2>/dev/null || printf unknown)"
    initial_checksum="$(awk -F= '$1 == "initial_checksum" { print $2; exit }' "${ready}")"
    final_checksum="$(awk -F= '$1 == "final_checksum" { print $2; exit }' "${log}" || true)"
    printf 'case=%s repeat=%s pid=%s fixture_status=ready native_exit=%s rss_before_kib=%s rss_after_kib=%s checksum_initial=%s checksum_final=%s\n' \
      "${case_name}" "${repeat}" "${active_pid}" "${native_exit}" "${rss_before}" "${rss_after}" "${initial_checksum:-unknown}" "${final_checksum:-pending}" >>"${output_path}"
    while IFS= read -r line; do printf 'case=%s repeat=%s native_%s\n' "${case_name}" "${repeat}" "${line}"; done <<<"${native_output}" >>"${output_path}"
    kill "${active_pid}" 2>/dev/null || true
    wait "${active_pid}" 2>/dev/null || true
    active_pid=""
  done
done
cat "${output_path}"
