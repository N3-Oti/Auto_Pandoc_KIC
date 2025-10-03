# ベースイメージとして公式のPandocイメージを指定
FROM pandoc/latex:latest

# --- 必要なツールをインストール ---
# python3: for the runner script
# pandoc-crossref: for cross-referencing
ARG PC_VERSION="0.3.17.0"
ARG PC_URL="https://github.com/lierdakil/pandoc-crossref/releases/download/v${PC_VERSION}/pandoc-crossref-Linux.tar.xz"

# apt-get updateし、wgetとpython3をインストール
# pandoc-crossrefをダウンロード・展開し、パスの通った場所に配置
# 後片付けとしてwgetを削除し、aptキャッシュをクリーンにする
RUN apt-get update && apt-get install -y \
    wget \
    python3 \
    && wget ${PC_URL} \
    && tar -xvf pandoc-crossref-Linux.tar.xz \
    && mv pandoc-crossref /usr/local/bin/ \
    && apt-get purge -y --auto-remove wget \
    && rm -rf /var/lib/apt/lists/*

# コンテナ内での作業ディレクトリを指定
WORKDIR /data