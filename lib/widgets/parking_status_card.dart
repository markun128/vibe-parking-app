import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/parking_location.dart';
import '../providers/parking_provider.dart';
import '../services/navigation_service.dart';
import '../services/geocoding_service.dart';
import '../theme/app_theme.dart';
import 'nearby_parking_widget.dart';

class ParkingStatusCard extends ConsumerStatefulWidget {
  final ParkingState parkingState;
  final VoidCallback onRefresh;

  const ParkingStatusCard({
    super.key,
    required this.parkingState,
    required this.onRefresh,
  });

  @override
  ConsumerState<ParkingStatusCard> createState() => _ParkingStatusCardState();
}

class _ParkingStatusCardState extends ConsumerState<ParkingStatusCard> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.parkingState.hasParking
              ? const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.parkingState.hasParking ? '駐車中' : '未駐車',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: widget.parkingState.hasParking 
                          ? Colors.white 
                          : Colors.grey.shade800,
                      shadows: widget.parkingState.hasParking ? [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ] : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: widget.parkingState.hasParking 
                          ? Colors.white 
                          : Colors.grey.shade700,
                    ),
                    onPressed: widget.onRefresh,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (widget.parkingState.hasParking) ...[
                _buildParkingInfo(widget.parkingState.currentParking!),
              ] else ...[
                _buildNoParkingInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParkingInfo(ParkingLocation location) {
    final elapsed = _currentTime.difference(location.timestamp);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              '駐車時間: ${_formatDuration(elapsed)}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 駐車時間表示
        Row(
          children: [
            const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${location.timestamp.month}/${location.timestamp.day} ${location.timestamp.hour}:${location.timestamp.minute.toString().padLeft(2, '0')} に記録',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 駐車位置の住所表示
        _buildParkingLocationAddress(location),
        
        if (location.textMemo != null && location.textMemo!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.note,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location.textMemo!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
        
        if (location.timerEndTime != null) ...[
          const SizedBox(height: 12),
          _buildTimerInfo(location.timerEndTime!),
        ],
        
        if (location.photoPath != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '写真あり',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 16),
        
        // 座標表示とマップ表示ボタン
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.gps_fixed,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // マップ表示ボタン
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showLocationOnMap(location),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF06B6D4), // シアン
                          Color(0xFF0284C7), // スカイブルー
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.explore,
                            color: Colors.white,
                            size: 18,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'マップ',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoParkingInfo() {
    final currentLocationAddressAsync = ref.watch(currentLocationAddressProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '駐車位置が記録されていません',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        
        // 現在位置の住所表示
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.blue.shade100.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '現在地',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              currentLocationAddressAsync.when(
                data: (address) => Text(
                  address ?? '住所を取得できませんでした',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                loading: () => Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '住所を取得中...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                error: (_, __) => Text(
                  '住所の取得に失敗しました',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        Text(
          '下の「駐車位置を記録」ボタンを押して\n現在の位置を保存しましょう',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerInfo(DateTime timerEndTime) {
    final timeLeft = timerEndTime.difference(_currentTime);
    
    if (timeLeft.isNegative) {
      return Row(
        children: [
          const Icon(
            Icons.timer_off,
            color: Colors.redAccent,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'タイマー終了',
            style: TextStyle(
              fontSize: 14,
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(
            Icons.timer,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'タイマー: ${_formatDuration(timeLeft)} 残り',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      );
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}日${duration.inHours % 24}時間';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}時間${duration.inMinutes % 60}分';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  // 駐車位置をマップで表示
  void _showLocationOnMap(ParkingLocation location) async {
    try {
      final navigationService = NavigationService.instance;
      final success = await navigationService.showParkingLocationOnMap(location);
      
      if (mounted) {
        if (success) {
          // 成功メッセージは不要（マップが開かれるため）
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('マップを開けませんでした。ブラウザのポップアップブロックを確認してください。'),
              backgroundColor: AppTheme.errorColor,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('マップ表示エラー: $e'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // 駐車位置の住所を表示
  Widget _buildParkingLocationAddress(ParkingLocation location) {
    return FutureBuilder<String?>(
      future: GeocodingService.instance.getAddressFromParkingLocation(location),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '住所を取得中...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        }

        final address = snapshot.data;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address ?? '住所を取得できませんでした',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.3,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}