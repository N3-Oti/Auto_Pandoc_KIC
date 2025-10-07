# Auto_Pandoc_KIC

KIC向けの修士論文自動変換システムです。MarkdownファイルからWord文書への変換を自動化し、日本語対応の章番号付けやスタイリングを提供します。

## 🚀 主な機能

- **自動Markdown→Word変換**: Pandocを使用した高品質な文書変換
- **日本語章番号対応**: カスタムLuaフィルターによる適切な章・節番号付け
- **カスタムタイトルページ**: 大学指定フォーマットに対応したタイトルページ生成
- **自動段落インデント**: 日本語文書に適した段落スタイル
- **GitHub Actions自動化**: CI/CDによる自動ビルドと成果物配布
- **図表リスト対応**: 図表リストの日本語化と自動生成

## 📁 プロジェクト構成

```
Auto_Pandoc_KIC/
├── 📁 chapters/                   # 論文章節ファイル
├── 📁 filters/                    # Pandocフィルター
│   ├── 📄 japanese_chapter.lua   # 日本語章番号フィルター
│   ├── 📄 japanese_toc_titles.lua # 目次タイトル日本語化フィルター
│   └── 📄 japanese_paragraph_indent.lua # 日本語段落インデントフィルター
├── 📁 .github/workflows/         # GitHub Actions設定
│   └── 📄 build-thesis.yml      # 自動ビルドワークフロー
├── 📁 img/                       # 画像ファイル
│   └── 📄 KICmini.png           # KICロゴ画像
├── 🐍 pandoc_runner.py           # メイン実行スクリプト
├── 📋 defaults.yaml              # Pandocデフォルト設定
├── 📚 references.bib             # 参考文献データベース
├── 📄 reference.docx             # 参照テンプレート
└── 📄 README.md                  # プロジェクト説明書
```

## 🛠️ セットアップ

### 必要な環境

- Python 3.8+
- Pandoc 2.19+
- pandoc-crossref
- Docker (GitHub Actionsで使用)

### ローカル環境での実行

1. **リポジトリのクローン**
   ```bash
   git clone https://github.com/N3-Oti/Auto_Pandoc_KIC.git
   cd Auto_Pandoc_KIC
   ```

2. **依存関係のインストール**
   ```bash
   # Pandocのインストール
   # Windows: choco install pandoc
   # macOS: brew install pandoc
   # Ubuntu: sudo apt-get install pandoc

   # pandoc-crossrefのインストール
   # Windows: choco install pandoc-crossref
   # macOS: brew install pandoc-crossref
   ```

3. **論文ファイルの配置**
   - `chapters/` フォルダにMarkdownファイルを配置
   - `references.bib` に参考文献を追加

4. **変換の実行**
   ```bash
   python pandoc_runner.py
   ```
   
   `pandoc_runner.py` の主な機能：
   - **自動メタデータ抽出**: `chapters/00_title.md` からYAMLフロントマターを自動抽出
   - **動的ファイル名生成**: メタデータに基づいて出力ファイル名を自動生成
   - **章ファイル自動検出**: `chapters/` フォルダ内の `.md` ファイルを番号順に自動取得
   - **エラーハンドリング**: Pandocの実行エラーを適切にキャッチして表示

### Docker環境での実行（GitHub Actions使用）

このプロジェクトは主にGitHub ActionsでDockerを使用して自動変換を行います。ローカルでのDocker実行は現在サポートしていませんが、以下の方法でローカル実行が可能です：

```bash
# DockerでPandocを直接実行
docker run --rm -v "$(pwd)":/data pandoc/latex:3.5 \
  --defaults=defaults.yaml \
  --citeproc \
  --bibliography=references.bib \
  --reference-doc=reference.docx \
  -V toc-title=目次 -V lot-title=表目次 -V lof-title=図目次 \
  --filter=pandoc-crossref \
  --output=output/thesis.docx \
  ./chapters/*.md
```

## 📝 使い方

### 基本的な使い方

1. **章ファイルの作成**
   ```markdown
   # 第1章 序論

   本研究では...

   ## 1.1 研究背景

   近年の技術発展により...

   ### 1.1.1 具体的な課題

   具体的には...
   ```

