# Supabaseのセットアップと導入

このドキュメントでは、Flutter SNS AppにSupabaseを導入し、カウンターデータをSupabaseのデータベースに保存する手順を説明します。

## 📋 目次

1. [Supabaseとは](#supabaseとは)
2. [Supabaseプロジェクトの作成](#supabaseプロジェクトの作成)
3. [データベーステーブルの作成](#データベーステーブルの作成)
4. [環境変数の設定](#環境変数の設定)
5. [パッケージのインストール](#パッケージのインストール)
6. [動作確認](#動作確認)
7. [トラブルシューティング](#トラブルシューティング)

---

## Supabaseとは

Supabaseは、Firebase代替のオープンソースBaaS（Backend as a Service）プラットフォームです。
PostgreSQLベースのデータベース、認証、ストレージ、リアルタイム同期などの機能を提供します。

### 主な特徴

- PostgreSQLベースのデータベース
- リアルタイムデータ同期
- ユーザー認証機能
- ストレージ機能
- 無料プランあり

---

## Supabaseプロジェクトの作成

### 1. Supabaseアカウントの作成

1. [Supabase公式サイト](https://supabase.com/)にアクセス
2. 右上の「Start your project」または「Sign up」をクリック
3. GitHubアカウントでサインアップ（推奨）または、メールアドレスでサインアップ

### 2. 新規プロジェクトの作成

1. ダッシュボードにログイン後、「New Project」をクリック
2. プロジェクト情報を入力:
   ```
   Name: flutter-sns-app (任意の名前)
   Database Password: 強力なパスワードを生成・保存
   Region: Northeast Asia (Tokyo) (日本の場合)
   Pricing Plan: Free (開発用)
   ```
3. 「Create new project」をクリック
4. プロジェクトの作成完了まで1-2分待機

### 3. APIキーの確認

プロジェクトが作成されたら、APIキーを確認します:

1. 左サイドバーの「Settings」(⚙️)をクリック
2. 「API」セクションをクリック
3. 以下の情報をコピーして保存:
   - **Project URL** (例: `https://xxxxxxxxxxxxx.supabase.co`)
   - **anon public** (公開API キー)

> ⚠️ **重要**: `service_role` キーは使用しないでください。これは完全な管理者権限を持つため、クライアント側では使用できません。

---

## データベーステーブルの作成

カウンターデータを保存するためのテーブルを作成します。

### 1. SQL Editorでテーブルを作成

1. 左サイドバーの「SQL Editor」をクリック
2. 「New query」をクリック
3. 以下のSQLを入力:

```sql
-- カウンターテーブルの作成
CREATE TABLE counters (
  id INTEGER PRIMARY KEY,
  value INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 初期データの挿入
INSERT INTO counters (id, value) VALUES (1, 0);

-- 更新時に updated_at を自動更新するトリガー
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_counters_updated_at
  BEFORE UPDATE ON counters
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

4. 「Run」(または Ctrl+Enter)をクリックして実行
5. 「Success. No rows returned」と表示されれば成功

### 2. テーブルの確認

1. 左サイドバーの「Table Editor」をクリック
2. `counters` テーブルが表示されることを確認
3. テーブルを開いて、`id=1, value=0` のレコードが存在することを確認

### 3. Row Level Security (RLS)の設定

開発初期段階では、RLSを無効化するか、全アクセスを許可します:

#### 方法1: RLSを無効化（開発環境のみ推奨）

```sql
ALTER TABLE counters DISABLE ROW LEVEL SECURITY;
```

#### 方法2: 全アクセスを許可（推奨）

```sql
-- RLSを有効化
ALTER TABLE counters ENABLE ROW LEVEL SECURITY;

-- すべてのユーザーに読み取り権限を付与
CREATE POLICY "Allow public read access"
  ON counters FOR SELECT
  TO public
  USING (true);

-- すべてのユーザーに更新権限を付与
CREATE POLICY "Allow public update access"
  ON counters FOR UPDATE
  TO public
  USING (true)
  WITH CHECK (true);

-- すべてのユーザーに挿入権限を付与
CREATE POLICY "Allow public insert access"
  ON counters FOR INSERT
  TO public
  WITH CHECK (true);
```

> 💡 **本番環境では**: 認証されたユーザーのみがアクセスできるように、適切なRLSポリシーを設定してください。

---

## 環境変数の設定

### 1. .envファイルの作成

プロジェクトのルートディレクトリに `.env` ファイルを作成します:

```bash
# プロジェクトルート (flutter_sns_app/) で実行
# 既に .env.example ファイルが存在するため、コピーして使用
cp .env.example .env
```

Windows の場合:
```bash
copy .env.example .env
```

### 2. .envファイルの編集

`.env` ファイルを開き、Supabaseの情報を入力します:

```env
# Supabase Configuration
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

- `SUPABASE_URL`: Supabaseダッシュボードの Settings > API > Project URL
- `SUPABASE_ANON_KEY`: Supabaseダッシュボードの Settings > API > anon public

### 3. .gitignoreの確認

`.env` ファイルが `.gitignore` に含まれていることを確認します（既に設定済み）:

```gitignore
# Environment variables
.env
.env.local
.env.*.local
```

> ⚠️ **重要**: `.env` ファイルは絶対にGitにコミットしないでください。APIキーが漏洩するとセキュリティリスクになります。

---

## パッケージのインストール

### 1. 依存関係の確認

`pubspec.yaml` に以下のパッケージが追加されていることを確認します（既に設定済み）:

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8

  # Supabase client for Flutter
  supabase_flutter: ^2.9.3

  # Environment variables
  flutter_dotenv: ^5.2.1

flutter:
  uses-material-design: true

  # .envファイルをアセットとして追加
  assets:
    - .env
```

### 2. パッケージのインストール

ターミナルで以下のコマンドを実行します:

```bash
flutter pub get
```

実行結果:
```
Running "flutter pub get" in flutter_sns_app...
Resolving dependencies...
+ supabase_flutter 2.9.3
+ flutter_dotenv 5.2.1
...
Got dependencies!
```

---

## 動作確認

### 1. アプリケーションの起動

```bash
flutter run
```

または、VS Codeのデバッグ機能（F5）でアプリを起動します。

### 2. カウンター機能のテスト

1. アプリが起動し、ローディングインジケーターが表示される
2. データ読み込み後、カウンター値（初期値: 0）が表示される
3. 「+」ボタンをクリックしてカウンターを増やす
4. アプリを完全に終了（再起動）する
5. 再度アプリを起動し、カウンター値が保持されていることを確認

### 3. Supabaseダッシュボードでの確認

1. Supabaseの「Table Editor」を開く
2. `counters` テーブルを選択
3. `value` カラムが、アプリで増やした値と一致していることを確認
4. `updated_at` が最新の日時になっていることを確認

---

## トラブルシューティング

### エラー: "Unable to load asset: .env"

**原因**: `.env` ファイルが存在しないか、`pubspec.yaml` のassetsに追加されていない

**解決方法**:
1. プロジェクトルートに `.env` ファイルが存在するか確認
2. `pubspec.yaml` の `assets` セクションに `- .env` が含まれているか確認
3. `flutter pub get` を再実行
4. アプリを再起動

### エラー: "Invalid API key"

**原因**: `.env` ファイルのAPIキーが間違っている

**解決方法**:
1. Supabaseダッシュボードで Settings > API を開く
2. Project URL と anon public キーを再度コピー
3. `.env` ファイルを更新
4. アプリを完全に再起動（ホットリロードでは反映されません）

### エラー: "Row Level Security policy violation"

**原因**: RLSが有効だが、適切なポリシーが設定されていない

**解決方法**:
1. Supabaseの SQL Editor を開く
2. [Row Level Security (RLS)の設定](#3-row-level-security-rlsの設定)のSQLを実行
3. または、開発環境では `ALTER TABLE counters DISABLE ROW LEVEL SECURITY;` を実行

### エラー: "relation 'counters' does not exist"

**原因**: `counters` テーブルが作成されていない

**解決方法**:
1. Supabaseの SQL Editor を開く
2. [データベーステーブルの作成](#データベーステーブルの作成)のSQLを実行

### カウンター値が保存されない

**原因**: ネットワークエラーまたはSupabaseの接続問題

**解決方法**:
1. インターネット接続を確認
2. Supabaseダッシュボードにアクセスできるか確認
3. `.env` の `SUPABASE_URL` が正しいか確認
4. アプリのエラーメッセージ（SnackBar）を確認

### ローディングが終わらない

**原因**: Supabaseへの接続がタイムアウトしている

**解決方法**:
1. ファイアウォールやプロキシ設定を確認
2. Supabaseのステータスページ（https://status.supabase.com/）を確認
3. デバッグコンソールでエラーメッセージを確認
4. `lib/main.dart` の `_loadCounter()` メソッドに `print(e)` を追加してエラー詳細を確認

---

## 📝 実装の詳細

### コードの説明

`lib/main.dart` でのSupabase統合の主要部分:

#### 1. 初期化 (main関数)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .envファイルから環境変数を読み込み
  await dotenv.load(fileName: '.env');

  // Supabaseの初期化
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}
```

#### 2. データ読み込み (_loadCounter)

```dart
Future<void> _loadCounter() async {
  try {
    // Supabaseからデータを取得
    final response = await supabase
        .from('counters')
        .select('value')
        .eq('id', 1)
        .maybeSingle();

    if (response != null) {
      // データが存在する場合、値を設定
      setState(() {
        _counter = response['value'] as int;
        _isLoading = false;
      });
    } else {
      // データが存在しない場合、初期値を挿入
      await supabase.from('counters').insert({'id': 1, 'value': 0});
      setState(() {
        _counter = 0;
        _isLoading = false;
      });
    }
  } catch (e) {
    // エラー処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading counter: $e')),
    );
  }
}
```

#### 3. データ更新 (_incrementCounter)

```dart
Future<void> _incrementCounter() async {
  final newValue = _counter + 1;

  // UIを即座に更新（楽観的更新）
  setState(() {
    _counter = newValue;
  });

  try {
    // Supabaseにデータを保存
    await supabase
        .from('counters')
        .update({'value': newValue})
        .eq('id', 1);
  } catch (e) {
    // エラー処理
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving counter: $e')),
    );
  }
}
```

---

## 🔗 関連リンク

- [Supabase公式ドキュメント](https://supabase.com/docs)
- [Supabase Flutter クイックスタート](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [flutter_dotenv パッケージ](https://pub.dev/packages/flutter_dotenv)
- [supabase_flutter パッケージ](https://pub.dev/packages/supabase_flutter)

---

## 📊 次のステップ

Supabaseの導入が完了したら、以下の機能を追加できます:

- [ ] ユーザー認証機能の実装
- [ ] リアルタイムデータ同期
- [ ] 複数ユーザー間でのカウンター共有
- [ ] 画像アップロード機能（Supabase Storage）
- [ ] プロフィール管理機能

---

**最終更新**: 2025-10-10
