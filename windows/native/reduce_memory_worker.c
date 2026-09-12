#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#include <shellapi.h>
#include <stdio.h>
#include <wchar.h>
#include <errno.h>
#include <stdlib.h>
#include <io.h>

typedef struct {
    DWORD pid;
    ULONGLONG creation_time;
    SIZE_T before_ws;
    SIZE_T after_ws;
    DWORD after_faults;
    int status; /* 1 measured, 2 identity changed, 0 after unknown */
    WCHAR name[MAX_PATH];
} TrimTarget;

typedef struct {
    DWORD seen, protected_process, filtered, foreground, open_failed;
    DWORD path_failed, windows_process, query_failed, below_minimum;
    DWORD trim_failed, no_reduction, measured, unmeasured;
} TrimStats;

static const WCHAR *protected_names[] = {
    L"system", L"registry", L"memory compression", L"secure system",
    L"csrss.exe", L"smss.exe", L"wininit.exe", L"winlogon.exe",
    L"services.exe", L"lsass.exe", L"dwm.exe", L"audiodg.exe",
    L"fontdrvhost.exe", NULL
};

static int equals_ignore_case(const WCHAR *left, const WCHAR *right) {
    return _wcsicmp(left, right) == 0;
}

static int is_protected_name(const WCHAR *name) {
    const WCHAR **current = protected_names;
    while (*current) {
        if (equals_ignore_case(name, *current)) return 1;
        ++current;
    }
    return 0;
}

static int filter_contains_name(const WCHAR *filter, const WCHAR *name) {
    const WCHAR *cursor;
    size_t name_length;
    if (!filter || !*filter) return 0;
    name_length = wcslen(name);
    cursor = filter;
    while ((cursor = wcschr(cursor, L'|')) != NULL) {
        const WCHAR *start = ++cursor;
        const WCHAR *end = wcschr(start, L'|');
        if (!end) break;
        if ((size_t)(end - start) == name_length &&
            _wcsnicmp(start, name, name_length) == 0) return 1;
        cursor = end;
    }
    return 0;
}

static int path_location(HANDLE process) {
    WCHAR path[32768];
    WCHAR windows_path[MAX_PATH];
    DWORD length = (DWORD)(sizeof(path) / sizeof(path[0]));
    UINT windows_length = GetWindowsDirectoryW(windows_path, MAX_PATH);
    if (!windows_length || windows_length >= MAX_PATH) return -1;
    if (!QueryFullProcessImageNameW(process, 0, path, &length)) return -1;
    if (windows_path[windows_length - 1] != L'\\') {
        windows_path[windows_length++] = L'\\';
        windows_path[windows_length] = L'\0';
    }
    return _wcsnicmp(path, windows_path, windows_length) == 0;
}

static int memory_snapshot(HANDLE process, SIZE_T *working_set, DWORD *page_faults) {
    PROCESS_MEMORY_COUNTERS_EX counters;
    ZeroMemory(&counters, sizeof(counters));
    counters.cb = sizeof(counters);
    if (!GetProcessMemoryInfo(process, (PROCESS_MEMORY_COUNTERS *)&counters, sizeof(counters))) return 0;
    *working_set = counters.WorkingSetSize;
    *page_faults = counters.PageFaultCount;
    return 1;
}

static int process_creation_time(HANDLE process, ULONGLONG *creation_time) {
    FILETIME created, exited, kernel, user;
    if (!GetProcessTimes(process, &created, &exited, &kernel, &user)) return 0;
    *creation_time = ((ULONGLONG)created.dwHighDateTime << 32) | created.dwLowDateTime;
    return 1;
}

static int current_foreground_pid(void) {
    HWND foreground = GetForegroundWindow();
    DWORD pid = 0;
    if (foreground) GetWindowThreadProcessId(foreground, &pid);
    return (int)pid;
}

static int trim_handle(HANDLE process) {
    if (EmptyWorkingSet(process)) return 1;
    return SetProcessWorkingSetSizeEx(process, (SIZE_T)-1, (SIZE_T)-1, 0) != 0;
}

/* A resident-memory result is known only when both snapshots succeeded. The
   signed value deliberately preserves memory growth instead of turning it
   into a misleading zero-byte "success". */
