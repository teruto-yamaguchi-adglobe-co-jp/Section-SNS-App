# Flutter 開発環境セットアップ手順

このドキュメントでは、Windows環境でFlutter開発を始めるための手順を説明します。

## 前提条件

以下のツールをインストールしてください：

### 1. Git for Windows
- [Git for Windows](https://git-scm.com/download/win) から最新版をダウンロードしてインストール

### 2. Visual Studio Code
- [VS Code](https://code.visualstudio.com/) をダウンロードしてインストール

## Flutterのインストール手順

### 1. Flutter拡張機能のインストール
1. VS Codeを起動
2. [Flutter拡張機能のマーケットプレイスページ](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)にアクセス
3. 「インストール」をクリック
   - Dart拡張機能も自動的にインストールされます

### 2. Flutter SDKのインストール
1. VS Codeでコマンドパレットを開く（`Ctrl + Shift + P`）
2. `Flutter: New Project` を入力して選択
3. 「SDK をダウンロード」を選択
4. Flutter SDKをインストールするフォルダを選択
5. 「Clone Flutter」をクリック
6. ダウンロード完了後、「SDK を PATH に追加」をクリック
7. VS Codeを再起動

## 動作確認

### 新しいFlutterプロジェクトの作成
1. コマンドパレットを開く（`Ctrl + Shift + P`）
2. `Flutter: New Project` を選択
3. 「Application」テンプレートを選択
4. プロジェクトの保存場所を選択
5. プロジェクト名を入力（例：`my_app`）

### Webブラウザでの実行
1. コマンドパレットで `Flutter: Select Device` を選択
2. 「Chrome」を選択
3. `F5` キーを押してデバッグ実行
4. Chromeブラウザでアプリが起動します

### ホットリロードの確認
1. `lib/main.dart` を開く
2. `_incrementCounter` メソッド内の `_counter++` を `_counter--` に変更
3. 保存すると自動的にアプリが更新されます（ホットリロード）
4. 状態を保ったままコードの変更が反映されることを確認

## トラブルシューティング

インストール中に問題が発生した場合は、以下を確認してください：

- すべてのターミナルウィンドウを閉じてVS Codeを再起動
- Gitが正しくインストールされているか確認（コマンドプロンプトで `git --version`）
- PATH環境変数にFlutter SDKが追加されているか確認（コマンドプロンプトで `flutter --version`）

## 次のステップ

Android開発環境のセットアップに進みます:
- [SETUP-02.md](./SETUP-02.md) - Android Emulatorのセットアップ

## リファレンス
- https://docs.flutter.dev/get-started/quick
