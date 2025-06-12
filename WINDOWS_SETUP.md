# 🪟 Windows セットアップガイド

P-MemoアプリをWindowsで開発・実行するための詳細ガイドです。

## 🚀 クイックスタート（自動インストール）

### 方法1: 完全自動セットアップ
```cmd
git clone https://github.com/markun128/vibe-parking-app.git
cd vibe-parking-app
scripts\install-flutter-windows.bat
scripts\run-web-portable.bat
```

### 方法2: ポータブル実行
```cmd
git clone https://github.com/markun128/vibe-parking-app.git
cd vibe-parking-app
scripts\run-web-portable.bat
```
※ Flutterが見つからない場合、自動でインストールオプションが表示されます

## 📋 手動セットアップ手順

### 1. 前提条件の確認

#### Git のインストール
```cmd
git --version
```
インストールされていない場合: https://git-scm.com/download/win

#### PowerShell の確認
```cmd
powershell -Command "Get-Host"
```
Windows 10/11では標準で利用可能

### 2. Flutter SDK のインストール

#### 自動インストール（推奨）
```cmd
scripts\install-flutter-windows.bat
```

#### 手動インストール
1. https://docs.flutter.dev/get-started/install/windows からダウンロード
2. `C:\flutter` に展開
3. システム環境変数 PATH に `C:\flutter\bin` を追加
4. コマンドプロンプトを再起動

### 3. Flutter の設定確認
```cmd
flutter doctor
```

## 🌐 Web アプリケーションの実行

### シンプル実行
```cmd
scripts\run-web-portable.bat
```

### 手動実行
```cmd
flutter pub get
flutter config --enable-web
flutter run -d chrome --web-port 8080
```

## 📱 Android 開発（Docker使用）

### Docker Desktop のインストール
1. https://www.docker.com/products/docker-desktop からダウンロード
2. WSL 2 バックエンドを有効化
3. Hyper-V を有効化（可能な場合）

### Android エミュレータの実行
```cmd
REM エミュレータ起動
scripts\run-android.bat

REM 別ウィンドウでADB接続
scripts\connect-adb.bat

REM Flutterアプリ実行
flutter run -d emulator-5554
```

## 🛠️ トラブルシューティング

### Flutter が見つからない
```
❌ 'flutter' is not recognized as an internal or external command
```

**解決方法:**
1. `scripts\install-flutter-windows.bat` を実行
2. またはPATH環境変数に `C:\flutter\bin` を追加
3. コマンドプロンプトを再起動

### PATH環境変数の手動設定
1. `Win + R` → `sysdm.cpl` → Enter
2. 「環境変数」をクリック
3. ユーザー環境変数の「Path」を選択 → 「編集」
4. 「新規」→ `C:\flutter\bin` を追加
5. 「OK」で全て閉じる
6. コマンドプロンプトを再起動

### Docker エラー
```
❌ Docker is not running
```

**解決方法:**
1. Docker Desktop を起動
2. WSL 2 統合が有効になっていることを確認
3. 仮想化が BIOS で有効になっていることを確認

### ポート使用中エラー
```
❌ Port 8080 is already in use
```

**解決方法:**
```cmd
netstat -ano | findstr :8080
taskkill /PID <プロセスID> /F
```

または別のポートを使用:
```cmd
flutter run -d chrome --web-port 8081
```

## 📁 ファイル構成

```
scripts/
├── install-flutter-windows.bat    # Flutter SDK 自動インストール
├── setup-windows.bat             # 開発環境セットアップ
├── run-web-windows.bat           # Web アプリ起動（標準）
├── run-web-portable.bat          # Web アプリ起動（ポータブル）
├── run-android.bat               # Android エミュレータ起動
└── connect-adb.bat               # ADB 接続
```

## 🎯 開発のヒント

### VSCode 拡張機能（推奨）
- Flutter
- Dart
- Docker

### パフォーマンス最適化
```cmd
REM リリースモードでビルド
flutter build web --release

REM キャッシュクリア
flutter clean
flutter pub get
```

### デバッグモード
```cmd
REM 詳細ログ付きで実行
flutter run -d chrome --web-port 8080 -v
```

## 🆘 サポート

問題が発生した場合:

1. **Flutter Doctor の実行**
   ```cmd
   flutter doctor -v
   ```

2. **キャッシュクリア**
   ```cmd
   flutter clean
   flutter pub get
   ```

3. **Issue 作成**
   https://github.com/markun128/vibe-parking-app/issues

## 🎉 成功の確認

以下が表示されれば成功です:
```
🚀 Starting P-Memo web application...
📱 App will be available at: http://localhost:8080
```

ブラウザで http://localhost:8080 にアクセスして P-Memo アプリが表示されることを確認してください！