import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';
import '../models/audio_model.dart';
import '../models/playlist_group_model.dart';

class PlaylistStorageService {
  static const String _keyVideoGroups = 'video_groups_key';
  static const String _keyAudioPlaylist = 'audio_playlist_key';

  // --- LOGIKA GROUP VIDEO ---
  static Future<List<PlaylistGroup>> getVideoGroups() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList(_keyVideoGroups);
    if (data == null) return [];
    return data.map((e) => PlaylistGroup.fromJson(e)).toList();
  }

  static Future<void> addVideoToGroup(String groupName, VideoModel video) async {
    final prefs = await SharedPreferences.getInstance();
    List<PlaylistGroup> groups = await getVideoGroups();

    int index = groups.indexWhere((g) => g.name == groupName);
    if (index != -1) {
      if (!groups[index].videos.any((v) => v.videoUrl == video.videoUrl)) {
        groups[index].videos.add(video);
      }
    } else {
      groups.add(PlaylistGroup(name: groupName, videos: [video]));
    }
    await prefs.setStringList(_keyVideoGroups, groups.map((g) => g.toJson()).toList());
  }

  // --- LOGIKA AUDIO (FIX ERROR DI SCREENSHOT) ---
  static Future<List<AudioModel>> getAudioPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? data = prefs.getStringList(_keyAudioPlaylist);
    if (data == null) return [];
    return data.map((e) => AudioModel.fromJson(e)).toList();
  }

  static Future<void> saveAudioToPlaylist(AudioModel audio) async {
    final prefs = await SharedPreferences.getInstance();
    List<AudioModel> current = await getAudioPlaylist();
    if (!current.any((e) => e.audioUrl == audio.audioUrl)) {
      current.add(audio);
      await prefs.setStringList(_keyAudioPlaylist, current.map((e) => e.toJson()).toList());
    }
  }
}