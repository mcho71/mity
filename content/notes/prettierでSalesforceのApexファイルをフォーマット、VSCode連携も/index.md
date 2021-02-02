---
title: 'PrettierでSalesforceのApexファイルをフォーマット、VSCode連携も'
date: 2021-02-02T13:39:03+09:00
categories:
  - Development
tags:
  - prettier
  - Apex
  - Salesforce
  - VSCode
keywords:
  - prettier
  - Apex
  - Salesforce
  - VSCode
archives: 2021-02
---

必要なライブラリインストールする。

[Prettier · Opinionated Code Formatter](https://prettier.io/)

[dangmai/prettier-plugin-apex: Code formatter for the Apex Programming Language](https://github.com/dangmai/prettier-plugin-apex)

```sh
npm i -D prettier prettier-plugin-apex
```

apex 向け prettier 設定を`.prettierrc`などとしてプロジェクトに追加する

```json
// .prettierrc
{
  "overrides": [
    {
      "files": ["*.cls", "*.trigger"],
      "options": {
        "useTabs": true
      }
    }
  ]
}
```

prettier のフォーマットコマンドをテストする。

```sh
npx prettier -c path/to/apex.cls
```

以下のメッセージが出ていれば OK

style 違反があるとき

```log
Checking formatting...
[warn] path/to/apex.cls
[warn] Code style issues found in the above file(s). Forgot to run Prettier?
```

style 違反がないとき

```log
Checking formatting...
All matched files use Prettier code style!
```

ここまででプロジェクトの Apex ファイルが prettier でフォーマットできるようになりました。

#### VSCode でフォーマットする。

以下の拡張機能をインストール
[Prettier - Code formatter - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

`.vscode/settings.json`をに以下を追記

```json
{
  "[apex]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    // 保存時にフォーマットする設定です。お好みにあわせて変更してください。
    "editor.formatOnSave": true
  }
}
```

以上です。
