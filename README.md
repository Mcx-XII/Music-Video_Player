# ViAuo – Music & Video Player

![Flutter](https://img.shields.io/badge/Flutter-Framework-blue)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2)
![Platform](https://img.shields.io/badge/Platform-Android-green)
![License](https://img.shields.io/badge/License-Educational-lightgrey)
![Flutter CI](https://github.com/Mcx-XII/Music-Video_Player/actions/workflows/flutter.yml/badge.svg)
![GitHub stars](https://img.shields.io/github/stars/USERNAME/Music-Video_Player?style=social)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen)

ViAuo adalah aplikasi **pemutar musik dan video berbasis Android** yang dikembangkan menggunakan **Flutter**. Aplikasi ini memungkinkan pengguna untuk mengakses, menelusuri, dan memutar file **audio (MP3)** serta **video (MP4)** yang tersimpan di perangkat secara langsung. Proyek ini dibuat sebagai bagian dari pengembangan dan pembelajaran aplikasi mobile menggunakan Flutter.

---
## TIM 
1. Tiwi Lamberkat Silaban (241712001)
2. Reza Pahlepi (241712010)
3. Ruth Anggelia Sihombing (241712012)
4. Dhea Trilova Simanjuntak (241712017)
5. Kabul Manik (241712023)
6. Rivaldo Nainggolan (241712043)

   <a href="https://github.com/Mcx-XII/Music-Video_Player/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Mcx-XII/Music-Video_Player" />
</a>
   
## Deskripsi Proyek

Seiring meningkatnya kebutuhan akan aplikasi multimedia yang ringan dan responsif, ViAuo hadir sebagai solusi pemutar media lokal dengan antarmuka sederhana namun fungsional. Aplikasi ini mengimplementasikan navigasi multi-halaman, manajemen izin Android modern, serta dukungan terhadap penyimpanan internal perangkat.

ViAuo dirancang untuk dijalankan pada perangkat Android fisik dan mendukung versi Android terbaru, termasuk sistem perizinan Android 13+.

---

## Fitur Utama

*  Pemutar video lokal (format MP4)
*  Pemutar audio lokal (format MP3)
*  Akses media langsung dari penyimpanan perangkat
*  Navigasi menggunakan Bottom Navigation Bar
*  Fitur pencarian media
*  Riwayat pemutaran media
*  Halaman profil pengguna
*  Antarmuka dengan tema gelap (Dark Mode)

---

## Teknologi & Tools
Proyek ViAuo dikembangkan menggunakan teknologi utama Flutter dengan fokus pada stabilitas framework dan ekosistem pendukungnya.

* **Flutter (Stable Channel)**  
  Digunakan sebagai framework utama untuk membangun antarmuka aplikasi dan logika bisnis. Versi Flutter yang digunakan berada pada **channel Stable** untuk memastikan kestabilan, kompatibilitas plugin, dan minim error selama pengembangan.

* **Dart**  
  Bahasa pemrograman utama yang digunakan dalam pengembangan aplikasi Flutter.

* **Flutter SDK Tools**  
  Digunakan untuk build, debug, hot reload, dan manajemen dependensi.

* **permission_handler**  
  Digunakan untuk menangani permintaan izin akses media secara runtime sesuai standar Flutter modern.

* **Android SDK (Sebagai Platform Target)**  
  Digunakan hanya sebagai platform deploy, tanpa ketergantungan pada fitur Android versi tertentu.

 ## Status Flutter Version

Aplikasi ViAuo dikembangkan dan diuji menggunakan:

* **Flutter Channel**: Stable
* **Flutter Version**: Mengikuti versi stable terbaru saat pengembangan
* **Dart SDK**: Mengikuti versi bawaan Flutter Stable

Penggunaan Flutter Stable bertujuan untuk:
* Menjamin kompatibilitas plugin
* Menghindari breaking changes dari versi beta atau dev
* Memastikan aplikasi dapat dijalankan secara konsisten di berbagai lingkungan pengembangan



---

##  Struktur Direktori

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

## Izin Akses (Permissions)

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

## Cara Menjalankan Aplikasi

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

## Catatan Khusus Perangkat Android

* Disarankan menggunakan **perangkat fisik** (bukan emulator)
* Untuk perangkat Xiaomi/Redmi:

  * Aktifkan *Developer Options*
  * Aktifkan *USB Debugging*
  * Aktifkan *Install via USB*
* Android 13 ke atas memerlukan izin media terpisah (audio & video)

---

## Dokumentasi Tampilan

> Screenshot aplikasi dapat ditambahkan pada bagian ini untuk dokumentasi visual.

---

## Pengembang

* Nama Aplikasi: **ViAuo**
* Platform: **Android (Flutter)**
* Tujuan Pengembangan: **Pembelajaran dan pengembangan aplikasi multimedia mobile**

---

## Lisensi

Proyek ini dikembangkan untuk keperluan pembelajaran dan non-komersial. Bebas digunakan dan dimodifikasi sesuai kebutuhan.



---
<br>
  <img alt="snake eating my contributions" src="https://raw.githubusercontent.com/salesp07/salesp07/output/github-contribution-grid-snake.svg" />
  
  <br/><br/><br/>