static LONGLONG measurement_delta(SIZE_T before, int after_valid, SIZE_T after,
                                  int *known) {
    if (!after_valid) {
        *known = 0;
        return 0;
    }
    *known = 1;
    return (LONGLONG)before - (LONGLONG)after;
}

static int measurement_contract_selftest(void) {
    const SIZE_T mib = 1024ULL * 1024ULL;
    int known = 0;
    LONGLONG delta;

    delta = measurement_delta(256ULL * mib, 0, 0, &known);
    if (known || delta != 0) return 60;
    delta = measurement_delta(256ULL * mib, 1, 288ULL * mib, &known);
    if (!known || delta != -(32LL * (LONGLONG)mib)) return 61;
    delta = measurement_delta(256ULL * mib, 1, 256ULL * mib, &known);
    if (!known || delta != 0) return 62;

    /* Two passes over one identity have one session baseline and one final
       snapshot: 256 -> 128 MiB is 128 MiB, never 256 MiB. */
    delta = measurement_delta(256ULL * mib, 1, 128ULL * mib, &known);
    if (!known || delta != 128LL * (LONGLONG)mib) return 63;
    return 0;
}

static int frontend_path(WCHAR *path, DWORD capacity) {
    WCHAR *separator;
    const WCHAR *frontend;
    DWORD length = GetModuleFileNameW(NULL, path, capacity);
    if (!length || length >= capacity) return 0;
    separator = wcsrchr(path, L'\\');
    if (!separator) return 0;
#ifdef _WIN64
    frontend = L"ReduceMemory_x64.exe";
#else
    frontend = L"ReduceMemory.exe";
#endif
    if ((size_t)(separator - path + 1) + wcslen(frontend) >= capacity) return 0;
    wcscpy_s(separator + 1, capacity - (DWORD)(separator - path + 1), frontend);
    return GetFileAttributesW(path) != INVALID_FILE_ATTRIBUTES;
}

static int launch_frontend(void) {
    WCHAR path[32768];
    HINSTANCE launched;
    if (!frontend_path(path, (DWORD)(sizeof(path) / sizeof(path[0])))) {
        MessageBoxW(NULL,
                    L"Aplikasi utama tidak ditemukan. Simpan worker ini di folder yang sama dengan ReduceMemory.",
                    L"ReduceMemory native worker", MB_OK | MB_ICONERROR);
        return 30;
    }
    launched = ShellExecuteW(NULL, L"open", path, NULL, NULL, SW_SHOWNORMAL);
    if ((INT_PTR)launched <= 32) {
        MessageBoxW(NULL, L"Aplikasi utama gagal dibuka.",
                    L"ReduceMemory native worker", MB_OK | MB_ICONERROR);
        return 31;
    }
    return 0;
}

static int parse_unsigned_arg(const WCHAR *argument, const WCHAR *prefix, DWORD *value) {
    size_t prefix_length = wcslen(prefix);
    WCHAR *end = NULL;
    unsigned long long parsed;
    if (_wcsnicmp(argument, prefix, prefix_length) != 0) return 0;
    if (argument[prefix_length] == L'\0' || argument[prefix_length] == L'-') return -1;
    errno = 0;
    parsed = wcstoull(argument + prefix_length, &end, 10);
    if (errno == ERANGE || parsed > MAXDWORD || !end || *end != L'\0') return -1;
    *value = (DWORD)parsed;
    return 1;
}

static const WCHAR *string_arg(const WCHAR *argument, const WCHAR *prefix) {
    size_t prefix_length = wcslen(prefix);
    if (_wcsnicmp(argument, prefix, prefix_length) != 0) return NULL;
    return argument + prefix_length;
}

static int write_handshake(const WCHAR *path, const WCHAR *session) {
    FILE *output = NULL;
    int ok = 1;
    if (!path || !*path || !session || !*session) return 0;
    if (_wfopen_s(&output, path, L"wx, ccs=UTF-8") != 0 || !output) return 0;
    if (fwprintf(output, L"protocol=2\nsession=%ls\nstate=ready\n", session) < 0) ok = 0;
    if (fflush(output) != 0 || _commit(_fileno(output)) != 0) ok = 0;
    if (fclose(output) != 0) ok = 0;
    return ok;
}

