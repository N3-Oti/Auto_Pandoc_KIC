# 参考文献

（↑ここに参考文献リストが自動生成されます）
🎯 流れの全体像
文献データベース（.bibファイル） を作る
ZoteroやJabRefで管理してもいいし、自分で手書きしてもOK。

例：references.bib

@article{example2020,
  author = {山田太郎 and 佐藤花子},
  title = {AIを用いた学習支援の研究},
  journal = {情報処理学会論文誌},
  year = {2020},
  volume = {61},
  number = {1},
  pages = {1--10}
}

Markdown本文で引用を挿入する
Pandocは [@キー] で文献を呼び出せる。

例：
AIによる学習支援の研究は進展している [@example2020]。


本文書を書くために参考にした文献を列挙する。（他の論文、著書、関連する既存システム、など）参考文献は、必ず本文中で引用する。（本文中に引用していない文献をここに書いてはいけない）

参考文献の書き方については情報処理学会の論文誌ジャーナル（IPSJ Journal）原稿執筆案内（https://www.ipsj.or.jp/journal/submit/ronbun_j_prms.html）のなかの「付録　参考文献の記載方法」を参照のこと。