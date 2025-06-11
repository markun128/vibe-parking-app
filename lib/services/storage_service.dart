import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_location.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  // キー定数
  static const String _currentParkingKey = 'current_parking_location';
  static const String _parkingHistoryKey = 'parking_history';
  static const String _isProUserKey = 'is_pro_user';
  static const String _showAdsKey = 'show_ads';
  static const String _appOpenCountKey = 'app_open_count';
  static const String _lastReviewPromptKey = 'last_review_prompt';

  SharedPreferences? _prefs;

  // SharedPreferencesの初期化
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 現在の駐車位置を保存
  Future<bool> saveCurrentParkingLocation(ParkingLocation location) async {
    await init();
    try {
      final jsonString = location.toJsonString();
      return await _prefs!.setString(_currentParkingKey, jsonString);
    } catch (e) {
      print('現在の駐車位置保存エラー: $e');
      return false;
    }
  }

  // 現在の駐車位置を取得
  Future<ParkingLocation?> getCurrentParkingLocation() async {
    await init();
    try {
      final jsonString = _prefs!.getString(_currentParkingKey);
      if (jsonString == null) return null;
      return ParkingLocation.fromJsonString(jsonString);
    } catch (e) {
      print('現在の駐車位置取得エラー: $e');
      return null;
    }
  }

  // 現在の駐車位置を削除
  Future<bool> clearCurrentParkingLocation() async {
    await init();
    try {
      return await _prefs!.remove(_currentParkingKey);
    } catch (e) {
      print('現在の駐車位置削除エラー: $e');
      return false;
    }
  }

  // 駐車履歴を保存
  Future<bool> saveParkingHistory(List<ParkingLocation> history) async {
    await init();
    try {
      final jsonList = history.map((location) => location.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs!.setString(_parkingHistoryKey, jsonString);
    } catch (e) {
      print('駐車履歴保存エラー: $e');
      return false;
    }
  }

  // 駐車履歴を取得
  Future<List<ParkingLocation>> getParkingHistory() async {
    await init();
    try {
      final jsonString = _prefs!.getString(_parkingHistoryKey);
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ParkingLocation.fromJson(json))
          .toList();
    } catch (e) {
      print('駐車履歴取得エラー: $e');
      return [];
    }
  }

  // 駐車履歴に追加
  Future<bool> addToParkingHistory(ParkingLocation location) async {
    try {
      final history = await getParkingHistory();
      
      // 最新の記録を先頭に追加
      history.insert(0, location);
      
      // PRO版は10件まで、無料版は3件まで
      final isProUser = await getIsProUser();
      final maxHistory = isProUser ? 10 : 3;
      
      if (history.length > maxHistory) {
        history.removeRange(maxHistory, history.length);
      }
      
      return await saveParkingHistory(history);
    } catch (e) {
      print('駐車履歴追加エラー: $e');
      return false;
    }
  }

  // PRO版ユーザーかどうかを保存
  Future<bool> setIsProUser(bool isPro) async {
    await init();
    try {
      return await _prefs!.setBool(_isProUserKey, isPro);
    } catch (e) {
      print('PRO版設定保存エラー: $e');
      return false;
    }
  }

  // PRO版ユーザーかどうかを取得
  Future<bool> getIsProUser() async {
    await init();
    try {
      return _prefs!.getBool(_isProUserKey) ?? false;
    } catch (e) {
      print('PRO版設定取得エラー: $e');
      return false;
    }
  }

  // 広告表示設定を保存
  Future<bool> setShowAds(bool showAds) async {
    await init();
    try {
      return await _prefs!.setBool(_showAdsKey, showAds);
    } catch (e) {
      print('広告表示設定保存エラー: $e');
      return false;
    }
  }

  // 広告表示設定を取得
  Future<bool> getShowAds() async {
    await init();
    try {
      final isProUser = await getIsProUser();
      if (isProUser) return false; // PRO版では広告を表示しない
      
      return _prefs!.getBool(_showAdsKey) ?? true;
    } catch (e) {
      print('広告表示設定取得エラー: $e');
      return true;
    }
  }

  // アプリ起動回数をカウント
  Future<int> incrementAppOpenCount() async {
    await init();
    try {
      final count = await getAppOpenCount();
      final newCount = count + 1;
      await _prefs!.setInt(_appOpenCountKey, newCount);
      return newCount;
    } catch (e) {
      print('アプリ起動回数更新エラー: $e');
      return 1;
    }
  }

  // アプリ起動回数を取得
  Future<int> getAppOpenCount() async {
    await init();
    try {
      return _prefs!.getInt(_appOpenCountKey) ?? 0;
    } catch (e) {
      print('アプリ起動回数取得エラー: $e');
      return 0;
    }
  }

  // 最後のレビュー依頼日時を保存
  Future<bool> setLastReviewPrompt(DateTime dateTime) async {
    await init();
    try {
      return await _prefs!.setString(
        _lastReviewPromptKey, 
        dateTime.toIso8601String(),
      );
    } catch (e) {
      print('レビュー依頼日時保存エラー: $e');
      return false;
    }
  }

  // 最後のレビュー依頼日時を取得
  Future<DateTime?> getLastReviewPrompt() async {
    await init();
    try {
      final dateString = _prefs!.getString(_lastReviewPromptKey);
      if (dateString == null) return null;
      return DateTime.parse(dateString);
    } catch (e) {
      print('レビュー依頼日時取得エラー: $e');
      return null;
    }
  }

  // データを全てクリア
  Future<bool> clearAllData() async {
    await init();
    try {
      return await _prefs!.clear();
    } catch (e) {
      print('全データクリアエラー: $e');
      return false;
    }
  }

  // 現在の駐車位置があるかチェック
  Future<bool> hasCurrentParking() async {
    final location = await getCurrentParkingLocation();
    return location != null;
  }
}