static int write_result(const WCHAR *path, const WCHAR *session, DWORD trimmed,
                        LONGLONG resident_delta, int mutated, int partial,
                        const TrimTarget *targets, DWORD target_count,
                        const TrimStats *stats) {
    FILE *output = NULL;
    DWORD index;
    int ok = 1;
    WCHAR temporary[32768];
    if (!path || !*path || !session || !*session) return 0;
    if (_snwprintf_s(temporary, sizeof(temporary) / sizeof(temporary[0]), _TRUNCATE,
                     L"%ls.tmp.%lu", path, GetCurrentProcessId()) < 0) return 0;
    DeleteFileW(temporary);
    if (_wfopen_s(&output, temporary, L"wx, ccs=UTF-8") != 0 || !output) return 0;
    if (fwprintf(output,
                 L"protocol=2\nsession=%ls\nterminal=%ls\nmutated=%d\nexit_code=0\n"
                 L"trimmed=%lu\nresident_delta=%lld\nrecord_count=%lu\n",
                 session, partial ? L"partial" : L"done", mutated, trimmed,
                 resident_delta, target_count) < 0) ok = 0;
    for (index = 0; index < target_count; ++index) {
        if (fwprintf(output, L"record=%lu|%016llX|%llu|%llu|%lu|%ls|%ls\n", targets[index].pid,
                 targets[index].creation_time,
                 (unsigned long long)targets[index].before_ws,
                 (unsigned long long)targets[index].after_ws,
                 targets[index].after_faults,
                 targets[index].status == 1 ? L"measured" :
                 (targets[index].status == 2 ? L"identity_changed" : L"after_unknown"),
                 targets[index].name) < 0) ok = 0;
    }
    if (fwprintf(output, L"seen=%lu\nprotected=%lu\nfiltered=%lu\nforeground=%lu\n"
             L"open_failed=%lu\npath_failed=%lu\nwindows_process=%lu\n"
             L"query_failed=%lu\nbelow_minimum=%lu\ntrim_failed=%lu\nno_reduction=%lu\n"
             L"measured=%lu\nunmeasured=%lu\n",
             stats->seen, stats->protected_process, stats->filtered, stats->foreground,
             stats->open_failed, stats->path_failed, stats->windows_process,
             stats->query_failed, stats->below_minimum, stats->trim_failed,
             stats->no_reduction, stats->measured, stats->unmeasured) < 0) ok = 0;
    if (fflush(output) != 0 || _commit(_fileno(output)) != 0) ok = 0;
    if (fclose(output) != 0) ok = 0;
    if (!ok) { DeleteFileW(temporary); return 0; }
    if (!MoveFileExW(temporary, path, MOVEFILE_WRITE_THROUGH)) {
        DeleteFileW(temporary);
        return 0;
    }
    return 1;
}

