import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/parking_status_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/ads_banner.dart';
import '../services/location_service.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _currentLocationAddress;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    // アプリ起動回数をカウント
    _incrementAppOpenCount();
    // 現在地を取得
    _getCurrentLocation();
  }

  Future<void> _incrementAppOpenCount() async {
    final storageService = ref.read(storageServiceProvider);
    await storageService.incrementAppOpenCount();
  }

  // 現在地を取得
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationService = LocationService.instance;
      final address = await locationService.getCurrentLocationAddress();
      
      if (mounted) {
        setState(() {
          _currentLocationAddress = address;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationAddress = '現在地を取得できませんでした';
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parkingState = ref.watch(parkingProvider);
    final showAdsAsync = ref.watch(showAdsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('P-Memo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // メインコンテンツエリア
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 駐車状態カード
                    ParkingStatusCard(
                      parkingState: parkingState,
                      onRefresh: () => _refreshParkingState(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // アクションボタン
                    ActionButtons(
                      parkingState: parkingState,
                      onParkCar: () => _recordParkingLocation(),
                      onCompleteParkingSession: () => _completeParkingSession(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    
                    // 現在地情報表示
                    _buildCurrentLocationCard(),
                    
                    const SizedBox(height: 16),
                    
                    // エラーメッセージ表示
                    if (parkingState.errorMessage != null)
                      _buildErrorMessage(parkingState.errorMessage!),
                    
                    // ローディング表示
                    if (parkingState.isLoading || parkingState.isRecording)
                      const _LoadingIndicator(),
                    
                    // 底部余白を追加
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // 広告バナー（無料版のみ）
            showAdsAsync.when(
              data: (showAds) => showAds 
                  ? const AdsBanner() 
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // 駐車位置を記録
  Future<void> _recordParkingLocation() async {
    try {
      // 位置情報取得前にユーザーに説明
      final shouldProceed = await _showLocationPermissionDialog();
      if (!shouldProceed) return;

      final success = await ref.read(parkingProvider.notifier).recordParkingLocation();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('駐車位置を記録しました！'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // 位置情報許可ダイアログを表示
  Future<bool> _showLocationPermissionDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('位置情報の使用'),
          ],
        ),
        content: const Text(
          '駐車位置を正確に記録するため、現在地の取得を行います。\n\n'
          'ブラウザから位置情報の使用許可を求められた場合は「許可」を選択してください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    ) ?? false;
  }


  // 駐車セッション完了
  Future<void> _completeParkingSession() async {
    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('駐車完了'),
        content: const Text('駐車セッションを完了しますか？\n記録は履歴に保存されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('完了'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await ref.read(parkingProvider.notifier).completeParkingSession();
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('駐車セッションを完了しました'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
          
          // 履歴プロバイダーを更新
          ref.invalidate(parkingHistoryProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  // 駐車状態をリフレッシュ
  Future<void> _refreshParkingState() async {
    ref.invalidate(parkingProvider);
  }

  // 設定画面に遷移
  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  // エラーメッセージウィジェット
  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: AppTheme.errorColor,
            onPressed: () {
              ref.read(parkingProvider.notifier).clearError();
            },
          ),
        ],
      ),
    );
  }

  // 現在地情報カードを構築 - シンプル
  Widget _buildCurrentLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppTheme.onSurfaceColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '現在地',
                style: TextStyle(
                  color: AppTheme.onSurfaceColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                color: AppTheme.onSurfaceColor,
                onPressed: _getCurrentLocation,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoadingLocation)
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '現在地を取得中...',
                  style: TextStyle(
                    color: AppTheme.onSurfaceColor,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            Text(
              _currentLocationAddress ?? '現在地を取得',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }
}

// ローディングインジケーター
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            '位置情報を取得中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}