import 'package:geocoding/geocoding.dart';
import '../models/parking_location.dart';

class GeocodingService {
  static GeocodingService? _instance;
  static GeocodingService get instance => _instance ??= GeocodingService._();
  GeocodingService._();

  /// 緯度経度から住所を取得
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      print('住所取得開始: 緯度=$latitude, 経度=$longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      print('Placemarks取得完了: ${placemarks.length}件');
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        print('Placemark詳細: ${placemark.toString()}');
        final address = _formatAddress(placemark);
        print('フォーマット済み住所: $address');
        return address;
      }
      
      print('Placemarkが空です');
      return _getFallbackAddress(latitude, longitude);
    } catch (e) {
      print('住所取得エラー: $e');
      print('エラータイプ: ${e.runtimeType}');
      return _getFallbackAddress(latitude, longitude);
    }
  }

  /// フォールバック用の簡易住所表示
  String _getFallbackAddress(double latitude, double longitude) {
    // 緯度経度をそのまま表示
    return '緯度: ${latitude.toStringAsFixed(6)}, 経度: ${longitude.toStringAsFixed(6)}';
  }

  /// ParkingLocationから住所を取得
  Future<String?> getAddressFromParkingLocation(ParkingLocation location) async {
    return await getAddressFromCoordinates(location.latitude, location.longitude);
  }

  /// 現在位置の住所を取得
  Future<String?> getCurrentLocationAddress() async {
    try {
      // 位置情報サービスから現在位置を取得する場合
      // この機能は LocationService と連携して実装
      return null;
    } catch (e) {
      print('現在位置住所取得エラー: $e');
      return null;
    }
  }

  /// Placemarkを読みやすい住所形式にフォーマット
  String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];

    // 日本の住所形式に対応
    if (placemark.country == 'Japan' || placemark.country == '日本') {
      // 日本の場合：都道府県、市区町村、町名、番地の順
      if (placemark.administrativeArea?.isNotEmpty == true) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.locality?.isNotEmpty == true) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.subLocality?.isNotEmpty == true) {
        addressParts.add(placemark.subLocality!);
      }
      if (placemark.thoroughfare?.isNotEmpty == true) {
        addressParts.add(placemark.thoroughfare!);
      }
      if (placemark.subThoroughfare?.isNotEmpty == true) {
        addressParts.add(placemark.subThoroughfare!);
      }
    } else {
      // 海外の場合：番地、通り、市、州、国の順
      if (placemark.subThoroughfare?.isNotEmpty == true) {
        addressParts.add(placemark.subThoroughfare!);
      }
      if (placemark.thoroughfare?.isNotEmpty == true) {
        addressParts.add(placemark.thoroughfare!);
      }
      if (placemark.locality?.isNotEmpty == true) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.administrativeArea?.isNotEmpty == true) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.country?.isNotEmpty == true) {
        addressParts.add(placemark.country!);
      }
    }

    return addressParts.isNotEmpty 
        ? addressParts.join(' ')
        : '住所を取得できませんでした';
  }

  /// 住所の短縮版を取得（市区町村レベルまで）
  String getShortAddress(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.country == 'Japan' || placemark.country == '日本') {
      if (placemark.administrativeArea?.isNotEmpty == true) {
        addressParts.add(placemark.administrativeArea!);
      }
      if (placemark.locality?.isNotEmpty == true) {
        addressParts.add(placemark.locality!);
      }
    } else {
      if (placemark.locality?.isNotEmpty == true) {
        addressParts.add(placemark.locality!);
      }
      if (placemark.administrativeArea?.isNotEmpty == true) {
        addressParts.add(placemark.administrativeArea!);
      }
    }

    return addressParts.isNotEmpty 
        ? addressParts.join(' ')
        : '不明な場所';
  }

  /// 住所からランドマークや建物名を抽出
  String? getLandmark(Placemark placemark) {
    // 建物名やランドマーク情報を取得
    if (placemark.name?.isNotEmpty == true && 
        placemark.name != placemark.thoroughfare &&
        placemark.name != placemark.locality) {
      return placemark.name;
    }
    return null;
  }
}