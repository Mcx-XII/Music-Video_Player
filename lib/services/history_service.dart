import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const _key = 'history_items';
  static const _maxItems = 50;

  static Future<void> add(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_key) ?? [];

    // hapus duplikat (url sama)
    rawList.removeWhere((e) =>
        HistoryItem.fromJson(jsonDecode(e)).url == item.url);

    rawList.insert(0, jsonEncode(item.toJson()));

    if (rawList.length > _maxItems) {
      rawList.removeLast();
    }

    await prefs.setStringList(_key, rawList);
  }

  static Future<List<HistoryItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];

    return rawList
        .map((e) => HistoryItem.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
