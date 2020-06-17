---
title: '背面に隠れた要素をクリックできるようにするCSS'
date: 2020-06-17T17:48:15+09:00
categories:
  - Bookmark
tags:
  - CSS
  - HTML
keywords:
  - CSS
  - HTML
  - Toast
  - トースト
  - z-index
archives: 2020-06
---

てっきり`z-index`でできると思っていたけど、できなかったのでメモ

[pointer-events - CSS: カスケーディングスタイルシート | MDN](https://developer.mozilla.org/ja/docs/Web/CSS/pointer-events)

を使う。  
以下の画像のようなときに、透明なコンテナが横幅いっぱいに広がって下のボタンが押せなくなるのを防ぎたかった。

![需要ある時の例](image/2020-06-17-17-52-43.png)

こんな感じにすると透明なコンテナの下にある要素をクリックできる。

```html
<div class="fixed-container">
  <span class="toast" />
  <span class="toast" />
  <span class="toast" />
</div>
<style>
  .fixed-container {
    pointer-events: none;
  }
  .fixed-container > .toast {
    pointer-events: auto;
  }
</style>
```
