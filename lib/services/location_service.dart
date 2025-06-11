import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'geocoding_service.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  // 位置情報の権限をチェック・リクエスト
  Future<bool> checkAndRequestPermission() async {
    try {
      // アプリレベルの権限チェック
      PermissionStatus permission = await Permission.location.status;
      
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }
      
      if (permission.isPermanentlyDenied) {
        // 設定画面に遷移を促す
        await openAppSettings();
        return false;
      }
      
      if (permission.isGranted) {
        // Geolocatorレベルの権限もチェック
        LocationPermission geoPermission = await Geolocator.checkPermission();
        
        if (geoPermission == LocationPermission.denied) {
          geoPermission = await Geolocator.requestPermission();
        }
        
        if (geoPermission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
          return false;
        }
        
        return geoPermission == LocationPermission.whileInUse ||
               geoPermission == LocationPermission.always;
      }
      
      return false;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  // 位置情報サービスが有効かチェック
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // 現在位置を取得
  Future<Position?> getCurrentPosition() async {
    try {
      print('位置情報取得開始');
      
      // Web環境でも実際の位置情報を取得
      if (kIsWeb) {
        print('Web環境: 実際の位置情報を取得中...');
        
        try {
          // Web環境での位置情報取得
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15),
          );
          print('Web環境で位置情報取得成功: 緯度=${position.latitude}, 経度=${position.longitude}');
          return position;
        } catch (webError) {
          print('Web環境での位置情報取得エラー: $webError');
          // Web環境でエラーの場合、フォールバックとしてテスト位置を使用
          print('フォールバック: テスト用位置情報を使用（東京駅）');
          return Position(
            latitude: 35.681236,
            longitude: 139.767125,
            timestamp: DateTime.now(),
            accuracy: 10.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
          );
        }
      }

      // モバイル環境での権限チェック
      if (!await checkAndRequestPermission()) {
        throw Exception('位置情報の権限が許可されていません');
      }

      // 位置情報サービス有効性チェック
      if (!await isLocationServiceEnabled()) {
        throw Exception('位置情報サービスが無効です');
      }

      // 現在位置を取得
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('位置情報取得成功: 緯度=${position.latitude}, 経度=${position.longitude}');
      return position;
    } catch (e) {
      print('位置情報取得エラー: $e');
      return null;
    }
  }

  // 高精度での現在位置取得（時間をかけてでも正確な位置を取得）
  Future<Position?> getHighAccuracyPosition() async {
    try {
      if (!await checkAndRequestPermission()) {
        throw Exception('位置情報の権限が許可されていません');
      }

      if (!await isLocationServiceEnabled()) {
        throw Exception('位置情報サービスが無効です');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 30),
      );

      return position;
    } catch (e) {
      print('高精度位置情報取得エラー: $e');
      return null;
    }
  }

  // 2点間の距離を計算（メートル単位）
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // 2点間の方位を計算（度数）
  double calculateBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // 位置情報の精度テキストを取得
  String getAccuracyText(double accuracy) {
    if (accuracy <= 5) {
      return '非常に高精度';
    } else if (accuracy <= 10) {
      return '高精度';
    } else if (accuracy <= 50) {
      return '中精度';
    } else {
      return '低精度';
    }
  }

  // 位置情報設定の案内メッセージ
  String getLocationSettingsMessage() {
    return '正確な駐車位置を記録するために、位置情報の使用を許可してください。\n\n'
           '設定 > プライバシーとセキュリティ > 位置情報サービス > P-Memo > 「このAppの使用中のみ許可」を選択してください。';
  }

  // 現在位置の住所を取得
  Future<String?> getCurrentLocationAddress() async {
    try {
      print('現在位置住所取得開始');
      final position = await getCurrentPosition();
      print('現在位置取得結果: $position');
      
      if (position != null) {
        print('位置情報取得成功: 緯度=${position.latitude}, 経度=${position.longitude}');
        final geocodingService = GeocodingService.instance;
        final address = await geocodingService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        print('住所取得結果: $address');
        return address;
      } else {
        print('位置情報の取得に失敗');
        return '位置情報を取得できませんでした';
      }
    } catch (e) {
      print('現在位置住所取得エラー: $e');
      return '住所の取得でエラーが発生しました: $e';
    }
  }

  // 現在位置の短縮住所を取得
  Future<String?> getCurrentLocationShortAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position != null) {
        final geocodingService = GeocodingService.instance;
        final address = await geocodingService.getAddressFromCoordinates(
          position.latitude, 
          position.longitude
        );
        // 市区町村レベルまでの短縮住所を作成
        if (address != null) {
          final parts = address.split(' ');
          return parts.length > 2 ? parts.take(2).join(' ') : address;
        }
      }
      return null;
    } catch (e) {
      print('現在位置短縮住所取得エラー: $e');
      return null;
    }
  }
}