static int run_trim(DWORD profile, DWORD foreground_pid, DWORD excluded_pid,
                    DWORD target_pid,
                    const WCHAR *exclude_filter, const WCHAR *include_filter,
                    const WCHAR *result_path, const WCHAR *handshake_path,
                    const WCHAR *session, DWORD minimum_mb,
                    DWORD protect_foreground) {
    HANDLE snapshot;
    PROCESSENTRY32W entry;
    TrimTarget *targets = NULL;
    DWORD capacity = 0, target_count = 0, trimmed = 0;
    TrimStats stats;
    LONGLONG resident_delta = 0;
    int mutated = 0, partial = 0;
    /* Validate in 64-bit arithmetic before narrowing to SIZE_T.  The x86
       worker must reject an unrepresentable threshold instead of silently
       wrapping it to a tiny value and trimming the wrong processes. */
    ULONGLONG minimum_bytes = (ULONGLONG)minimum_mb * 1024ULL * 1024ULL;
    if (sizeof(SIZE_T) == 4 && minimum_bytes > 0xFFFFFFFFULL) return 2;
    SIZE_T minimum = (SIZE_T)minimum_bytes;

    ZeroMemory(&stats, sizeof(stats));
    if (!write_handshake(handshake_path, session)) return 13;
    snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return 10;
    ZeroMemory(&entry, sizeof(entry));
    entry.dwSize = sizeof(entry);
    if (!Process32FirstW(snapshot, &entry)) {
        CloseHandle(snapshot);
        return 11;
    }

    do {
        HANDLE process;
        SIZE_T before = 0, after = 0;
        DWORD before_faults = 0, after_faults = 0;
        int location;
        ULONGLONG creation_before = 0, creation_after = 0;
        ++stats.seen;
        if (entry.th32ProcessID == 0 || entry.th32ProcessID == 4 ||
            entry.th32ProcessID == GetCurrentProcessId() ||
            entry.th32ProcessID == excluded_pid ||
            is_protected_name(entry.szExeFile)) { ++stats.protected_process; continue; }
        if ((target_pid && entry.th32ProcessID != target_pid) ||
            filter_contains_name(exclude_filter, entry.szExeFile) ||
            (include_filter && *include_filter &&
             !filter_contains_name(include_filter, entry.szExeFile))) { ++stats.filtered; continue; }
        if (protect_foreground && ((foreground_pid && entry.th32ProcessID == foreground_pid) ||
            entry.th32ProcessID == (DWORD)current_foreground_pid())) {
            ++stats.foreground; continue;
        }

        process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SET_QUOTA,
                              FALSE, entry.th32ProcessID);
        if (!process) { ++stats.open_failed; continue; }
        location = path_location(process);
        if (location != 0) {
            if (location < 0) ++stats.path_failed; else ++stats.windows_process;
            CloseHandle(process);
            continue;
        }
        if (!memory_snapshot(process, &before, &before_faults)) {
            ++stats.query_failed;
            CloseHandle(process);
            continue;
        }
        if (!process_creation_time(process, &creation_before)) {
            ++stats.query_failed;
            CloseHandle(process);
            continue;
        }
        if (before < minimum) {
            ++stats.below_minimum;
            CloseHandle(process);
            continue;
        }
        /* Reserve the record before mutation. If memory is exhausted, skip the
           target instead of performing an action that cannot be accounted. */
        if (target_count == capacity) {
            DWORD new_capacity = capacity ? capacity * 2 : 64;
            TrimTarget *expanded = targets
                ? (TrimTarget *)HeapReAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY,
                                            targets, sizeof(TrimTarget) * new_capacity)
                : (TrimTarget *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY,
                                          sizeof(TrimTarget) * new_capacity);
            if (!expanded) {
                partial = 1;
                ++stats.trim_failed;
                CloseHandle(process);
                continue;
            }
            targets = expanded;
            capacity = new_capacity;
        }
        if (!trim_handle(process)) {
            ++stats.trim_failed;
            CloseHandle(process);
            continue;
        }
        mutated = 1;
        ++trimmed;
        {
            int after_valid = memory_snapshot(process, &after, &after_faults);
            int known = 0;
            int identity_changed = 0;
            if (!process_creation_time(process, &creation_after) || creation_after != creation_before) {
                after_valid = 0;
                identity_changed = 1;
                partial = 1;
            }
            LONGLONG delta = measurement_delta(before, after_valid, after, &known);
            if (!after_valid) {
            ++stats.query_failed;
            ++stats.unmeasured;
            } else {
                ++stats.measured;
                resident_delta += delta;
                if (delta <= 0) ++stats.no_reduction;
            }

            targets[target_count].pid = entry.th32ProcessID;
            targets[target_count].creation_time = creation_before;
            targets[target_count].before_ws = before;
            targets[target_count].after_ws = after;
            targets[target_count].after_faults = after_faults;
            targets[target_count].status = known ? 1 : (identity_changed ? 2 : 0);
            wcsncpy_s(targets[target_count].name, MAX_PATH, entry.szExeFile, _TRUNCATE);
            ++target_count;
        }
        CloseHandle(process);
    } while (Process32NextW(snapshot, &entry));

    CloseHandle(snapshot);
    if (!write_result(result_path, session, trimmed, resident_delta, mutated, partial,
                      targets, target_count, &stats)) {
        if (targets) HeapFree(GetProcessHeap(), 0, targets);
        return 12;
    }
    if (targets) HeapFree(GetProcessHeap(), 0, targets);
    return 0;
}

