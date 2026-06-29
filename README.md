<div align="center">

# MobileStore — Frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![BLoC](https://img.shields.io/badge/State-BLoC-5C6BC0?style=flat-square)](https://bloclibrary.dev)

</div>

---

## Fitur

- 🔐 Login & Register akun pelanggan
- 📦 Lihat katalog produk HP
- 🔍 Cari produk berdasarkan nama
- 🛒 Keranjang belanja (tambah, ubah jumlah, hapus)
- 💳 Checkout & pembuatan pesanan
- 📜 Riwayat transaksi

---

## Cara Menjalankan

```bash
# 1. Install dependensi
flutter pub get

# 2. Sesuaikan URL API di lib/data/api_service.dart
#    Emulator Android  → http://10.0.2.2:8000/api
#    Perangkat fisik   → http://192.168.x.x:8000/api

# 3. Jalankan
flutter run
```

> Pastikan **Backend sudah berjalan** sebelum menjalankan aplikasi.
