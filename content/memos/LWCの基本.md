---
title: "LWCの基本"
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

LWCを使いそうなので基本をやる。所謂WebComponentsが中身になってるってことはどこかでみた。

トレイルがあったので、これをやる。
[Lightning Web コンポーネントの作成 | Salesforce Trailhead](https://trailhead.salesforce.com/ja/content/learn/trails/build-lightning-web-components)

## Lightning Web コンポーネントの作成

- `LightningElement`がLWCの実装っぽい。`HTMLElement`をラップしてそう

前から3つ終わったけど、大体開発環境とかの話だったな

## 所感

やり終わってしまったので所感を書く。雑メモは社スラックに投稿していたので気が向いたらこっちにまとめる。
Web標準に準拠して作られているので、最近のjavascriptフロントエンドライブラリを触っていれば、固有のAPIやアノテーションはあるけど、抵抗はすくないと感じた。モジュールをなぞってコードを読んだだけなので、やりたいことに向けてコードをいじったときに色々気づくかもしれない。
Salesforceのコンポーネントとしてしか利用出来ないのが惜しいなと、Webのどこにでも入れられるような感じに想像していたのでちょっとがっかり。
Salesforceのコンポーネントをモダンなjavascriptで書けるのは良い。出来ることはAuraには追いついていないらしいけど、API等の対応も進んでいるので今後はこっちが主流になっていくのかな。
トレイルに関しては、熊追跡アプリの作成のモジュールが参考になった。その他はSFDXだったり環境構築のことが大半をしめていた。

## さいごに

日本語でPG組織を作成するとTrailheadのステップで、ホームのAPI名が違って完了しないので注意
