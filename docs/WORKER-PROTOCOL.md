# Reduce Memory native worker protocol v2

Dokumen ini adalah kontrak antara frontend AutoIt, worker Windows, dan test
harness. Versi protokol tidak sama dengan versi aplikasi.

## Transport

Worker menulis UTF-8 text ke file result sementara, melakukan flush/close,
lalu mem-publish dengan rename atomik. File handshake dibuat lebih dulu dengan
`protocol=2`, `session=<id>`, dan `state=ready`. Folder hasil harus eksklusif
untuk satu session, owner/ACL-nya tervalidasi, dan semua path di-quote.

Input dan output dibatasi maksimum 8 MiB sebelum parser mengalokasikan isi dan
16.384 record. Parser menolak data terpotong, trailing payload, key duplikat,
angka di luar rentang, enum yang tidak dikenal, session yang salah, dan record
identity yang berulang. Hasil invalid tidak boleh mengubah ledger, history,
atau total UI.

## Envelope result

Contoh valid (metric dapat bertambah hanya melalui perubahan kontrak producer,
consumer, dan tes secara bersamaan):

```text
protocol=2
session=abc123
terminal=done
mutated=1
exit_code=0
trimmed=1
resident_delta=65536
record_count=1
record=4242|00000000000000AF|131072|65536|3|measured|fixture.exe
measured=1
unmeasured=0
```

`terminal` minimum adalah `done` atau `partial`. `mutated=1` berarti setidaknya
satu mutator mungkin sudah dipanggil; hasil yang hilang sesudah itu harus
dilaporkan sebagai partial/unknown dan tidak boleh memicu replay luas.
`resident_delta` adalah jumlah endpoint resident yang terukur, bukan jaminan
RAM fisik unik atau private commit yang didealokasi.

Metric taxonomy lengkap yang diproduksi worker saat ini berupa angka unsigned:
`seen`, `protected`, `filtered`, `foreground`, `open_failed`, `path_failed`,
`windows_process`, `query_failed`, `below_minimum`, `trim_failed`,
`no_reduction`, `measured`, dan `unmeasured`. Nilai `measured` dan `unmeasured`
harus sama dengan jumlah status record yang sesuai.

## Record identity

Format record adalah:

```text
record=<pid>|<creation-time-hex-16>|<before-working-set>|<after-working-set>|<faults>|<status>|<display-name>
```

Creation time adalah identitas instance proses Windows 64-bit dalam 16 digit
hex uppercase. Status yang sah: `measured`, `after_unknown`, dan
`identity_changed`. PID saja bukan identity dan tidak boleh dipakai untuk
menggabungkan dua session/pass.

## Lifecycle dan fallback

Frontend membuat satu `session` untuk satu operasi Optimize. Pass native atau
fallback memiliki `pass_id` di bawah session tersebut. Child yang dibuat oleh
frontend harus dimiliki melalui process handle/job yang sesuai, memiliki
deadline, dan hanya child optimizer yang boleh dibatalkan. Target aplikasi
tidak boleh diterminasi.

Tidak adanya ready-file saja bukan bukti child belum bermutasi. Jika handshake
sudah valid atau state child menunjukkan mutasi mungkin dimulai, kegagalan
result menjadi partial/unknown; frontend tidak boleh mengulangi trim semua
target melalui fallback.

## Perubahan kompatibel

Perubahan field wajib menaikkan schema transport atau menyediakan parser yang
menolak producer lama secara jelas. Jangan memperlakukan angka missing sebagai
nol sukses. Setiap perubahan harus memiliki fixture valid, fixture invalid,
producer, consumer, dan tes lifecycle yang sama-sama diperbarui.
