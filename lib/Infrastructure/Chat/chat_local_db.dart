import 'dart:convert';
import 'package:catering/Domain/Chat/message_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ChatLocalDb {
  static const String _cacheKeyPrefix = 'chat_history_';

  Future<void> saveHistory(String roomId, List<MessageModel> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final data = messages.map((m) => m.toJson()).toList();
    await prefs.setString('$_cacheKeyPrefix$roomId', jsonEncode(data));
  }

  Future<List<MessageModel>> getHistory(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString('$_cacheKeyPrefix$roomId');
    if (rawData == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(rawData);
      return decoded.map((m) => MessageModel.fromJson(m as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }
}
