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
          // 駐車位置記録ボタン
          _buildMainActionButton(
            context: context,
            onPressed: parkingState.isRecording ? null : onParkCar,
            icon: parkingState.isRecording 
                ? Icons.location_searching 
                : Icons.local_parking,
            label: parkingState.isRecording 
                ? '位置情報取得中...' 
                : '駐車位置を記録',
            backgroundColor: AppTheme.primaryColor,
            isLoading: parkingState.isRecording,
          ),
        ] else ...[
          // アクションボタン群
          Row(
            children: [
              // 位置更新ボタン
              Expanded(
                child: _buildNeuomorphicButton(
                  context: context,
                  onPressed: parkingState.isRecording ? null : onParkCar,
                  icon: Icons.gps_fixed,
                  label: '位置更新',
                  color: const Color(0xFFDC2626),
                  isLoading: parkingState.isRecording,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 駐車完了ボタン
              Expanded(
                child: _buildNeuomorphicButton(
                  context: context,
                  onPressed: onCompleteParkingSession,
                  icon: Icons.check_circle,
                  label: '駐車完了',
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMainActionButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Icon(
                icon,
                size: 32,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            
            const SizedBox(width: 12),
            
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
    );
  }


  // ニューモーフィズムボタン
  Widget _buildNeuomorphicButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isLoading = false,
  }) {
    final isEnabled = onPressed != null && !isLoading;
    final effectiveColor = isEnabled ? color : Colors.grey.shade400;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: effectiveColor,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 32,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}