# Android Emulator セットアップ手順

このドキュメントでは、Windows環境でAndroid開発のためのエミュレータをセットアップする手順を説明します。

## 前提条件

- Flutter SDKがインストール済みであること（[SETUP-01.md](./SETUP-01.md)を参照）
- 十分なディスク容量（推奨: 10GB以上の空き容量）

## Android Studioのインストール

### 1. Android Studioのダウンロードとインストール

1. [Android Studio](https://developer.android.com/studio)の公式サイトにアクセス
2. 最新の安定版をダウンロード
3. インストーラーを実行し、デフォルト設定でインストール
4. 初回起動時にセットアップウィザードが表示されるので、指示に従って進める

### 2. Android SDKとツールのインストール

#### SDK Managerの起動

- **「Android Studio へようこそ」ダイアログが表示されている場合:**
  1. 「その他のアクション」ボタン（More Actionsボタン）をクリック
  2. ドロップダウンメニューから「SDK マネージャー」を選択

- **プロジェクトを開いている場合:**
  1. メニューバーから「Tools」→「SDK Manager」を選択

#### SDKプラットフォームのインストール

1. 「SDK プラットフォーム」タブを開く
2. **API レベル 36** のエントリを確認
3. ステータス列に「更新プログラムが利用可能」または「インストールされていません」と表示されている場合:
   - チェックボックスを選択
   - 「適用」をクリック
   - 「変更の確認」ダイアログで「OK」をクリック
   - インストール完了後、「完了」をクリック

#### SDKツールのインストール

1. 「SDK ツール」タブに切り替え
2. 以下のツールが選択されていることを確認:
   - **Android SDK Build-Tools**
   - **Android SDK Command-line Tools**
   - **Android Emulator**
   - **Android SDK Platform-Tools**
3. いずれかが「更新プログラムが利用可能」または「インストールされていません」の場合:
   - 必要なツールのチェックボックスを選択
   - 「適用」をクリック
   - 「変更の確認」ダイアログで「OK」をクリック
   - インストール完了後、「完了」をクリック

### 3. Androidライセンスへの同意

1. ターミナル（PowerShellまたはコマンドプロンプト）を開く
2. 以下のコマンドを実行:

```bash
flutter doctor --android-licenses
```

3. 各ライセンスの内容を確認し、`y`（yes）を入力して同意
4. すべてのライセンスに同意すると、以下のメッセージが表示されます:

```
All SDK package licenses accepted.
```

## Android Emulatorのセットアップ

### 1. VMアクセラレーションの有効化

Windows環境では、エミュレータのパフォーマンス向上のために仮想化機能を有効にします。

#### BIOSでの設定確認

1. PCを再起動し、BIOS/UEFI設定画面に入る（通常はF2、Del、F12などのキーを押す）
2. 「Virtualization Technology」または「Intel VT-x」/「AMD-V」を探す
3. 有効（Enabled）に設定
4. 設定を保存してBIOSを終了

#### Windowsの機能確認

1. 「Windowsの機能の有効化または無効化」を開く
2. 以下を確認:
   - **「Hyper-V」が無効**になっていること（WSL2を使用している場合は有効でも可）
   - **「Windows ハイパーバイザー プラットフォーム」が有効**になっていること

### 2. 新しいエミュレータの作成

#### Device Managerの起動

- **「Android Studio へようこそ」ダイアログが表示されている場合:**
  1. 「その他のアクション」ボタンをクリック
  2. 「仮想デバイス マネージャー」を選択

- **プロジェクトを開いている場合:**
  1. メニューバーから「Tools」→「Device Manager」を選択

#### 仮想デバイスの作成

1. **「仮想デバイスの作成」ボタン（+アイコン）をクリック**

2. **デバイス定義の選択:**
   - 「Phone」または「Tablet」を選択
   - 推奨: **Pixel 7** または **Pixel 8**
   - 「Next」をクリック

3. **システムイメージの選択:**
   - お使いのPCのアーキテクチャに応じて選択:
     - **x64デバイスの場合:** x86イメージ
     - **Arm64デバイスの場合:** ARMイメージ
   - 推奨: 最新の安定版Android（例: **Android 14.0 (API 34)** または **Android 15.0 (API 35)**）
   - システムイメージ名の左側に**ダウンロードアイコン**がある場合はクリック
   - ダウンロード完了後、「Finish」をクリック
   - システムイメージを選択して「Next」をクリック

4. **詳細設定の調整:**
   - 上部のタブバーで「**詳細設定**」（Advanced Settings）をクリック
   - 「**エミュレートされたパフォーマンス**」（Emulated Performance）までスクロール
   - 「**グラフィック アクセラレーション**」（Graphics）ドロップダウンメニューから「**Hardware - GLES 2.0**」を選択
     - これによりハードウェアアクセラレーションが有効になり、レンダリングパフォーマンスが向上します

5. **設定の確認:**
   - 仮想デバイスの名前を確認（必要に応じて変更可能）
   - 「Finish」をクリック

### 3. エミュレータの起動と確認

#### GUIから起動（Android Studio）

1. **Device Manager**ダイアログで、作成した仮想デバイスの右側にある**実行アイコン（▶）**をクリック
2. エミュレータが起動し、選択したAndroid OSバージョンのホーム画面が表示されます
3. 初回起動時は起動に数分かかる場合があります

#### コマンドラインから起動

Android Studioの画面から起動できない場合や、コマンドラインから直接起動したい場合は以下の手順を実行します。

##### 1. 環境変数の設定

1. Android StudioのSDK Managerを開く
2. SDK Locationのパスをコピー（例: `C:\Users\<ユーザー名>\AppData\Local\Android\Sdk`）
3. 環境変数に以下を追加:
   - 「設定」→「システム」→「バージョン情報」→「システムの詳細設定」を開く
   - 「環境変数」をクリック
   - 「Path」を選択し、「編集」をクリック
   - 「新規」をクリックし、`<SDK Location>\emulator`を追加（例: `C:\Users\<ユーザー名>\AppData\Local\Android\Sdk\emulator`）
   - 「OK」をクリックして保存
4. PCを再起動

##### 2. 環境変数の確認

ターミナル（PowerShellまたはコマンドプロンプト）を開いて以下を実行:

```bash
emulator -version
```

Android Emulatorのバージョン情報が表示されればパスが正しく設定されています。

##### 3. 利用可能な仮想デバイスの確認

```bash
emulator -list-avds
```

作成済みの仮想デバイス名の一覧が表示されます。

##### 4. エミュレータの起動

```bash
emulator -avd <仮想デバイス名>
```

例:
```bash
emulator -avd Pixel_7_API_34
```

エミュレータが起動し、選択したAndroid OSバージョンのホーム画面が表示されます。

## セットアップの検証

### 1. ツールチェーンの確認

ターミナルで以下のコマンドを実行:

```bash
flutter doctor
```

期待される出力:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, x.x.x, ...)
[✓] Android toolchain - develop for Android devices (Android SDK version xx.x.x)
[✓] Chrome - develop for the web
[✓] Visual Studio Code (version x.x.x)
[✓] Connected device (x available)
[✓] Network resources
```

エラーや警告が表示された場合は、該当箇所の指示に従って修正してください。

### 2. デバイスの確認

ターミナルで以下のコマンドを実行:

```bash
flutter emulators
```

期待される出力例:

```
2 available emulators:

