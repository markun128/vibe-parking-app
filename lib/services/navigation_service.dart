import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/parking_location.dart';

// Web版でのJavaScript実行用
import 'dart:js' as js;

class NavigationService {
  static NavigationService? _instance;
  static NavigationService get instance => _instance ??= NavigationService._();
  NavigationService._();

  // 駐車位置への徒歩ナビゲーションを開始
  Future<bool> navigateToParkingLocation(ParkingLocation location) async {
    try {
      if (kIsWeb) {
        // Web版の場合は常にGoogle Maps Webを使用
        return await _launchGoogleMapsWeb(location);
      } else if (Platform.isIOS) {
        return await _launchAppleMaps(location);
      } else if (Platform.isAndroid) {
        return await _launchGoogleMaps(location);
      } else {
        // その他のプラットフォーム（Linux等）もWebを使用
        return await _launchGoogleMapsWeb(location);
      }
    } catch (e) {
      print('ナビゲーション起動エラー: $e');
      return false;
    }
  }

  // Apple Maps（iOS）でナビゲーションを開始
  Future<bool> _launchAppleMaps(ParkingLocation location) async {
    try {
      // Apple Maps URLスキーム（徒歩ナビゲーション）
      final url = 'http://maps.apple.com/?daddr=${location.latitude},${location.longitude}&dirflg=w';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        return await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
      
      // Apple Mapsが使用できない場合はGoogle Mapsにフォールバック
      return await _launchGoogleMaps(location);
    } catch (e) {
      print('Apple Maps起動エラー: $e');
      return false;
    }
  }

  // Google Maps（Android/Web）でナビゲーションを開始
  Future<bool> _launchGoogleMaps(ParkingLocation location) async {
    try {
      // Google Maps URLスキーム（徒歩ナビゲーション）
      final url = 'google.navigation:q=${location.latitude},${location.longitude}&mode=w';
      
      if (await canLaunchUrl(Uri.parse(url))) {
        return await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      }
      
      // Google Maps アプリが使用できない場合はWebにフォールバック
      return await _launchGoogleMapsWeb(location);
    } catch (e) {
      print('Google Maps起動エラー: $e');
      return false;
    }
  }

  // Google Maps Web版でナビゲーションを開始
  Future<bool> _launchGoogleMapsWeb(ParkingLocation location) async {
    try {
      // Google Maps Web URL（徒歩ナビゲーション）- より詳細な緯度経度表示
      final url = 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude.toStringAsFixed(6)},${location.longitude.toStringAsFixed(6)}&travelmode=walking';
      
      print('Google Maps URL: $url'); // デバッグ用
      
      if (kIsWeb) {
        // Web版ではJavaScript経由で開く
        try {
          js.context.callMethod('openExternalLink', [url]);
          print('JavaScript method called successfully');
          return true;
        } catch (jsError) {
          print('JavaScript method failed: $jsError');
          // fallback to url_launcher
        }
      }
      
      // 通常のurl_launcherを使用
      final uri = Uri.parse(url);
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      
      print('Launch success: $success'); // デバッグ用
      return success;
    } catch (e) {
      print('Google Maps Web起動エラー: $e');
      return false;
    }
  }

  // 駐車位置を地図で表示（ナビゲーションなし）
  Future<bool> showParkingLocationOnMap(ParkingLocation location) async {
    try {
      String url;
      
      if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
        // Web版またはデスクトップ版では Google Maps を使用
        // 緯度経度でピンマーカーを表示（6桁精度）
        final lat = location.latitude.toStringAsFixed(6);
        final lng = location.longitude.toStringAsFixed(6);
        url = 'https://www.google.com/maps/search/$lat,$lng/@$lat,$lng,18z/data=!3m1!4b1';
      } else if (Platform.isIOS) {
        // Apple Maps で位置を表示（緯度経度付き）
        final lat = location.latitude.toStringAsFixed(6);
        final lng = location.longitude.toStringAsFixed(6);
        url = 'http://maps.apple.com/?ll=$lat,$lng&q=駐車位置($lat,$lng)&z=18';
      } else {
        // Google Maps で位置を表示（緯度経度付き）
        final lat = location.latitude.toStringAsFixed(6);
        final lng = location.longitude.toStringAsFixed(6);
        url = 'https://www.google.com/maps/search/$lat,$lng/@$lat,$lng,18z';
      }
      
      print('Map display URL: $url'); // デバッグ用
      print('緯度: ${location.latitude.toStringAsFixed(6)}, 経度: ${location.longitude.toStringAsFixed(6)}'); // 座標確認用
      
      if (kIsWeb) {
        // Web版ではJavaScript経由で開く
        try {
          js.context.callMethod('openExternalLink', [url]);
          print('Map opened via JavaScript');
          return true;
        } catch (jsError) {
          print('JavaScript method failed for map: $jsError');
          // fallback to url_launcher
        }
      }
      
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      print('地図表示エラー: $e');
      return false;
    }
  }

  // 現在位置から駐車位置までの距離と方向を計算
  Map<String, dynamic> calculateLocationInfo(
    double currentLatitude,
    double currentLongitude,
    ParkingLocation parkingLocation,
  ) {
    // 距離を計算（geolocatorを使用）
    // import 'package:geolocator/geolocator.dart'; が必要
    final distance = _calculateDistance(
      currentLatitude,
      currentLongitude,
      parkingLocation.latitude,
      parkingLocation.longitude,
    );
    
    // 方位を計算
    final bearing = _calculateBearing(
      currentLatitude,
      currentLongitude,
      parkingLocation.latitude,
      parkingLocation.longitude,
    );
    
    return {
      'distance': distance,
      'distanceText': _formatDistance(distance),
      'bearing': bearing,
      'direction': _getDirectionText(bearing),
    };
  }

  // 2点間の距離を計算（メートル単位）
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Haversine formula の簡易実装
    const double earthRadius = 6371000; // 地球の半径（メートル）
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
  
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // 2点間の方位を計算（度数）
  double _calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);
    
    final double y = sin(dLon) * cos(lat2Rad);
    final double x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);
    
    final double bearing = (atan2(y, x) * 180 / pi);
    
    return (bearing + 360) % 360;
  }

  // 距離を読みやすい形式でフォーマット
  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  // 方位角から方向テキストを取得
  String _getDirectionText(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) {
      return '北';
    } else if (bearing >= 22.5 && bearing < 67.5) {
      return '北東';
    } else if (bearing >= 67.5 && bearing < 112.5) {
      return '東';
    } else if (bearing >= 112.5 && bearing < 157.5) {
      return '南東';
    } else if (bearing >= 157.5 && bearing < 202.5) {
      return '南';
    } else if (bearing >= 202.5 && bearing < 247.5) {
      return '南西';
    } else if (bearing >= 247.5 && bearing < 292.5) {
      return '西';
    } else {
      return '北西';
    }
  }

  // ナビゲーションアプリが利用可能かチェック
  Future<bool> isNavigationAvailable() async {
    if (kIsWeb) {
      return true; // Web版では常に利用可能
    } else if (Platform.isIOS) {
      return await canLaunchUrl(Uri.parse('http://maps.apple.com/'));
    } else if (Platform.isAndroid) {
      return await canLaunchUrl(Uri.parse('google.navigation:q=0,0'));
    }
    return true; // デスクトップ版では常に利用可能
  }
}