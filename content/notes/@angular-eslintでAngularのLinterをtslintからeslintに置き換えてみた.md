---
title: '@angular-eslint/angular-eslintでAngularのLinterをTSLintからESLintに置き換えてみた'
date: 2020-03-16T12:06:21+09:00
categories:
  - Web
tags:
  - Angular
  - ESLint
  - TSLint
keywords:
  - ESLint
  - TSLint
  - Angular
archives: 2020-03
---

## モチベーション

各所で TSLint から ESLint の移行が進んでるのと、VSCode の ESLint フォーマッターを使いたかった。

## 移行手順

`ng new`したところから始めます。AngularCLI のバージョンは`9.0.6`でした。

### パッケージのインストール

まず、`eslint`と`@angular-eslint`関連のパッケージをインストールします。
[angular-eslint/angular-eslint: Monorepo for all the tooling related to using ESLint with Angular](https://github.com/angular-eslint/angular-eslint)

```sh
npm i -D eslint \
  @angular-eslint/builder \
  @angular-eslint/eslint-plugin \
  @angular-eslint/template-parser \
  @angular-eslint/eslint-plugin-template
```

### コマンドと ESLint の設定を修正

前述したリポジトリに手順もありますが、各設定ファイルのサンプルがあったので、それを参考に`angular.json`を修正、**`.eslintrc.js`**を追加しました。angular.json の差分はこんな感じ  
![angular.jsonの差分](/img/2020-03-16-12-41-16.png)

`.eslint.js`のサンプルは
[ここ](https://github.com/angular-eslint/angular-eslint/blob/master/packages/integration-tests/fixtures/angular-cli-workspace/.eslintrc.js)からいただきました。

また、この`.eslint.js`を使うために、`@typescript-eslint`関連のパッケージが必要なので以下のコマンドでインストールします。

```sh
npm i -D @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

ここまでで`ng lint`は動くようになるはずです。手元の環境では、`app.component.spec.ts`でクオートのエラーがでました。

## VSCode でも動かしてみる

設定されてるルールが適用されてるか見てみます。サンプルにあった`'@typescript-eslint/no-non-null-assertion': 'error'`で試してみます。

!['@typescript-eslint/no-non-null-assertion': 'error'](/img/2020-03-16-18-37-21.png)

無事 Lint されていました。また、画像や動画をとっていないですが、`ESLint: Fix all auto-fixable Problems`も効きました。

## 終わり

Angular 本体の ESLint 対応も待ち遠しいですが、`@angular-eslint/angular-eslint`はルールも順次対応していくようなので、とりあえずこちらで良さそうですね
