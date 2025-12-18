# 🎵🎬 ViAuo – Music & Video Player

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![License](https://img.shields.io/badge/License-Educational-lightgrey)
![Flutter CI](https://github.com/USERNAME/Music-Video_Player/actions/workflows/flutter.yml/badge.svg)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen)

ViAuo adalah aplikasi **pemutar musik dan video berbasis Android** yang dikembangkan menggunakan **Flutter**. Aplikasi ini memungkinkan pengguna untuk mengakses, menelusuri, dan memutar file **audio (MP3)** serta **video (MP4)** yang tersimpan di perangkat secara langsung. Proyek ini dibuat sebagai bagian dari pengembangan dan pembelajaran aplikasi mobile menggunakan Flutter.

---

## 📌 Deskripsi Proyek

Seiring meningkatnya kebutuhan akan aplikasi multimedia yang ringan dan responsif, ViAuo hadir sebagai solusi pemutar media lokal dengan antarmuka sederhana namun fungsional. Aplikasi ini mengimplementasikan navigasi multi-halaman, manajemen izin Android modern, serta dukungan terhadap penyimpanan internal perangkat.

ViAuo dirancang untuk dijalankan pada perangkat Android fisik dan mendukung versi Android terbaru, termasuk sistem perizinan Android 13+.

---

## ✨ Fitur Utama

* ▶️ Pemutar video lokal (format MP4)
* 🎵 Pemutar audio lokal (format MP3)
* 📂 Akses media langsung dari penyimpanan perangkat
* 🧭 Navigasi menggunakan Bottom Navigation Bar
* 🔍 Fitur pencarian media
* 🕘 Riwayat pemutaran media
* 👤 Halaman profil pengguna
* 🌙 Antarmuka dengan tema gelap (Dark Mode)

---

## 🛠️ Teknologi & Tools

* **Flutter** – Framework UI multiplatform
* **Dart** – Bahasa pemrograman utama
* **permission_handler** – Manajemen izin runtime Android
* **Android SDK** – Integrasi native Android

---

## 📁 Struktur Direktori

```
lib/
├── audiopage/
│   └── audio_page.dart
├── videopage/
│   └── video_page.dart
├── searchpage/
│   └── search_page.dart
├── historypage/
│   └── history_page.dart
├── profilepage/
│   └── profile.dart
├── splash_screen.dart
└── main.dart
```

---

## 🔐 Izin Akses (Permissions)

Aplikasi ini memerlukan izin untuk membaca file media dari penyimpanan perangkat.

### AndroidManifest.xml

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
```

Permintaan izin dilakukan secara **runtime** menggunakan package `permission_handler`.

---

## 🚀 Cara Menjalankan Aplikasi

### 1. Persiapan Lingkungan

* Flutter SDK telah terinstall
* Android Studio / VS Code
* Perangkat Android dengan USB Debugging aktif

### 2. Clone Repository

```bash
git clone <repository-url>
cd Music-Video_Player
```

### 3. Install Dependency

```bash
flutter pub get
```

### 4. Menjalankan Aplikasi

Hubungkan perangkat Android, kemudian jalankan:

```bash
flutter run
```

---

## 📱 Catatan Khusus Perangkat Android

* Disarankan menggunakan **perangkat fisik** (bukan emulator)
* Untuk perangkat Xiaomi/Redmi:

  * Aktifkan *Developer Options*
  * Aktifkan *USB Debugging*
  * Aktifkan *Install via USB*
* Android 13 ke atas memerlukan izin media terpisah (audio & video)

---

## 📸 Dokumentasi Tampilan

> Screenshot aplikasi dapat ditambahkan pada bagian ini untuk dokumentasi visual.

---

## 👨‍💻 Pengembang

* Nama Aplikasi: **ViAuo**
* Platform: **Android (Flutter)**
* Tujuan Pengembangan: **Pembelajaran dan pengembangan aplikasi multimedia mobile**

---

## 📄 Lisensi

Proyek ini dikembangkan untuk keperluan pembelajaran dan non-komersial. Bebas digunakan dan dimodifikasi sesuai kebutuhan.

---

⭐ *Dikembangkan menggunakan Flutter sebagai bagian dari eksplorasi pengembangan aplikasi mobile modern.*