2. **変換の実行**
   ```bash
   python pandoc_runner.py
   ```

3. **結果の確認**
   - `output/thesis.docx` が生成されます

### 高度な機能

#### カスタムタイトルページ

`chapters/00_title.md` でタイトルページをカスタマイズできます：

```markdown
---
title: "修士論文タイトル"
author: "学生氏名"
university: "金沢工業大学"
department: "情報工学科"
advisor: "指導教員名"
date: "2024年3月"
---

# 修士論文

## タイトル
**論文タイトル**

## 学生情報
- 氏名: 学生氏名
- 学科: 情報工学科
- 指導教員: 指導教員名

## 提出日
2024年3月
```

#### 図表の参照

```markdown
![図の説明](path/to/image.png){#fig:example}

図 @fig:example に示すように...

| 項目 | 値 |
|------|-----|
| A    | 1   |

表 @tbl:example の結果...
```

## 🔧 カスタマイズ

### フィルターの追加

新しいフィルターを `filters/` フォルダに追加し、`defaults.yaml` で有効化できます：

```yaml
filters:
  - pandoc-crossref
  - filters/japanese_chapter.lua
  - filters/japanese_toc_titles.lua
  - filters/japanese_paragraph_indent.lua
  - filters/your_custom_filter.lua
```

### スタイルの変更

`reference.docx` を編集して、出力される文書のスタイルをカスタマイズできます。

## 🤖 GitHub Actions

このリポジトリは GitHub Actions を使用して自動ビルドを実行します：

### 実行トリガー
- **自動実行**: `main` または `master` ブランチへのプッシュ
- **手動実行**: GitHub の Actions タブから手動実行可能

### 主な機能
- **章ファイル自動検出**: `chapters/` フォルダ内の `.md` ファイルを番号順に自動取得
- **reference.docx自動検出**: テンプレートファイルの存在確認と自動適用
- **詳細デバッグログ**: 変換プロセスの各段階を詳細に記録
- **成果物配布**: 変換されたWord文書（`thesis.docx`）を自動ダウンロード可能

### ワークフローの流れ
1. リポジトリのチェックアウト
2. 出力ディレクトリの作成
3. `reference.docx` の存在確認とログ出力
4. Pandocコマンドの詳細ログ表示
5. 章ファイルの自動取得とソート
6. Dockerコンテナ（pandoc/latex:3.5）での変換実行
7. 変換結果の確認とログ出力
8. 成果物のアップロード

### デバッグ機能
- ファイルサイズと権限の表示
- 章ファイルの一覧表示
- Pandocコマンド引数の詳細表示
- 変換結果の検証

## 🐛 トラブルシューティング

### よくある問題

1. **章番号が正しく表示されない**
   - `japanese_chapter.lua` フィルターが正しく読み込まれているか確認
   - 見出しの階層が適切か確認

2. **図表リストが英語のまま**
   - `defaults.yaml` の設定を確認
   - フィルターの適用順序を確認

3. **段落インデントが適用されない**
   - `japanese_paragraph_indent.lua` フィルターが有効か確認
   - `reference.docx` のスタイル設定を確認

### デバッグ方法

```bash
# 標準実行（詳細ログ付き）
python pandoc_runner.py

# 手動でPandocコマンドを実行
pandoc --defaults=defaults.yaml \
  --citeproc \
  --bibliography=references.bib \
  --reference-doc=reference.docx \
  -V toc-title=目次 -V lot-title=表目次 -V lof-title=図目次 \
  --filter=pandoc-crossref \
  --output=output/thesis.docx \
  ./chapters/*.md
```

## 📚 参考資料

- [Pandoc公式ドキュメント](https://pandoc.org/MANUAL.html)
- [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/)
- [KIC修士論文執筆要領](大学の公式ガイドラインを参照)

## 🤝 貢献

バグ報告や機能提案は Issue でお知らせください。プルリクエストも歓迎します。

## 📄 ライセンス

このプロジェクトは MIT ライセンスの下で公開されています。

## 👥 作成者

- **N3-Oti** - プロジェクト作成・メンテナンス

---

**注意**: このツールは金沢工業大学の修士論文執筆を支援するために作成されています。大学の公式ガイドラインに従って使用してください。
