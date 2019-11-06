---
title: "TypeScriptなVueプロジェクトをページ分けするときにやったこと"
date: 2019-11-05T15:31:32+09:00
categories:
- Development  
tags: 
- Vue
- Webpack
keywords: 
- multi projects
- マルチプロジェクト
- vue
- vue-cli-service
- vue.config.js
- multi page app
- マルチページ
archives: 2019-11
---

## これはなに

Vueのプロジェクトに管理画面用アプリケーションを追加した際にやったことのメモ

## 事前知識

`@vue/cli`, `@vue/cli-service`についてあまり知らなかったので、今回よく使っていたコマンドをメモ

- `vue-cli-service build` - `vue create`で作成されたプロジェクトのnpm scriptsに`npm run build`として登録されていた。`vue.config.js`にビルド設定がある。
- `vue inspect` - `vue.config.js`を考慮した実際にビルドの際に使われる`webpack.config.js`を出力してくれる

## 始める前のプロジェクト構成等

`vue cli`で生成したままのプロジェクト構成でした。
必要そうなものを抜き出すとこんな感じ

```tree
├── public
├── src
├── tests
├── package.json
└── vue.config.js
```

ちなみにビルドは`vue-cli-service build`で行っていた。

## やりたいこと

- 出力をdist/app, dist/adminのように複数ディレクトリに分ける。

## 変更後のディレクトリ構成とビルドコンフィグ

アプリと管理画面のソースを分けるために以下のようにディレクトリ構成を変更した。

```tree
.
├── projects
│    ├── admin
│    │   ├── public
│    │   ├── src
│    │   ├── package.json
│    │   └── vue.config.js
│    └── app
│        ├── public
│        ├── src
│        ├── package.json
│        └── vue.config.js
└── package.json
```

## こうなった理由(仮)

やり始めた際は`vue.config.js`の`pages`でマルチエントリにして終わりと思っていたけど、そうは行かなかったのは以下。

- 出力先が同ディレクトリ
    - 自分の知識では`vue.config.js`から制御しきれなかった
- コンフィグ系が共有
    - `tsconfig.json`、`vue.config.js`等々。必要のない設定を読み込むことが双方のプロジェクトに発生する。
- ビルドが同時のみ
    - 現時点の`vue-cli-service(ver 3.12.1)`では`vue.config.js`の`pages`はエントリポイントを増やすことだけを行って、個別に`webpack.config.js`相当のものを作るわけじゃなかった。

ということで、`projects`ディレクトリを作ってそこで`vue create admin`を叩いた感じになった。

## この構成で思うこと

- package.jsonめっちゃある
- node_modulesもめっちゃある、重複しまくりそう
