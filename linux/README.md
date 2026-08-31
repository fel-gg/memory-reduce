# ReduceMemory Linux

Windows `EmptyWorkingSet` and `NtSetSystemInformation` do not exist on Linux.
`ReduceMemory_Linux.sh` therefore uses the native Linux memory interfaces.

```bash
chmod +x ReduceMemory_Linux.sh
./ReduceMemory_Linux.sh check
./ReduceMemory_Linux.sh normal
sudo ./ReduceMemory_Linux.sh smooth
sudo ./ReduceMemory_Linux.sh aggressive
```

- `check` validates the Linux memory interface without changing cache state.
- `normal` synchronizes pending writes and leaves useful kernel cache intact.
- `smooth` drops page cache only, reducing the chance of visible stutter.
- `aggressive` drops page cache, dentries, and inode cache, then requests memory compaction.

Linux aggressively reuses otherwise-free RAM as cache. A lower "used" number is
not automatically faster; `MemAvailable` is the result that matters.
