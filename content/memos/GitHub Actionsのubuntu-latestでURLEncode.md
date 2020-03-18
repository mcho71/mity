---
title: "GitHub Actionsのubuntu-latestでURLEncode"
date: 2020-03-18T15:27:50+09:00
categories: 
- GitHubActions
tags: 
keywords: 
- urlencode
- githubactions
- github
- actions
archives: 2020-03
---

jsonから値を抜きだしてURLを作りたかったので結局こんな感じになった

```sh
USER_NAME=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1][1:-1]))" $(echo $HOGE_JSON | jq .huga))'
ENCODED_URL=$(echo https://example.com?un=${USER_NAME})
```

`$(echo $HOGE)`は引数に渡るときに`"hoge"`となるので`sys.argv[1][1:-1]`で両端のダブルクオートを切り取ってる
もっといいやり方がありそうだけどとりあえずこれで
