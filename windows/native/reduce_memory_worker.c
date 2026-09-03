#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#include <shellapi.h>
#include <stdio.h>
#include <wchar.h>

typedef struct {
    DWORD pid;
    SIZE_T after_ws;
    DWORD after_faults;
    SIZE_T released;
    WCHAR name[MAX_PATH];
} TrimTarget;

typedef struct {
    DWORD seen, protected_process, filtered, foreground, open_failed;
    DWORD path_failed, windows_process, query_failed, below_minimum;
    DWORD trim_failed, no_reduction;
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

static int trim_handle(HANDLE process) {
    if (EmptyWorkingSet(process)) return 1;
    return SetProcessWorkingSetSizeEx(process, (SIZE_T)-1, (SIZE_T)-1, 0) != 0;
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
    unsigned long parsed;
    if (_wcsnicmp(argument, prefix, prefix_length) != 0) return 0;
    parsed = wcstoul(argument + prefix_length, &end, 10);
    if (!end || *end != L'\0') return -1;
    *value = (DWORD)parsed;
    return 1;
}

static const WCHAR *string_arg(const WCHAR *argument, const WCHAR *prefix) {
    size_t prefix_length = wcslen(prefix);
    if (_wcsnicmp(argument, prefix, prefix_length) != 0) return NULL;
    return argument + prefix_length;
}

static int write_result(const WCHAR *path, DWORD trimmed, unsigned long long released,
                        const TrimTarget *targets, DWORD target_count,
                        const TrimStats *stats) {
    FILE *output = NULL;
    DWORD index;
    if (_wfopen_s(&output, path, L"w, ccs=UTF-8") != 0 || !output) return 0;
    fwprintf(output, L"0\n%lu\n%llu\n%lu\n", trimmed, released, target_count);
    for (index = 0; index < target_count; ++index) {
        fwprintf(output, L"%lu|%llu|%lu|%llu|%ls\n", targets[index].pid,
                 (unsigned long long)targets[index].after_ws,
                 targets[index].after_faults,
                 (unsigned long long)targets[index].released, targets[index].name);
    }
    fwprintf(output, L"seen=%lu\nprotected=%lu\nfiltered=%lu\nforeground=%lu\n"
             L"open_failed=%lu\npath_failed=%lu\nwindows_process=%lu\n"
             L"query_failed=%lu\nbelow_minimum=%lu\ntrim_failed=%lu\nno_reduction=%lu\n",
             stats->seen, stats->protected_process, stats->filtered, stats->foreground,
             stats->open_failed, stats->path_failed, stats->windows_process,
             stats->query_failed, stats->below_minimum, stats->trim_failed,
             stats->no_reduction);
    fclose(output);
    return 1;
}

static int run_trim(DWORD profile, DWORD foreground_pid, DWORD excluded_pid,
                    DWORD target_pid,
                    const WCHAR *exclude_filter, const WCHAR *include_filter,
                    const WCHAR *result_path) {
    HANDLE snapshot;
    PROCESSENTRY32W entry;
    TrimTarget *targets = NULL;
    DWORD capacity = 0, target_count = 0, trimmed = 0;
    TrimStats stats;
    unsigned long long released = 0;
    SIZE_T minimum = profile == 3 ? 0 : 4ULL * 1024ULL * 1024ULL;

    ZeroMemory(&stats, sizeof(stats));
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
        ++stats.seen;
        if (entry.th32ProcessID == 0 || entry.th32ProcessID == 4 ||
            entry.th32ProcessID == GetCurrentProcessId() ||
            entry.th32ProcessID == excluded_pid ||
            is_protected_name(entry.szExeFile)) { ++stats.protected_process; continue; }
        if ((target_pid && entry.th32ProcessID != target_pid) ||
            filter_contains_name(exclude_filter, entry.szExeFile) ||
            (include_filter && *include_filter &&
             !filter_contains_name(include_filter, entry.szExeFile))) { ++stats.filtered; continue; }
        if (profile != 3 && foreground_pid && entry.th32ProcessID == foreground_pid) {
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
        if (before < minimum) {
            ++stats.below_minimum;
            CloseHandle(process);
            continue;
        }
        if (!trim_handle(process)) {
            ++stats.trim_failed;
            CloseHandle(process);
            continue;
        }
        if (!memory_snapshot(process, &after, &after_faults)) {
            ++stats.query_failed;
            CloseHandle(process);
            continue;
        }
        ++trimmed;
        if (before > after) released += (unsigned long long)(before - after);
        else ++stats.no_reduction;

        if (target_count == capacity) {
            DWORD new_capacity = capacity ? capacity * 2 : 64;
            TrimTarget *expanded = (TrimTarget *)HeapReAlloc(
                GetProcessHeap(), HEAP_ZERO_MEMORY, targets,
                sizeof(TrimTarget) * new_capacity);
            if (!expanded && !targets) {
                expanded = (TrimTarget *)HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY,
                                                    sizeof(TrimTarget) * new_capacity);
            }
            if (!expanded) {
                CloseHandle(process);
                break;
            }
            targets = expanded;
            capacity = new_capacity;
        }
        targets[target_count].pid = entry.th32ProcessID;
        targets[target_count].after_ws = after;
        targets[target_count].after_faults = after_faults;
        targets[target_count].released = before > after ? before - after : 0;
        wcsncpy_s(targets[target_count].name, MAX_PATH, entry.szExeFile, _TRUNCATE);
        ++target_count;
        CloseHandle(process);
    } while (Process32NextW(snapshot, &entry));

    CloseHandle(snapshot);
    if (!write_result(result_path, trimmed, released, targets, target_count, &stats)) {
        if (targets) HeapFree(GetProcessHeap(), 0, targets);
        return 12;
    }
    if (targets) HeapFree(GetProcessHeap(), 0, targets);
    return 0;
}

int wmain(int argc, WCHAR **argv) {
    DWORD profile = 2, foreground_pid = 0, excluded_pid = 0, target_pid = 0;
    int allow_all = 0;
    const WCHAR *result_path = NULL;
    const WCHAR *exclude_filter = NULL, *include_filter = NULL;
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
    for (index = 1; index < argc; ++index) {
        DWORD value;
        int parsed = parse_unsigned_arg(argv[index], L"/profile=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { profile = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/foreground=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { foreground_pid = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/exclude-pid=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { excluded_pid = value; continue; }
        parsed = parse_unsigned_arg(argv[index], L"/pid=", &value);
        if (parsed < 0) return 2;
        if (parsed > 0) { target_pid = value; continue; }
        if (equals_ignore_case(argv[index], L"/all")) {
            allow_all = 1;
            continue;
        }
        {
            const WCHAR *candidate = string_arg(argv[index], L"/result=");
            if (candidate) result_path = candidate;
            candidate = string_arg(argv[index], L"/exclude=");
            if (candidate) exclude_filter = candidate;
            candidate = string_arg(argv[index], L"/include=");
            if (candidate) include_filter = candidate;
        }
    }
    if (!result_path || (profile != 2 && profile != 3) ||
        (!target_pid && !allow_all) || (target_pid && allow_all)) return 2;
    return run_trim(profile, foreground_pid, excluded_pid, target_pid, exclude_filter,
                    include_filter, result_path);
}
