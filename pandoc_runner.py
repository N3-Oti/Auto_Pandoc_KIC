#!/usr/bin/env python3
"""
Pandoc Runner Script
論文のMarkdownファイルをWordドキュメントに変換するスクリプト
"""

import os
import subprocess
import sys
import glob
import re
import yaml
from pathlib import Path


def extract_metadata_from_title_file(title_file_path):
    """
    00_title.mdからメタデータを抽出する
    
    Args:
        title_file_path: タイトルファイルのパス
    
    Returns:
        dict: 抽出されたメタデータ（title, author, date等）
    """
    if not os.path.exists(title_file_path):
        print(f"警告: タイトルファイルが見つかりません: {title_file_path}")
        return None
    
    try:
        with open(title_file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # YAMLフロントマターを抽出
        yaml_match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
        if yaml_match:
            yaml_content = yaml_match.group(1)
            metadata = yaml.safe_load(yaml_content)
            return metadata
        else:
            print(f"警告: {title_file_path}にYAMLフロントマターが見つかりません")
            return None
            
    except Exception as e:
        print(f"エラー: {title_file_path}の読み込みに失敗しました: {e}")
        return None


def generate_filename_from_metadata(metadata):
    """
    メタデータからファイル名を生成する
    
    Args:
        metadata: 抽出されたメタデータ
    
    Returns:
        str: 生成されたファイル名
    """
    if not metadata:
        return "修士論文_氏名.docx"
    
    # タイトルを取得（最初のタイトルを使用）
    title = metadata.get('title', '修士論文')
    if isinstance(title, list):
        title = title[0]
    
    # 著者を取得
    author = metadata.get('author', '氏名')
    if isinstance(author, list):
        author = author[0]
    
    # ファイル名に使用できない文字を置換
    def sanitize_filename(text):
        # ファイル名に使用できない文字を置換
        invalid_chars = r'[<>:"/\\|?*]'
        text = re.sub(invalid_chars, '_', text)
        # 連続するアンダースコアを単一に
        text = re.sub(r'_+', '_', text)
        # 先頭末尾のアンダースコアを削除
        text = text.strip('_')
        # スペースと全角スペースをアンダースコアに置換
        text = text.replace(" ", "_")
        text = text.replace("　", "_")
        return text
    
    # タイトルを簡潔にする（長すぎる場合は省略）
    clean_title = sanitize_filename(title)
    if len(clean_title) > 30:
        clean_title = clean_title[:30] + "..."
    
    # 著者名を簡潔にする
    clean_author = sanitize_filename(author)
    
    # ファイル名を生成
    filename = f"{clean_author}_manuscript.docx"
    
    print(f"生成されたファイル名: {filename}")
    return filename


def find_markdown_files(directory="."):
    """
    指定されたディレクトリ内のMarkdownファイルを検索する
    
    Args:
        directory: 検索するディレクトリ (デフォルト: カレントディレクトリ)
    
    Returns:
        list: Markdownファイルのパスのリスト
    """
    # まずルートディレクトリを検索
    md_files = glob.glob(os.path.join(directory, "*.md"))
    
    # chapters/ フォルダも検索
    chapters_dir = os.path.join(directory, "chapters")
    if os.path.exists(chapters_dir):
        md_files.extend(glob.glob(os.path.join(chapters_dir, "*.md")))
    
    md_files.sort()
    return md_files


def run_pandoc(source_files, output_file, reference_doc=None, filter_crossref=True, bibliography=None):
    """
    Pandocを実行してWordドキュメントを生成する
    
    Args:
        source_files: 入力Markdownファイルのリスト
        output_file: 出力ファイル名
        reference_doc: 参照用のWordテンプレート (オプション)
        filter_crossref: pandoc-crossrefフィルターを使用するか
        bibliography: 参考文献ファイル (オプション)
    """
    
    if not source_files:
        print("エラー: 変換するMarkdownファイルが見つかりません")
        sys.exit(1)
    
    print(f"変換するファイル: {len(source_files)}個")
    for f in source_files:
        print(f"  - {f}")
    
    cmd = ["pandoc"]
    cmd.extend(source_files)
    cmd.extend(["-o", output_file])
    
    # defaults.yamlを使用
    if os.path.exists("defaults.yaml"):
        cmd.extend(["--defaults", "defaults.yaml"])
        print("設定ファイル: defaults.yaml")
    else:
        print("警告: defaults.yamlが見つかりません。デフォルト設定を使用します。")
        # defaults.yamlがない場合のフォールバック設定
        if filter_crossref:
            cmd.extend(["--filter", "pandoc-crossref"])
    
    # 目次タイトルの日本語化のため、直接変数を指定
    cmd.extend(["-V", "toc-title=目次"])
    cmd.extend(["-V", "lot-title=表目次"])
    cmd.extend(["-V", "lof-title=図目次"])
    print("目次タイトル変数を直接指定: toc-title=目次, lot-title=表目次, lof-title=図目次")
    
    # citeproc for bibliography
    cmd.extend(["--citeproc"])
    
    if reference_doc and os.path.exists(reference_doc):
        cmd.extend(["--reference-doc", reference_doc])
        print(f"参照テンプレート: {reference_doc}")
    
    if bibliography and os.path.exists(bibliography):
        cmd.extend(["--bibliography", bibliography])
        print(f"参考文献: {bibliography}")
    
    print(f"\n実行コマンド:")
    print(" ".join(cmd))
    print()
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"✓ 変換成功: {output_file}")
        if result.stdout:
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ エラー: Pandocの実行に失敗しました")
        print(f"エラーメッセージ: {e.stderr}")
        sys.exit(1)
    except FileNotFoundError:
        print("✗ エラー: Pandocが見つかりません。インストールされているか確認してください。")
        sys.exit(1)


