import 'package:flutter/material.dart';
import '../providers/parking_provider.dart';
import '../theme/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final ParkingState parkingState;
  final VoidCallback onParkCar;
  final VoidCallback onCompleteParkingSession;

  const ActionButtons({
    super.key,
    required this.parkingState,
    required this.onParkCar,
    required this.onCompleteParkingSession,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!parkingState.hasParking) ...[
          // 駐車位置記録ボタン - シンプル
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: parkingState.isRecording ? null : onParkCar,
              style: AppStyles.primaryButtonStyle,
              icon: parkingState.isRecording 
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.onPrimaryColor,
                      ),
                    )
                  : Icon(Icons.add_location_outlined),
              label: Text(
                parkingState.isRecording 
                    ? '位置情報取得中...' 
                    : '駐車位置を記録',
              ),
            ),
          ),
        ] else ...[
          // アクションボタン群 - シンプル
          Column(
            children: [
              // 位置更新ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: parkingState.isRecording ? null : onParkCar,
                  style: AppStyles.secondaryButtonStyle,
                  icon: parkingState.isRecording 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : Icon(Icons.my_location_outlined),
                  label: Text('位置を更新'),
                ),
              ),
              const SizedBox(height: 8),
              // 駐車完了ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCompleteParkingSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: AppTheme.onSecondaryColor,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.check_circle_outline),
                  label: Text('駐車完了'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

}