import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/parking_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ads_banner.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isProAsync = ref.watch(isProUserProvider);
    final showAdsAsync = ref.watch(showAdsProvider);
    final historyAsync = ref.watch(parkingHistoryProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('設定'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRO版アップグレードセクション
                  isProAsync.when(
                    data: (isPro) => isPro
                        ? _buildProStatusCard()
                        : _buildUpgradeCard(),
                    loading: () => const _LoadingCard(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // アプリ設定セクション
                  _buildSectionTitle('アプリ設定'),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: 'タイマー通知',
                      subtitle: isProAsync.value == true 
                          ? '駐車時間の通知を設定' 
                          : 'PRO版限定機能',
                      trailing: isProAsync.value == true 
                          ? Switch(
                              value: true,
                              onChanged: (value) {
                                // タイマー通知設定の切り替え
                              },
                            )
                          : const Icon(Icons.lock, color: Colors.grey),
                      onTap: isProAsync.value == true 
                          ? () => _showTimerSettings()
                          : null,
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.camera_alt,
                      title: '写真保存',
                      subtitle: isProAsync.value == true 
                          ? '駐車位置の写真を保存' 
                          : 'PRO版限定機能',
                      trailing: isProAsync.value == true 
                          ? Switch(
                              value: true,
                              onChanged: (value) {
                                // 写真保存設定の切り替え
                              },
                            )
                          : const Icon(Icons.lock, color: Colors.grey),
                      onTap: isProAsync.value == true 
                          ? () => _showPhotoSettings()
                          : null,
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  
                  // データ管理セクション
                  _buildSectionTitle('データ管理'),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    historyAsync.when(
                      data: (history) => _buildSettingItem(
                        icon: Icons.history,
                        title: '駐車履歴',
                        subtitle: '${history.length}件の記録',
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showParkingHistory(history),
                      ),
                      loading: () => _buildSettingItem(
                        icon: Icons.history,
                        title: '駐車履歴',
                        subtitle: '読み込み中...',
                        trailing: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => _buildSettingItem(
                        icon: Icons.history,
                        title: '駐車履歴',
                        subtitle: '読み込みエラー',
                        trailing: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.delete_forever,
                      title: 'データを全て削除',
                      subtitle: '駐車履歴と設定をリセット',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showClearDataDialog(),
                      textColor: Colors.red,
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // アプリ情報セクション
                  _buildSectionTitle('アプリ情報'),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSettingItem(
                      icon: Icons.info,
                      title: 'バージョン',
                      subtitle: '1.0.0',
                      trailing: const SizedBox.shrink(),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.privacy_tip,
                      title: 'プライバシーポリシー',
                      subtitle: 'データの取り扱いについて',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showPrivacyPolicy(),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.star,
                      title: 'アプリを評価',
                      subtitle: 'App Storeでレビューする',
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _openAppStore(),
                    ),
                  ]),
                  
                  const SizedBox(height: 32),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(
        icon,
        color: textColor ?? AppTheme.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 64,
      endIndent: 20,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildProStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'PRO版ユーザー',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'すべての機能をご利用いただけます',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.upgrade,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  'PRO版にアップグレード',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• 広告なし\n• 写真保存機能\n• タイマー通知\n• 履歴10件まで保存',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleUpgrade(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '¥400でアップグレード',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpgrade() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PRO版購入'),
        content: const Text('この機能は実装されていません。\n実際のアプリではApp Store購入が実行されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTimerSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('タイマー設定'),
        content: const Text('タイマー通知の設定画面です。\n実際のアプリでは通知時間を設定できます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPhotoSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('写真設定'),
        content: const Text('写真保存の設定画面です。\n実際のアプリでは写真の品質などを設定できます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showParkingHistory(List history) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('駐車履歴')),
          body: history.isEmpty
              ? const Center(
                  child: Text('駐車履歴がありません'),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final location = history[index];
                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text('${location.timestamp.month}/${location.timestamp.day} ${location.timestamp.hour}:${location.timestamp.minute.toString().padLeft(2, '0')}'),
                      subtitle: Text('${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}'),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ削除'),
        content: const Text('すべてのデータを削除しますか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(storageServiceProvider).clearAllData();
              ref.invalidate(parkingProvider);
              ref.invalidate(parkingHistoryProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('データを削除しました')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プライバシーポリシー'),
        content: const Text('プライバシーポリシーの詳細ページです。\n実際のアプリでは利用規約とプライバシーポリシーが表示されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openAppStore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アプリ評価'),
        content: const Text('App Storeの評価画面に移動します。\n実際のアプリではレビュー画面が開きます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}