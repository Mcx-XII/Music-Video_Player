# ViAuo – Music & Video Player

## Nama Aplikasi
**ViAuo (Video & Audio Player)**

---

## TIM 
1. Dhea Tri Lova Simanjuntak (241712017)
2. Ruth Anggelia Sihombing (241712012)
3. Reza Pahlepi (241712010)
4. Kabul Manik (241712023)
5. Tiwi Lamberkat (241712001)
6. Rivaldo Nainggolan (241712043)

---

## Deskripsi Singkat Aplikasi
ViAuo adalah aplikasi pemutar video dan audio berbasis Flutter yang menyediakan fitur **streaming online** dan **mode offline**.  
Aplikasi ini dirancang untuk memungkinkan pengguna memutar konten multimedia baik melalui koneksi internet maupun tanpa koneksi internet dengan memanfaatkan file lokal/asset.

---

## Daftar Fitur pada Aplikasi
- Streaming video secara online melalui URL
- Pemutaran video secara offline (asset video)
- Play dan pause video
- Tampilan daftar video
- Navigasi antar halaman (Video, Audio, Pencarian, Riwayat)
- Antarmuka sederhana dan responsif
- Mendukung platform Android dan Web

---

## Stack Technology yang Digunakan
- **Flutter** sebagai framework utama
- **Dart** sebagai bahasa pemrograman
- **Android SDK** untuk platform Android
- **Material Design** untuk antarmuka pengguna

---

## Flutter Version
- Flutter **3.38.x**
- Dart SDK **≥ 3.9.0**

---

## Android Version
- Minimum Android SDK: **Android 7.0 (API Level 24)**
- Target Android SDK: **Android 13+**

---

## Library / Framework yang Digunakan
- `video_player`  
  Digunakan untuk memutar video baik dari internet (streaming) maupun dari file lokal (offline).
- `path_provider`  
  Digunakan untuk mengakses direktori penyimpanan lokal pada perangkat.
- `flutter/material.dart`  
  Digunakan untuk komponen UI berbasis Material Design.

---

## Public / Private API yang Digunakan
- **Public API**
  - URL video publik (contoh: video sample Flutter)
- **Private API**
  - Tidak menggunakan private API eksternal
  - Akses file lokal menggunakan API bawaan Flutter

---

## Cara Menjalankan Aplikasi

1. Pastikan Flutter sudah terinstall
   ```bash
   flutter --version
2. Clone repository
   ```bash
   git clone https://github.com/Mcx-XII/Music-Video_Player.git
3. Masuk ke folder project
   ```bash
   cd Music-Video_Player
4. Pindah ke branch streaming & offline mode
   ```bash
   git checkout streaming-offline-mode
5. Install dependencies
   ```bash
   flutter pub get
6. Jalankan aplikasi
   ```bash
   flutter run
7. Pastikan perangkat Android atau emulator sudah terhubung
