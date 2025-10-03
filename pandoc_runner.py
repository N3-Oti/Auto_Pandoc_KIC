import subprocess
import sys
from pathlib import Path

# --- ここを編集してください ---
# Markdownファイルが格納されているフォルダを指定
SOURCE_DIR = "chapters"

# --- 基本設定 (必要なら変更) ---
OUTPUT_DOCX = "修士論文_氏名.docx"
BIB_FILE = "references.bib"
REF_DOCX = "template.docx"
CSL_FILE = "ieee.csl"

def get_source_files(directory: str) -> list[str]:
    """指定されたディレクトリから.mdファイルを検索し、ソートして返す"""
    source_path = Path(directory)
    if not source_path.is_dir():
        print(f"エラー: ソースフォルダ '{directory}' が見つかりません。", file=sys.stderr)
        sys.exit(1)

    # .mdで終わるファイルを検索し、ファイル名でソート
    files = sorted(source_path.glob("*.md"))

    if not files:
        print(f"警告: '{directory}' 内にMarkdownファイルが見つかりません。", file=sys.stderr)
        return []

    # Pathオブジェクトを文字列に変換して返す
    return [str(file) for file in files]

def build_document():
    """Pandocコマンドを構築して実行する"""
    print(f"'{SOURCE_DIR}' フォルダ内のMarkdownファイルを検索しています...")
    source_files = get_source_files(SOURCE_DIR)

    if not source_files:
        print("コンパイル対象のファイルがありません。処理を終了します。")
        sys.exit(0)
        
    print(f"コンパイル対象ファイル: {', '.join(source_files)}")
    print("PythonランナーでWordドキュメントをビルドします...")

    # Pandocコマンドのリストを構築
    command = [
        "pandoc",
        # 入力ファイル
        *source_files,
        # 出力ファイル
        "-o", OUTPUT_DOCX,
        # Pandocオプション
        f"--reference-doc={REF_DOCX}",
        f"--bibliography={BIB_FILE}",
        f"--csl={CSL_FILE}",
        "--toc",               # 目次を自動生成
        "-N",                  # 章番号を振る
        "-F", "pandoc-crossref", # 図表参照を有効化
    ]

    try:
        # コマンドを実行
        # check=True: コマンドが失敗した場合に例外を発生させる
        result = subprocess.run(command, check=True, capture_output=True, text=True, encoding='utf-8')
        print(f"ビルド完了: {OUTPUT_DOCX}")
        # 詳細なログが必要な場合は下のコメントを解除
        # if result.stdout:
        #     print("Pandoc STDOUT:\n", result.stdout)
    except FileNotFoundError:
        print("エラー: 'pandoc' コマンドが見つかりません。", file=sys.stderr)
        print("Dockerコンテナ内にPandocは正しくインストールされていますか？", file=sys.stderr)
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        # Pandoc実行中にエラーが発生した場合
        print("Pandocの実行中にエラーが発生しました。", file=sys.stderr)
        print(f"リターンコード: {e.returncode}", file=sys.stderr)
        print(f"エラー出力:\n{e.stderr}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    build_document()
```

### 主な変更点

1.  **`SOURCE_FILES` のリストを削除**: ファイル名を直接書き込む必要がなくなりました。
2.  **`SOURCE_DIR` の追加**: `chapters` という名前のフォルダを検索対象とするよう設定しました。このフォルダ名は自由に変更できます。
3.  **ファイルの自動検索**: スクリプト実行時に、`SOURCE_DIR` で指定されたフォルダ内にある `.md` で終わるファイルをすべて探し出し、ファイル名で自動的にソート（`01_...`, `02_...` の順に並び替え）します。

### 新しい使い方

この変更に伴い、プロジェクトのフォルダ構成を少し変更する必要があります。

1.  プロジェクトのルートに **`chapters`** という名前の新しいフォルダを作成してください。
2.  これまでルートに置いていたMarkdownファイル（`01_intro.md`, `02_method.md` など）を、すべてこの **`chapters`** フォルダの中に移動します。

**新しいフォルダ構成の例:**
修士論文/
├── 📁 chapters/              <-- 論文本体のフォルダ
│   ├── 📄 01_intro.md
│   └── 📄 02_method.md
├── 🐍 pandoc_runner.py       
├── 🐳 Dockerfile
├── 🐳 docker-compose.yml
├── 📚 references.bib         <-- 参考文献のファイル
└── 🎨 template.docx          <-- テンプレートのファイル
```