def main():
    """メイン処理"""
    print("=" * 60)
    print("Pandoc Document Builder")
    print("=" * 60)
    print()
    
    current_dir = os.getcwd()
    print(f"作業ディレクトリ: {current_dir}\n")
    
    # タイトルファイルからメタデータを抽出
    title_file_candidates = [
        "chapters/00_title.md",
        "00_title.md",
        "chapters/title.md",
        "title.md"
    ]
    
    metadata = None
    title_file_path = None
    
    for candidate in title_file_candidates:
        if os.path.exists(candidate):
            title_file_path = candidate
            print(f"タイトルファイルを発見: {candidate}")
            metadata = extract_metadata_from_title_file(candidate)
            break
    
    if not metadata:
        print("警告: タイトルファイルからメタデータを抽出できませんでした")
        print("デフォルトのファイル名を使用します")
    
    # ファイル名を生成
    output_file = generate_filename_from_metadata(metadata)
    
    markdown_files = find_markdown_files()
    
    if not markdown_files:
        print("警告: Markdownファイルが見つかりません")
        print("カレントディレクトリに .md ファイルを配置してください")
        sys.exit(1)
    
    # テンプレートファイルを検索（複数の候補を試す）
    reference_doc = None
    for template_name in ["template.docx", "reference.docx"]:
        if os.path.exists(template_name):
            reference_doc = template_name
            break
    
    if not reference_doc:
        print("注意: テンプレートファイルが見つかりません（デフォルトスタイルで変換）\n")
    
    # 参考文献ファイルを検索
    bibliography = None
    for bib_name in ["references.bib", "bibliography.bib"]:
        if os.path.exists(bib_name):
            bibliography = bib_name
            break
    
    run_pandoc(
        source_files=markdown_files,
        output_file=output_file,
        reference_doc=reference_doc,
        filter_crossref=True,
        bibliography=bibliography
    )
    
    # GitHub Actions用にファイル名を環境変数として出力
    if os.environ.get('GITHUB_ACTIONS'):
        # ファイル名を環境変数として設定
        os.environ['GENERATED_FILENAME'] = output_file
        # GitHub Actionsの出力として設定
        with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
            f.write(f"filename={output_file}\n")
    
    print()
    print("=" * 60)
    print("変換完了!")
    print("=" * 60)


if __name__ == "__main__":
    main()