# ReduceMemory support matrix

Dokumen ini memisahkan jalur yang sudah memiliki bukti lokal/CI dari jalur yang
baru didukung secara desain. Tidak ada klaim bahwa setiap distro Linux atau
software masa depan identik perilakunya.

| Platform/jalur | Bukti yang tersedia | Batas saat ini |
| --- | --- | --- |
| Windows x86 frontend + worker | Staged build, PE architecture check, AutoIt self-test, worker protocol/lifecycle, measurement contract, targeted trim fixture, dan interactive UI smoke enam mode pada staging | Native global reclaim dan explicit UAC/SID/ACL matrix perlu evidence terpisah |
| Windows x64 frontend + worker | Staged build, PE architecture check, AutoIt self-test, worker protocol/lifecycle, measurement contract, targeted trim fixture 371.2 MB dengan target tetap hidup | Native global reclaim dan UAC matrix perlu runner disposable/CI |
| Linux desktop Bash + Python helper | Bash syntax, native unit/session tests, fixture-isolation/failure adapters, baseline capture, desktop installer, native page-out, launcher, dan mode gates lulus pada CI Ubuntu 22.04/24.04 run `34743359103` | Full mapping/swap/namespace matrix memerlukan Linux disposable evidence tambahan |
| Linux server/VPS | Shared engine dan server installer/source path tersedia; server mode tidak memakai GUI; server installer CI smoke lulus pada Ubuntu 22.04/24.04 | Live service-user/delegated-cgroup matrix perlu host Linux server/CI |
| Git Bash/MSYS | Hanya fixture/syntax development; helper native Linux tidak dianggap didukung | Tidak memiliki kernel Linux atau `flock`/cgroup semantics yang diperlukan |
| Software baru/AI workload baru | Seleksi berbasis metadata proses, path, RSS, activity, identity, dan optional pattern; tidak memakai daftar aplikasi tetap untuk mode utama | Perilaku memory allocator setiap software dapat berbeda; hasil harus diukur, bukan diasumsikan |

## Mode dan privilege

- Normal berusaha tetap konservatif dan melindungi foreground/background activity
  yang terdeteksi.
- Aggressive/Emergency dapat membutuhkan Administrator/root dan bisa membuat
  page fault atau reload sementara.
- `Aggressive + Delete Temp` adalah operasi filesystem permanen terpisah; file
  yang sedang dipakai dilewati dan bukan pengganti antivirus.
- Angka `working-set/RSS reduction` dan `MemAvailable` adalah metrik berbeda;
  hanya pasangan before/after yang valid yang boleh disebut measured.

Support matrix ini harus diperbarui setelah runner/CI baru menghasilkan bukti,
bukan hanya karena source terlihat kompatibel.