int wmain(int argc, WCHAR **argv) {
    DWORD profile = 2, foreground_pid = 0, excluded_pid = 0, target_pid = 0;
    int allow_all = 0;
    const WCHAR *result_path = NULL, *handshake_path = NULL, *session = NULL;
    const WCHAR *exclude_filter = NULL, *include_filter = NULL;
    DWORD protocol = 0, minimum_mb = 4, protect_foreground = 1;
    unsigned seen_arguments = 0;
    int index;
    if (argc == 1) return launch_frontend();
    if (argc == 2 && equals_ignore_case(argv[1], L"/launch-test")) {
        WCHAR path[32768];
        return frontend_path(path, (DWORD)(sizeof(path) / sizeof(path[0]))) ? 0 : 30;
    }
    if (argc == 2 && equals_ignore_case(argv[1], L"/selftest")) {
        HANDLE current = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SET_QUOTA,
                                     FALSE, GetCurrentProcessId());
        if (!current) return 20;
        SIZE_T ws = 0;
        DWORD faults = 0;
        if (!memory_snapshot(current, &ws, &faults) || !ws) { CloseHandle(current); return 21; }
        CloseHandle(current);
        return 0;
    }
    if (argc == 2 && equals_ignore_case(argv[1], L"/measurement-selftest")) {
        return measurement_contract_selftest();
    }
    for (index = 1; index < argc; ++index) {
        DWORD value;
        int parsed = parse_unsigned_arg(argv[index], L"/profile=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { if (seen_arguments & 1) return 2; seen_arguments |= 1; profile = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/foreground=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { if (seen_arguments & 2) return 2; seen_arguments |= 2; foreground_pid = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/exclude-pid=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { if (seen_arguments & 4) return 2; seen_arguments |= 4; excluded_pid = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/pid=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { if (seen_arguments & 8) return 2; seen_arguments |= 8; target_pid = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/protocol=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { if (seen_arguments & 16) return 2; seen_arguments |= 16; protocol = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/minimum-mb=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { if (seen_arguments & 2048) return 2; seen_arguments |= 2048; minimum_mb = value; continue; }
        if (equals_ignore_case(argv[index], L"/all")) {
            if (seen_arguments & 32) return 2;
            seen_arguments |= 32;
            allow_all = 1;
            continue;
        }
        parsed = parse_unsigned_arg(argv[index], L"/protect-foreground=", &value);
        if (parsed < 0 || (parsed > 0 && value > 1)) return 2;
        if (parsed > 0) { if (seen_arguments & 4096) return 2; seen_arguments |= 4096; protect_foreground = value; continue; }
        {
            const WCHAR *candidate = string_arg(argv[index], L"/result=");
            if (candidate) { if ((seen_arguments & 64) || !*candidate) return 2; seen_arguments |= 64; result_path = candidate; continue; }
            candidate = string_arg(argv[index], L"/handshake=");
            if (candidate) { if ((seen_arguments & 128) || !*candidate) return 2; seen_arguments |= 128; handshake_path = candidate; continue; }
            candidate = string_arg(argv[index], L"/session=");
            if (candidate) { if ((seen_arguments & 256) || !*candidate) return 2; seen_arguments |= 256; session = candidate; continue; }
            candidate = string_arg(argv[index], L"/exclude=");
            if (candidate) { if (seen_arguments & 512) return 2; seen_arguments |= 512; exclude_filter = candidate; continue; }
            candidate = string_arg(argv[index], L"/include=");
            if (candidate) { if (seen_arguments & 1024) return 2; seen_arguments |= 1024; include_filter = candidate; continue; }
        }
        return 2;
    }
    if (protocol != 2 || !session || !handshake_path || !result_path ||
        (profile != 2 && profile != 3) ||
        (!target_pid && !allow_all) || (target_pid && allow_all)) return 2;
    return run_trim(profile, foreground_pid, excluded_pid, target_pid, exclude_filter,
                    include_filter, result_path, handshake_path, session, minimum_mb,
                    protect_foreground);
}
