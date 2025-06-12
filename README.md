# 🅿️ P-Memo - 駐車位置記録アプリ

世界で最も早く、簡単に、駐車した場所を記録・発見できるFlutterアプリです。

## ✨ 主な機能

### 📍 位置情報機能
- **現在地取得**: GPS/ブラウザ位置情報を使用してリアルタイム位置表示
- **住所表示**: 緯度経度を読みやすい住所に自動変換
- **位置精度表示**: 取得した位置情報の精度レベルを表示

### 🚗 駐車管理機能
- **ワンタップ記録**: 駐車位置を簡単に記録・保存
- **駐車状態管理**: 現在の駐車状況をカードで分かりやすく表示
- **駐車時間計測**: 駐車開始からの経過時間を自動計測
- **履歴保存**: 過去の駐車記録を履歴として保存

### 🗺️ ナビゲーション機能
- **Google Maps連携**: 記録した駐車位置へのナビゲーション
- **距離・方角表示**: 現在地から駐車位置までの距離と方角を表示

### 🎨 ユーザーエクスペリエンス
- **直感的UI**: シンプルで使いやすいマテリアルデザイン
- **位置情報許可ガイド**: 初回使用時の分かりやすい説明
- **エラーハンドリング**: 位置情報取得失敗時の適切な対応
- **リフレッシュ機能**: 現在地情報の手動更新

## 🚀 起動方法

### 前提条件
- Flutter SDK (3.19.6以上)
- Dart SDK
- Web ブラウザ（Chrome, Firefox, Safari等）

### 起動手順

#### Linux/macOS

1. **リポジトリをクローン**
```bash
git clone https://github.com/markun128/vibe-parking-app.git
cd vibe-parking-app
```

2. **依存関係をインストール**
```bash
flutter pub get
```

3. **Webサーバーで起動**
```bash
flutter run -d web-server --web-port 8080
```

4. **ブラウザでアクセス**
```
http://localhost:8080
```

#### Windows

**🚀 クイックスタート（推奨）:**
```cmd
git clone https://github.com/markun128/vibe-parking-app.git
cd vibe-parking-app
scripts\run-web-portable.bat
```
※ Flutterが未インストールの場合、自動インストールオプションが表示されます

**📖 詳細セットアップ:** [WINDOWS_SETUP.md](WINDOWS_SETUP.md) を参照

**手動セットアップ:**
1. **Flutter SDK インストール**
```cmd
scripts\install-flutter-windows.bat
```

2. **環境セットアップ**
```cmd
scripts\setup-windows.bat
```

3. **Webアプリ起動**
```cmd
scripts\run-web-windows.bat
```

4. **ブラウザで自動的に開きます**
```
http://localhost:8080
```

## 🌐 対応プラットフォーム

- ✅ **Web**: Chrome, Firefox, Safari
- ✅ **Android**: 5.0 (API level 21) 以上
- ✅ **iOS**: 12.0 以上
- ✅ **macOS**: 10.14 以上
- ✅ **Windows**: 10 以上
- ✅ **Linux**: Ubuntu 18.04 以上

## 📱 使い方

1. **アプリを開く**: ブラウザで http://localhost:8080 にアクセス
2. **位置情報を許可**: ブラウザの位置情報許可ダイアログで「許可」を選択
3. **現在地を確認**: 現在地カードで位置情報が取得されていることを確認
4. **駐車位置を記録**: 「駐車位置を記録」ボタンをタップ
5. **駐車完了**: 車を移動する際に「駐車完了」ボタンをタップ

## 🛠️ 技術スタック

### フロントエンド
- **Flutter 3.19.6**: クロスプラットフォームUIフレームワーク
- **Dart**: プログラミング言語
- **Riverpod**: 状態管理
- **Material Design**: UIデザインシステム

### 位置情報サービス
- **geolocator**: GPS位置情報取得
- **geocoding**: 緯度経度と住所の相互変換
- **permission_handler**: 位置情報権限管理

### データ管理
- **shared_preferences**: ローカルデータ保存
- **flutter_riverpod**: リアクティブ状態管理

### ナビゲーション
- **url_launcher**: 外部アプリ（Google Maps）連携

## 📂 プロジェクト構成

```
lib/
├── main.dart                    # アプリエントリーポイント
├── models/
│   └── parking_location.dart   # 駐車位置データモデル
├── providers/
│   └── parking_provider.dart   # 駐車状態管理
├── screens/
│   ├── home_screen.dart        # メイン画面
│   └── settings_screen.dart    # 設定画面
├── services/
│   ├── location_service.dart   # 位置情報サービス
│   ├── geocoding_service.dart  # 住所変換サービス
│   ├── navigation_service.dart # ナビゲーションサービス
│   └── storage_service.dart    # データ保存サービス
├── theme/
│   └── app_theme.dart         # アプリテーマ設定
└── widgets/
    ├── action_buttons.dart     # アクションボタン
    ├── ads_banner.dart        # 広告バナー
    └── parking_status_card.dart # 駐車状態カード
```

## 🔧 開発・ビルド

### 開発モード

#### Web版

**Linux/macOS:**
```bash
flutter run -d web-server --web-port 8080
```

**Windows:**
```cmd
scripts\run-web-windows.bat
```

#### Android版（Docker エミュレータ）

**Linux/macOS:**
```bash
# エミュレータ起動
./scripts/run-android.sh

# 別ターミナルでADB接続
./scripts/connect-adb.sh

# Flutterアプリ実行
flutter run -d emulator-5554
```

**Windows:**
```cmd
REM エミュレータ起動
scripts\run-android.bat

REM 別コマンドプロンプトでADB接続
scripts\connect-adb.bat

REM Flutterアプリ実行
flutter run -d emulator-5554
```

### プロダクションビルド
```bash
# Web用
flutter build web

# Android用
flutter build apk

# iOS用
flutter build ios
```

### テスト実行
```bash
flutter test
```

## 🐳 Docker Android エミュレータ

Dockerを使用してAndroidエミュレータを実行できます。

### 前提条件
- Docker
- Docker Compose
- KVM対応（Linux）/ Hyper-V対応（Windows）

### 使用方法

#### Linux/macOS
1. **エミュレータ起動**
```bash
./scripts/run-android.sh
```

2. **ADB接続**（別ターミナルで）
```bash
./scripts/connect-adb.sh
```

3. **Flutterアプリ実行**
```bash
flutter run -d emulator-5554
```

#### Windows
1. **エミュレータ起動**
```cmd
scripts\run-android.bat
```

2. **ADB接続**（別コマンドプロンプトで）
```cmd
scripts\connect-adb.bat
```

3. **Flutterアプリ実行**
```cmd
flutter run -d emulator-5554
```

### Docker構成
- **ベースイメージ**: Ubuntu 22.04
- **Android SDK**: 最新版
- **Flutter**: 3.19.6
- **エミュレータ**: Pixel 6 API 33
- **仮想化**: KVM加速対応

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🤝 コントリビューション

プルリクエストやイシューの投稿を歓迎します！

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📞 サポート

問題や質問がある場合は、[Issues](https://github.com/markun128/vibe-parking-app/issues)でお知らせください。

---

**P-Memo** - あなたの駐車体験を革新します 🚗✨
