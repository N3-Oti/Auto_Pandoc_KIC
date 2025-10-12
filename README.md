# Auto_Pandoc_KIC

KIC向けの修士論文自動変換システムです。Markdownで書いてプッシュするだけで、GitHub Actionsが自動的にWord文書に変換します。

## ⚠️使用上の注意

使用する際はリポジトリの権限に細心の注意を払ってください。
パブリックに設定すると論文が公開されてしまいます。

## 🚀 主な機能

- **📝 Markdownで執筆**: テキストエディタでMarkdownファイルを編集
- **🔄 自動変換**: GitHub Actionsで自動的にWord文書に変換
- **📄 日本語対応**: 章番号、段落インデント、図表リストを日本語化
- **📋 目次自動生成**: 目次、図目次、表目次を自動生成

## 📁 プロジェクト構成

```
Auto_Pandoc_KIC/
├── 📁 chapters/                   # 論文章節ファイル
│   ├── 📄 00_title.md            # タイトルページ
│   ├── 📄 01_abstract.md         # 概要
│   ├── 📄 02_introduction.md     # 序論
│   └── ...                       # その他の章（デモ用）
├── 📁 filters/                    # Pandocフィルター
│   ├── 📄 japanese_chapter.lua   # 日本語章番号フィルター
│   ├── 📄 japanese_toc_titles.lua # 目次タイトル日本語化フィルター
│   └── 📄 japanese_paragraph_indent.lua # 日本語段落インデントフィルター
├── 🐍 pandoc_runner.py           # メイン実行スクリプト
├── 📋 defaults.yaml              # Pandocデフォルト設定
├── 📚 references.bib             # 参考文献データベース
├── 📄 reference.docx             # 参照テンプレート
└── 📄 README.md                  # このファイル
```

## 🛠️ 使い方

### 1. リポジトリのクローン
```bash
git clone https://github.com/N3-Oti/Auto_Pandoc_KIC.git
cd Auto_Pandoc_KIC
```

### 2. 論文の執筆
`chapters/` フォルダ内のMarkdownファイルを編集します：

```markdown
# 第1章 序論

本研究では...

## 1.1 研究背景

近年の技術発展により...

### 1.1.1 具体的な課題

具体的には...
```

### 3. 自動変換
変更をコミットしてプッシュするだけで、GitHub Actionsが自動的にWord文書に変換します：

```bash
git add .
git commit -m "論文の更新"
git push origin main
```

### 4. 結果のダウンロード
GitHub Actionsの完了後、`Actions` タブから変換されたWord文書をダウンロードできます。

## 📝 執筆のポイント

### 章ファイルの作成
- `chapters/00_title.md` - タイトルページ
- `chapters/01_abstract.md` - 概要
- `chapters/02_introduction.md` - 序論
- その他の章は必要に応じて追加

### 図表の参照
```markdown
![図の説明](path/to/image.png){#fig:example}

図 @fig:example に示すように...

| 項目 | 値 |
|------|-----|
| A    | 1   |

表 @tbl:example の結果...
```

## 🤖 GitHub Actions

- **トリガー**: `main` ブランチへのプッシュ
- **機能**: 自動的にMarkdownからWord文書に変換
- **成果物**: `thesis.docx` を自動ダウンロード可能

## 🐛 トラブルシューティング

### よくある問題

1. **章番号が正しく表示されない**
   - 見出しの階層が適切か確認（# → ## → ###）

2. **変換が失敗する**
   - GitHub Actionsのログを確認

## 📚 参考資料

- [Pandoc公式ドキュメント](https://pandoc.org/MANUAL.html)
- [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/)

---

**注意**: このツールはKICの修士論文執筆を支援するために作成されています。大学の公式ガイドラインに従って使用してください。
