# ReduceMemory Phase 1 — handoff Luna ke Sol

Dokumen ini adalah handoff implementasi, bukan sign-off. Sol diminta memeriksa
source dan bukti runtime sebelum Phase 2 dipertimbangkan.

## Snapshot

- Repository: `https://github.com/fel-gg/memory-reduce`
- Branch: `main`
- Latest implementation commit at handoff: `b7dbb06`
- Phase 2: belum dimulai
- Configuration pengguna dan artefak untracked di luar scope tidak diubah.

## Bukti CI utama

- Run `34684823652`: Windows dan Linux `success`.
  - Windows: build frontend/worker x86+x64, self-test, real working-set trim,
    refault recovery, dan Aggressive integration.
  - Linux: native page-out, targeted launcher reclaim, desktop/server installer,
    benchmark fixture, dan release contract.
- Run Linux targeted launcher berikutnya juga menunjukkan `success` pada tahap
  `REDUCE_MEMORY_TARGET_PID` dan native mapping advice.

Run terbaru dari commit setelah snapshot ini boleh menggantikan angka di atas,
tetapi harus dicatat dengan status job yang benar-benar terminal.

## Perubahan utama yang perlu direview

1. Windows worker protocol v2, session, birth identity, bounded child lifecycle,
   Job Object, parser transaction, dan x86/x64 parity.
2. Aggressive Windows release: elevated worker, measured passes, standby/cache
   stages, bounded refault recovery, dan per-instance ledger.
3. Effectiveness history: bounded validation, v2 executable identity, TTL,
   decay, deterministic eviction, dan atomic replacement.
4. Linux native page-out dan cgroup v2 reclaim: PID/starttime identity, target
   scope, numeric bounds, errno/partial accounting, swap policy, dan targeted
   launcher path.
5. Temp containment: broad-root rejection, reparse/junction skip, locked-file
   behavior, dan permanent-delete warning.
6. Benchmark tooling: randomized collector, six workload patterns, RSS/CPU/
   faults/I/O/swap/delayed samples, latency p50/p95/p99, dan failure semantics.
7. Release workflow: source-built Windows artifacts, manifest/checksum verifier,
   package verification, toolchain/job timeouts, dan no tracked-EXE fallback.

## Command verifikasi yang tersedia

```text
python -m unittest tests/release/test_release_workflow_contract.py
python -m unittest tests/benchmark/test_latency_probe.py
python -m py_compile tests/benchmark/*.py
bash -n linux/ReduceMemory_Linux.sh
```

Remote Linux CI juga menjalankan native unit tests, fixture isolation, failure
adapter, session accounting, installer smoke, targeted launcher reclaim, dan
server/desktop installation. Remote Windows CI menjalankan build serta runtime
self-tests dari staging.

## Known gaps sebelum Phase 1 sign-off

- Benchmark final candidate ReduceMemory nyata: lima repetition, baseline/no-op
  setara, delayed +3/+15/+60, dan workload latency aktif yang dibandingkan.
- Live Linux matrix untuk swap/cgroup delegated, ancestor limits, dan beberapa
  permission/errno kernel.
- Windows handle-relative/path-swap race harness saat traversal Temp.
- Clean-tag release build dan verifikasi artifact yang benar-benar dipublikasi.
- Review Sol atas API rights, overflow/precision, ownership, replay/orphan,
  partial accounting, history, dan Temp containment.

Jangan menyimpulkan “lebih banyak RAM bebas” dari `bytes advised` atau working
set delta saja; retained memory dan latency harus dilihat dari benchmark yang
terkontrol. Jangan menjalankan purge/cache stage pada workstation atau VPS
produksi hanya untuk mengisi checklist.
