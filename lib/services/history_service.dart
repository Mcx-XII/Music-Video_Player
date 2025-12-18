import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  // Key unik untuk menyimpan daftar riwayat di SharedPreferences
  static const String _keyHistory = 'user_history_storage_v1';

  // --- FUNGSI UNTUK MENGAMBIL DAFTAR RIWAYAT ---
  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyJson = prefs.getStringList(_keyHistory);
    
    if (historyJson == null) return [];

    // Mengubah String JSON kembali menjadi List Objek HistoryItem
    return historyJson.map((item) {
      return HistoryItem.fromJson(json.decode(item));
    }).toList();
  }

  // --- FUNGSI UNTUK MENAMBAH ITEM KE RIWAYAT ---
  static Future<void> addToHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    List<HistoryItem> history = await getHistory();

    // 1. Cek jika URL sudah ada di riwayat, hapus yang lama (agar tidak double)
    history.removeWhere((oldItem) => oldItem.url == item.url);
    
    // 2. Masukkan item baru ke posisi paling atas (index 0)
    history.insert(0, item);

    // 3. Batasi riwayat maksimal 50 item saja agar memori HP tidak penuh
    if (history.length > 50) {
      history = history.sublist(0, 50);
    }

    // 4. Simpan kembali ke memori dalam bentuk List String
    final List<String> historyStrings = history.map((e) {
      return json.encode(e.toJson());
    }).toList();
    
    await prefs.setStringList(_keyHistory, historyStrings);
  }

  // --- FUNGSI UNTUK MENGHAPUS SELURUH RIWAYAT ---
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }
}