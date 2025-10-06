---
title: 修士論文のタイトル
author:
  - 21XXX 山田 太郎
supervisor: 嶋 久登 教授
date: 1111年1月11日
institute: |
  神戸情報大学院大学
  情報技術研究科 情報システム専攻
---
---
title: "修士論文のタイトル"
author: "氏名"
date: "2025年10月4日"
documentclass: bxjsreport  # 日本語の論文に適したクラス
classoption:
  - "pandoc"
toc: true
header-includes:
  - '\renewcommand{\chaptername}{第}' # 章名の前に「第」を追加
  - '\renewcommand{\thesection}{\thechapter.\arabic{section}}' # セクション番号を「章番号.セクション番号」形式に
---