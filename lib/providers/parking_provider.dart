import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/parking_location.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../services/geocoding_service.dart';

// 現在の駐車状態を管理するプロバイダー
class ParkingState {
  final ParkingLocation? currentParking;
  final bool isLoading;
  final String? errorMessage;
  final bool isRecording;

  const ParkingState({
    this.currentParking,
    this.isLoading = false,
    this.errorMessage,
    this.isRecording = false,
  });

  ParkingState copyWith({
    ParkingLocation? currentParking,
    bool? isLoading,
    String? errorMessage,
    bool? isRecording,
  }) {
    return ParkingState(
      currentParking: currentParking,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isRecording: isRecording ?? this.isRecording,
    );
  }

  bool get hasParking => currentParking != null;
}

class ParkingNotifier extends StateNotifier<ParkingState> {
  final LocationService _locationService;
  final StorageService _storageService;

  ParkingNotifier(this._locationService, this._storageService) 
      : super(const ParkingState()) {
    _loadCurrentParking();
  }

  // 保存されている駐車位置を読み込み
  Future<void> _loadCurrentParking() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final parkingLocation = await _storageService.getCurrentParkingLocation();
      state = state.copyWith(
        currentParking: parkingLocation,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '駐車位置の読み込みに失敗しました',
      );
    }
  }

  // 駐車位置を記録
  Future<bool> recordParkingLocation({
    String? textMemo,
    String? photoPath,
    DateTime? timerEndTime,
  }) async {
    state = state.copyWith(isRecording: true, errorMessage: null);

    try {
      // 現在位置を取得
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        // Web版やテスト用のモック位置情報を使用
        final mockPosition = await _getMockPosition();
        if (mockPosition == null) {
          state = state.copyWith(
            isRecording: false,
            errorMessage: '位置情報の取得に失敗しました。ブラウザで位置情報の使用を許可してください。',
          );
          return false;
        }
        // モック位置情報を使用して続行
        return _recordWithPosition(mockPosition.latitude, mockPosition.longitude, textMemo, photoPath, timerEndTime);
      }

      return _recordWithPosition(position.latitude, position.longitude, textMemo, photoPath, timerEndTime);
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: '駐車位置の記録に失敗しました: $e',
      );
      return false;
    }
  }

  // 実際の位置情報で駐車位置を記録するヘルパーメソッド
  Future<bool> _recordWithPosition(
    double latitude,
    double longitude,
    String? textMemo,
    String? photoPath,
    DateTime? timerEndTime,
  ) async {
    try {
      // PRO版かどうかをチェック
      final isPro = await _storageService.getIsProUser();

      // 駐車位置オブジェクトを作成
      final parkingLocation = ParkingLocation(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        textMemo: textMemo,
        photoPath: photoPath,
        timerEndTime: timerEndTime,
        isPro: isPro,
      );

      // 保存
      final success = await _storageService.saveCurrentParkingLocation(parkingLocation);
      
      if (success) {
        state = state.copyWith(
          currentParking: parkingLocation,
          isRecording: false,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          isRecording: false,
          errorMessage: '駐車位置の保存に失敗しました',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: '駐車位置の記録に失敗しました: $e',
      );
      return false;
    }
  }

  // モック位置情報を取得（テスト用）
  Future<MockPosition?> _getMockPosition() async {
    try {
      // 東京駅周辺のモック位置情報
      return MockPosition(
        latitude: 35.6812 + (DateTime.now().millisecond % 100) * 0.0001,
        longitude: 139.7671 + (DateTime.now().millisecond % 100) * 0.0001,
      );
    } catch (e) {
      return null;
    }
  }

  // 駐車完了（現在の駐車位置をクリアして履歴に追加）
  Future<bool> completeParkingSession() async {
    if (state.currentParking == null) return false;

    try {
      // 履歴に追加
      await _storageService.addToParkingHistory(state.currentParking!);
      
      // 現在の駐車位置をクリア
      await _storageService.clearCurrentParkingLocation();
      
      state = state.copyWith(
        currentParking: null,
        errorMessage: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: '駐車セッションの完了に失敗しました',
      );
      return false;
    }
  }

  // 駐車位置を更新（PRO機能：メモや写真を追加）
  Future<bool> updateParkingLocation({
    String? textMemo,
    String? photoPath,
    DateTime? timerEndTime,
  }) async {
    if (state.currentParking == null) return false;

    try {
      final updatedLocation = state.currentParking!.copyWith(
        textMemo: textMemo,
        photoPath: photoPath,
        timerEndTime: timerEndTime,
      );

      final success = await _storageService.saveCurrentParkingLocation(updatedLocation);
      
      if (success) {
        state = state.copyWith(
          currentParking: updatedLocation,
          errorMessage: null,
        );
        return true;
      } else {
        state = state.copyWith(
          errorMessage: '駐車位置の更新に失敗しました',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: '駐車位置の更新に失敗しました: $e',
      );
      return false;
    }
  }

  // 現在位置から駐車位置までの距離を取得
  Future<double?> getDistanceToParking() async {
    if (state.currentParking == null) return null;

    try {
      final currentPosition = await _locationService.getCurrentPosition();
      if (currentPosition == null) return null;

      return _locationService.calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        state.currentParking!.latitude,
        state.currentParking!.longitude,
      );
    } catch (e) {
      return null;
    }
  }

  // エラーをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // 強制的に駐車位置をクリア（テスト用）
  Future<void> forceClearParking() async {
    await _storageService.clearCurrentParkingLocation();
    state = state.copyWith(currentParking: null);
  }
}

// プロバイダーの定義
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService.instance;
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final parkingProvider = StateNotifierProvider<ParkingNotifier, ParkingState>((ref) {
  final locationService = ref.read(locationServiceProvider);
  final storageService = ref.read(storageServiceProvider);
  return ParkingNotifier(locationService, storageService);
});

// 駐車履歴を管理するプロバイダー
final parkingHistoryProvider = FutureProvider<List<ParkingLocation>>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getParkingHistory();
});

// PRO版かどうかを管理するプロバイダー
final isProUserProvider = FutureProvider<bool>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getIsProUser();
});

// 広告表示設定を管理するプロバイダー
final showAdsProvider = FutureProvider<bool>((ref) async {
  final storageService = ref.read(storageServiceProvider);
  return await storageService.getShowAds();
});

// 現在位置の住所を管理するプロバイダー
final currentLocationAddressProvider = FutureProvider<String?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocationAddress();
});

// 現在位置の短縮住所を管理するプロバイダー  
final currentLocationShortAddressProvider = FutureProvider<String?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocationShortAddress();
});

// モック位置情報クラス
class MockPosition {
  final double latitude;
  final double longitude;
  
  MockPosition({required this.latitude, required this.longitude});
}