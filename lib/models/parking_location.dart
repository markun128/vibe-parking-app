import 'dart:convert';

class ParkingLocation {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? photoPath;
  final String? textMemo;
  final DateTime? timerEndTime;
  final bool isPro;

  const ParkingLocation({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.photoPath,
    this.textMemo,
    this.timerEndTime,
    this.isPro = false,
  });

  // JSONからオブジェクトを作成
  factory ParkingLocation.fromJson(Map<String, dynamic> json) {
    return ParkingLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      photoPath: json['photoPath'],
      textMemo: json['textMemo'],
      timerEndTime: json['timerEndTime'] != null 
          ? DateTime.parse(json['timerEndTime']) 
          : null,
      isPro: json['isPro'] ?? false,
    );
  }

  // オブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'photoPath': photoPath,
      'textMemo': textMemo,
      'timerEndTime': timerEndTime?.toIso8601String(),
      'isPro': isPro,
    };
  }

  // オブジェクトをJSON文字列に変換
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // JSON文字列からオブジェクトを作成
  static ParkingLocation fromJsonString(String jsonString) {
    return ParkingLocation.fromJson(jsonDecode(jsonString));
  }

  // copyWithメソッド
  ParkingLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? photoPath,
    String? textMemo,
    DateTime? timerEndTime,
    bool? isPro,
  }) {
    return ParkingLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      photoPath: photoPath ?? this.photoPath,
      textMemo: textMemo ?? this.textMemo,
      timerEndTime: timerEndTime ?? this.timerEndTime,
      isPro: isPro ?? this.isPro,
    );
  }

  // 経過時間を取得
  Duration getElapsedTime() {
    return DateTime.now().difference(timestamp);
  }

  // タイマーが設定されているかチェック
  bool hasTimer() {
    return timerEndTime != null;
  }

  // タイマーが終了しているかチェック
  bool isTimerExpired() {
    if (timerEndTime == null) return false;
    return DateTime.now().isAfter(timerEndTime!);
  }

  // 残り時間を取得
  Duration? getRemainingTime() {
    if (timerEndTime == null) return null;
    final remaining = timerEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  String toString() {
    return 'ParkingLocation(lat: $latitude, lng: $longitude, time: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ timestamp.hashCode;
  }
}