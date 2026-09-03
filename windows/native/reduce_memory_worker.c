#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#include <stdio.h>
#include <wchar.h>

typedef struct {
    DWORD pid;
    SIZE_T after_ws;
    WCHAR name[MAX_PATH];
} TrimTarget;

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

static int path_is_under_windows(HANDLE process) {
    WCHAR path[32768];
    WCHAR windows_path[MAX_PATH];
    DWORD length = (DWORD)(sizeof(path) / sizeof(path[0]));
    UINT windows_length = GetWindowsDirectoryW(windows_path, MAX_PATH);
    if (!windows_length || windows_length >= MAX_PATH) return 1;
    if (!QueryFullProcessImageNameW(process, 0, path, &length)) return 1;
    if (windows_path[windows_length - 1] != L'\\') {
        windows_path[windows_length++] = L'\\';
        windows_path[windows_length] = L'\0';
    }
    return _wcsnicmp(path, windows_path, windows_length) == 0;
}

static SIZE_T working_set(HANDLE process) {
    PROCESS_MEMORY_COUNTERS_EX counters;
    ZeroMemory(&counters, sizeof(counters));
    counters.cb = sizeof(counters);
    if (!GetProcessMemoryInfo(process, (PROCESS_MEMORY_COUNTERS *)&counters, sizeof(counters))) return 0;
    return counters.WorkingSetSize;
}

static int trim_handle(HANDLE process) {
    if (EmptyWorkingSet(process)) return 1;
    return SetProcessWorkingSetSizeEx(process, (SIZE_T)-1, (SIZE_T)-1, 0) != 0;
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
                        const TrimTarget *targets, DWORD target_count) {
    FILE *output = NULL;
    DWORD index;
    if (_wfopen_s(&output, path, L"w, ccs=UTF-8") != 0 || !output) return 0;
    fwprintf(output, L"0\n%lu\n%llu\n%lu\n", trimmed, released, target_count);
    for (index = 0; index < target_count; ++index) {
        fwprintf(output, L"%lu|%llu|%ls\n", targets[index].pid,
                 (unsigned long long)targets[index].after_ws, targets[index].name);
    }
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
    unsigned long long released = 0;
    SIZE_T minimum = profile == 3 ? 0 : 4ULL * 1024ULL * 1024ULL;

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
        SIZE_T before, after;
        if (entry.th32ProcessID == 0 || entry.th32ProcessID == 4 ||
            entry.th32ProcessID == GetCurrentProcessId() ||
            entry.th32ProcessID == excluded_pid ||
            (target_pid && entry.th32ProcessID != target_pid) ||
            is_protected_name(entry.szExeFile) ||
            filter_contains_name(exclude_filter, entry.szExeFile) ||
            (include_filter && *include_filter &&
             !filter_contains_name(include_filter, entry.szExeFile)) ||
            (profile != 3 && foreground_pid && entry.th32ProcessID == foreground_pid)) continue;

        process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SET_QUOTA,
                              FALSE, entry.th32ProcessID);
        if (!process) continue;
        if (path_is_under_windows(process)) {
            CloseHandle(process);
            continue;
        }
        before = working_set(process);
        if (!before || before < minimum || !trim_handle(process)) {
            CloseHandle(process);
            continue;
        }
        after = working_set(process);
        ++trimmed;
        if (before > after) released += (unsigned long long)(before - after);

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
        wcsncpy_s(targets[target_count].name, MAX_PATH, entry.szExeFile, _TRUNCATE);
        ++target_count;
        CloseHandle(process);
    } while (Process32NextW(snapshot, &entry));

    CloseHandle(snapshot);
    if (!write_result(result_path, trimmed, released, targets, target_count)) {
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
    if (argc == 2 && equals_ignore_case(argv[1], L"/selftest")) {
        HANDLE current = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION | PROCESS_SET_QUOTA,
                                     FALSE, GetCurrentProcessId());
        if (!current) return 20;
        if (!working_set(current)) { CloseHandle(current); return 21; }
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
