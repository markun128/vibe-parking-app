# P-Memo - 駐車場記録アプリ

## Google Places API設定方法

近くの駐車場機能を使用するには、Google Places APIキーの設定が必要です。

### 1. Google Cloud Console でAPIキーを取得

1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. プロジェクトを作成または選択
3. 「APIとサービス」→「認証情報」でAPIキーを作成
4. Places API、Maps JavaScript API、Geocoding APIを有効化

### 2. APIキーの設定

`lib/services/parking_search_service.dart` ファイルの12行目：

```dart
static const String _placesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';
```

を以下のように変更：

```dart
static const String _placesApiKey = 'あなたのAPIキー';
```

### 3. APIキーの制限設定（推奨）

Google Cloud Consoleで以下の制限を設定することを推奨します：

- **アプリケーションの制限**: HTTPリファラー
- **API制限**: Places API、Maps JavaScript API、Geocoding API

## 機能

- 駐車位置の記録・管理
- 現在地の住所表示
- 半径1km以内の近くの駐車場検索
- 駐車時間の自動計測
- Google Mapsとの連携

## 起動方法

```bash
flutter run -d web-server --web-port 8081
```

アプリは http://localhost:8081 でアクセスできます。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
