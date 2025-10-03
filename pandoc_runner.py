#!/usr/bin/env python3
"""
Pandoc Runner Script
論文のMarkdownファイルをWordドキュメントに変換するスクリプト
"""

import os
import subprocess
import sys
import glob
from pathlib import Path


def find_markdown_files(directory="."):
    """
    指定されたディレクトリ内のMarkdownファイルを検索する
    
    Args:
        directory: 検索するディレクトリ (デフォルト: カレントディレクトリ)
    
    Returns:
        list: Markdownファイルのパスのリスト
    """
    md_files = glob.glob(os.path.join(directory, "*.md"))
    md_files.sort()
    return md_files


def run_pandoc(source_files, output_file, reference_doc=None, filter_crossref=True):
    """
    Pandocを実行してWordドキュメントを生成する
    
    Args:
        source_files: 入力Markdownファイルのリスト
        output_file: 出力ファイル名
        reference_doc: 参照用のWordテンプレート (オプション)
        filter_crossref: pandoc-crossrefフィルターを使用するか
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
    
    if filter_crossref:
        cmd.extend(["--filter", "pandoc-crossref"])
    
    if reference_doc and os.path.exists(reference_doc):
        cmd.extend(["--reference-doc", reference_doc])
        print(f"参照テンプレート: {reference_doc}")
    
    cmd.extend(["-M", "autoSectionLabels=true"])
    cmd.extend([
        "--standalone",
        "--toc",
        "--number-sections",
    ])
    
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
    
    markdown_files = find_markdown_files()
    
    if not markdown_files:
        print("警告: Markdownファイルが見つかりません")
        print("カレントディレクトリに .md ファイルを配置してください")
        sys.exit(1)
    
    output_file = "修士論文_氏名.docx"
    
    reference_doc = "reference.docx"
    if not os.path.exists(reference_doc):
        reference_doc = None
        print("注意: reference.docx が見つかりません（テンプレートなしで変換）\n")
    
    run_pandoc(
        source_files=markdown_files,
        output_file=output_file,
        reference_doc=reference_doc,
        filter_crossref=True
    )
    
    print()
    print("=" * 60)
    print("変換完了!")
    print("=" * 60)


if __name__ == "__main__":
    main()