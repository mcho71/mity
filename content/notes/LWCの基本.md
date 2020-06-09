---
title: 'LWCの基本'
date: 2020-01-15T16:58:28+09:00
categories:
  - Salesforce
tags:
  - LWC
keywords:
  - LightningWebComponent
  - Trailhead
  -
  - LWC
archives: 2020-01
---

## はじめに

LWC を使いそうなので基本をやる。所謂 WebComponents が中身になってるってことはどこかでみた。

トレイルがあったので、これをやる。
[Lightning Web コンポーネントの作成 | Salesforce Trailhead](https://trailhead.salesforce.com/ja/content/learn/trails/build-lightning-web-components)

## Lightning Web コンポーネントの作成

- `LightningElement`が LWC の実装っぽい。`HTMLElement`をラップしてそう

前から 3 つ終わったけど、大体開発環境とかの話だったな

## 所感

やり終わってしまったので所感を書く。雑メモは社スラックに投稿していたので気が向いたらこっちにまとめる。
Web 標準に準拠して作られているので、最近の javascript フロントエンドライブラリを触っていれば、固有の API やアノテーションはあるけど、抵抗はすくないと感じた。モジュールをなぞってコードを読んだだけなので、やりたいことに向けてコードをいじったときに色々気づくかもしれない。
Salesforce のコンポーネントとしてしか利用出来ないのが惜しいなと、Web のどこにでも入れられるような感じに想像していたのでちょっとがっかり。
Salesforce のコンポーネントをモダンな javascript で書けるのは良い。出来ることは Aura には追いついていないらしいけど、API 等の対応も進んでいるので今後はこっちが主流になっていくのかな。
トレイルに関しては、熊追跡アプリの作成のモジュールが参考になった。その他は SFDX だったり環境構築のことが大半をしめていた。

## さいごに

日本語で PG 組織を作成すると Trailhead のステップで、ホームの API 名が違って完了しないので注意
