import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';
import '../models/audio_model.dart';
import '../models/playlist_group_model.dart'; // Model folder video
import '../models/audio_group_model.dart';    // Model folder audio

class PlaylistStorageService {
  // Key penyimpanan permanen di memori HP
  static const String _keyVideoGroups = 'video_groups_storage_key';
  static const String _keyAudioGroups = 'audio_groups_storage_key';

  // ==========================================
  // --- LOGIKA GROUP VIDEO ---
  // ==========================================
  
  static Future<List<PlaylistGroup>> getVideoGroups() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList(_keyVideoGroups);
    if (data == null) return [];
    return data.map((e) => PlaylistGroup.fromJson(e)).toList();
  }

  static Future<void> addVideoToGroup(String groupName, VideoModel video) async {
    final prefs = await SharedPreferences.getInstance();
    List<PlaylistGroup> groups = await getVideoGroups();

    // Cari apakah folder video dengan nama tersebut sudah ada
    int index = groups.indexWhere((g) => g.name == groupName);
    
    if (index != -1) {
      // Jika folder ada, tambahkan video (cek agar tidak duplikat URL)
      if (!groups[index].videos.any((v) => v.videoUrl == video.videoUrl)) {
        groups[index].videos.add(video);
      }
    } else {
      // Jika folder belum ada, buat folder baru beserta videonya
      groups.add(PlaylistGroup(name: groupName, videos: [video]));
    }
    
    // Simpan daftar folder terbaru ke SharedPreferences
    await prefs.setStringList(_keyVideoGroups, groups.map((g) => g.toJson()).toList());
  }

  // ==========================================
  // --- LOGIKA GROUP AUDIO (FOLDER MUSIK) ---
  // ==========================================

  static Future<List<AudioGroup>> getAudioGroups() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList(_keyAudioGroups);
    if (data == null) return [];
    return data.map((e) => AudioGroup.fromJson(e)).toList();
  }

  static Future<void> addAudioToGroup(String groupName, AudioModel audio) async {
    final prefs = await SharedPreferences.getInstance();
    List<AudioGroup> groups = await getAudioGroups();

    // Cari apakah folder musik dengan nama tersebut sudah ada
    int index = groups.indexWhere((g) => g.name == groupName);

    if (index != -1) {
      // Jika folder ada, masukkan lagu ke list audios milik folder tersebut
      if (!groups[index].audios.any((a) => a.audioUrl == audio.audioUrl)) {
        groups[index].audios.add(audio);
      }
    } else {
      // Jika folder tidak ditemukan, buat folder musik baru
      groups.add(AudioGroup(name: groupName, audios: [audio]));
    }

    // Update penyimpanan lokal
    await prefs.setStringList(_keyAudioGroups, groups.map((g) => g.toJson()).toList());
  }

  // --- FUNGSI CADANGAN (Agar UI lama tidak error) ---
  static Future<List<AudioModel>> getAudioPlaylist() async {
    return []; // Mengembalikan list kosong karena sistem sudah pindah ke Grouping
  }
}