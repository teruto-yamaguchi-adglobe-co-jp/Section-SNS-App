# Flutter アプリケーション起動手順

このドキュメントでは、flutter_sns_appの起動手順を説明します。

## 前提条件

- Flutter SDKとAndroid Emulatorがセットアップ済みであること
  - Flutter SDKのセットアップ: [SETUP-01.md](./SETUP-01.md)
  - Android Emulatorのセットアップ: [SETUP-02.md](./SETUP-02.md)

## コマンドラインからの起動手順

### 1. エミュレータの起動

まず、Androidエミュレータを起動します。

```bash
# 利用可能なエミュレータを確認
emulator -list-avds

# エミュレータを起動（例: Pixel_7_API_34）
emulator -avd Pixel_7_API_34
```

または、Android StudioのDevice Managerから起動することもできます。

### 2. プロジェクトのクリーンアップ（初回起動時または問題が発生した場合）

```bash
flutter clean
```

このコマンドは以下をクリーンアップします:
- `build/` ディレクトリ
- `.dart_tool/` ディレクトリ
- プラットフォーム固有の一時ファイル

### 3. 依存関係のインストール

```bash
flutter pub get
```

このコマンドは `pubspec.yaml` に定義されたすべての依存パッケージをダウンロードします。

### 4. エミュレータの確認

エミュレータが正しく認識されているか確認します。

```bash
flutter devices
```

期待される出力例:
```
2 connected devices:

sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64    • Android 14 (API 34) (emulator)
Chrome (web)                 • chrome        • web-javascript • Google Chrome 120.0.6099.109
```

### 5. アプリの起動

```bash
flutter run
```

このコマンドは以下を実行します:
1. Gradleタスク `assembleDebug` を実行してAPKをビルド
2. APKをエミュレータにインストール
3. アプリを起動

初回起動時は、ビルドに数分かかる場合があります。

### 6. 起動後の操作

アプリが起動すると、以下のコマンドが使用できます:

```
r  Hot reload（ホットリロード）- コードの変更を即座に反映
R  Hot restart（ホットリスタート）- アプリを再起動
h  利用可能なコマンド一覧を表示
d  Detach（アプリを終了せずにflutter runを終了）
c  画面をクリア
q  Quit（アプリを終了）
```

## VS Codeからの起動手順

VS Codeから起動する場合は、以下の手順を実行します。

### 1. エミュレータの起動

1. コマンドパレットを開く（`Ctrl + Shift + P`）
2. `Flutter: Launch Emulator` を入力して選択
3. 使用するエミュレータを選択

または、コマンドラインから起動することもできます。

### 2. デバイスの選択

1. VS Codeの右下にある「デバイス選択」をクリック
2. 起動中のエミュレータを選択

### 3. アプリの起動

以下のいずれかの方法でアプリを起動します:

- `F5` キーを押してデバッグ実行
- `Ctrl + F5` でデバッグなしで実行
- デバッグパネルから「Run and Debug」をクリック

## トラブルシューティング

### エミュレータがflutter devicesに表示されない

1. エミュレータが起動しているか確認
2. ADBを再起動:

```bash
adb kill-server
adb start-server
```

3. 再度 `flutter devices` を実行

### ビルドエラーが発生する

1. プロジェクトをクリーンアップ:

```bash
flutter clean
flutter pub get
```

2. Gradleキャッシュをクリア（Windowsの場合）:

```bash
cd android
.\gradlew clean
cd ..
```

3. 再度 `flutter run` を実行

### ホットリロードが動作しない

1. `R` キーを押してホットリスタートを試す
2. アプリを再起動（`q` で終了後、再度 `flutter run`）

### パフォーマンスに関する警告が表示される

```
I/Choreographer: Skipped XX frames! The application may be doing too much work on its main thread.
```

このメッセージは、初回起動時やエミュレータの性能によって表示されることがあります。通常、アプリの動作には影響ありません。

## 次のステップ

これでアプリケーションの起動が完了しました。開発を進めるにあたり、以下のリソースを参考にしてください:
- [README.md](./README.md) - ドキュメントトップページに戻る

## 参考情報

### Flutter DevTools

アプリ起動時に表示されるURLからFlutter DevToolsにアクセスできます:

```
The Flutter DevTools debugger and profiler on sdk gphone64 x86 64 is available at:
http://127.0.0.1:9101?uri=http://127.0.0.1:53462/...
```

DevToolsでは以下が可能です:
- パフォーマンスプロファイリング
- ウィジェットツリーの検査
- ネットワークリクエストの監視
- メモリ使用状況の確認