Pixel_7_API_34 • Pixel 7 API 34 • Google • android

To run an emulator, run 'flutter emulators --launch <emulator id>'.
```

エミュレータが起動している状態で以下を実行:

```bash
flutter devices
```

期待される出力例:

```
2 connected devices:

sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64    • Android 14 (API 34) (emulator)
Chrome (web)                 • chrome        • web-javascript • Google Chrome 120.0.6099.109
```

### 3. Flutter アプリの実行テスト

1. テスト用のFlutterプロジェクトを作成（既存のプロジェクトでも可）:

```bash
flutter create test_app
cd test_app
```

2. エミュレータが起動していることを確認

3. アプリを実行:

```bash
flutter run
```

4. アプリがエミュレータ上で正常に起動することを確認

## トラブルシューティング

### エミュレータが起動しない

- **Android StudioのGUIから起動できない場合:**
  - コマンドラインから起動を試してください（上記の「コマンドラインから起動」セクションを参照）
  - `emulator -list-avds`で仮想デバイスが表示されるか確認
  - `emulator -avd <仮想デバイス名>`で起動を試行

- **HAXM（Intel Hardware Accelerated Execution Manager）のインストール:**
  - Android Studioの「SDK Manager」→「SDK Tools」タブ
  - 「Intel x86 Emulator Accelerator (HAXM installer)」を選択してインストール

- **Hyper-Vとの競合:**
  - Hyper-Vが有効な場合、Intel HAXMと競合します
  - 「Windowsの機能」でHyper-Vを無効化するか、Android EmulatorでHyper-Vモードを使用

### エミュレータの動作が遅い

- グラフィックアクセラレーションが「Hardware」に設定されているか確認
- RAMの割り当てを増やす（Device Managerで仮想デバイスを編集）
- 不要なバックグラウンドアプリを終了

### `flutter doctor`でエラーが表示される

- **Android licenses not accepted:**
  ```bash
  flutter doctor --android-licenses
  ```
  を実行してすべてのライセンスに同意

- **cmdline-tools component is missing:**
  - Android Studioの「SDK Manager」→「SDK Tools」タブ
  - 「Android SDK Command-line Tools」をインストール

### エミュレータがflutter devicesに表示されない

1. エミュレータが起動しているか確認
2. 以下のコマンドでADBを再起動:

```bash
adb kill-server
adb start-server
```

3. 再度`flutter devices`を実行

## VS Codeでの使用

### 1. エミュレータの起動

- コマンドパレット（`Ctrl + Shift + P`）を開く
- 「Flutter: Launch Emulator」を入力して選択
- 使用するエミュレータを選択

### 2. デバイスの選択

- VS Codeの右下にある「デバイス選択」をクリック
- 起動中のエミュレータを選択

### 3. アプリの実行

- `F5`キーを押してデバッグ実行
- または、`Ctrl + F5`でデバッグなしで実行

## 次のステップ

これでAndroid開発環境のセットアップが完了しました。次はアプリケーションを起動してみましょう:
- [SETUP-03.md](./SETUP-03.md) - アプリケーション起動手順

セットアップ全体の概要に戻る:
- [README.md](./README.md) - ドキュメントトップページ

## リファレンス
- https://docs.flutter.dev/platform-integration/android/setup