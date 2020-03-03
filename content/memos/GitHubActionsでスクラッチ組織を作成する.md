---
title: "GitHubActionsでSalesforceのスクラッチ組織を作成する"
date: 2020-02-27T16:05:09+09:00
categories: 
- Salesforce
tags: 
- Salesforce
- GitHubActions
- SFDX
keywords: 
- セールズフォース
- Salesforce
- GitHubActions
- CI
- SFDX
archives: 2020-02
---

## どうしてやるの

- ワンアクションで確認用のスクラッチ組織を作成できるワークフローがほしかった。
- GitHubActionsが正式リリースされた。

## ワークフローの流れ

1. ソースをチェックアウト
2. SFDXのセットアップ
3. DevHub認証
4. スクラッチ組織を作成、セットアップ
5. ログイン用のURLを表示する

## 完成品

完成品のコードです、このままコピペするだけじゃ使えません。`2. SFDXのセットアップ`と`3. DevHubへログインする`をする必要があります。  
フック条件はmasterブランチのpushになっています。

```yml:create-scratch-org.yml
name: masterブランチpush時にスクラッチ組織作成します。

on:
  push:
    branches:
      - master

jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout source code'
        uses: actions/checkout@v2

      - name: 'SFDXのセットアップ'
        run: npm i -D sfdx

      - name: 'DevHub認証'
        shell: bash
        run: 'echo ${{ secrets.DEVHUB_SFDX_URL }} > ./DEVHUB_SFDX_URL.txt'

      # Authenticate dev hub
      - name: 'Authenticate Dev Hub'
        run: 'npx sfdx force:auth:sfdxurl:store -f ./DEVHUB_SFDX_URL.txt -a matchingmap-${{ steps.extract_branch.outputs.branch }} -d'

      # Setup Scratch Org
      - name: 'Setup Scratch Org'
        run: 'ORG_HASH=${{ steps.extract_branch.outputs.branch }} EXPIRED_DATE=1 npm run setup'

      - name: 'Generate password'
        run: 'npx sfdx force:user:password:generate -u matchingmap-SCRATCH${{ steps.extract_branch.outputs.branch }}'

      - name: 'Make Login Url'
        id: make-login-url
        shell: bash
        run: |
          ORG_INFO=$(npx sfdx force:org:display -u matchingmap-SCRATCH${{ steps.extract_branch.outputs.branch }} --json | jq .result)
          INSTANCE_URL=$(echo $ORG_INFO | jq .instanceUrl)
          USER_NAME=$(echo $ORG_INFO | jq .username)
          PASSWORD=$(echo $ORG_INFO | jq .password)
          echo "##[set-output name=login-url;]$(echo ${INSTANCE_URL}?un=${USER_NAME}\&pw=${PASSWORD})"

      # Send message to slack
      - name: 'Send scratch org Info to slack'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
        uses: pullreminders/slack-action@v1.0.7
        with:
          # [Formatting text for app surfaces | Slack](https://api.slack.com/reference/surfaces/formatting)
          args: '{
            \"channel\": \"CKR7N45JT\",
            \"attachments\": [
              {
                \"fallback\": \"メッセージの投稿に失敗しました...\",
                \"color\": \"#36a64f\",
                \"title\": \"${{ steps.extract_branch.outputs.branch }}ブランチが更新されました！\",
                \"text\": \"下記URLからスクラッチ組織にログインすることが出来ます。\n${{ steps.make-login-url.outputs.login-url }}\"
              }
            ]
          }'

```

## 各ステップについてなど

### ファイル作成と1. ソースコードのチェックアウト

[ワークフローを設定する - GitHub ヘルプ](https://help.github.com/ja/actions/configuring-and-managing-workflows/configuring-a-workflow#creating-a-workflow-file)に沿って`.github/workflows`フォルダ内へ適当にワークフローファイルを設置します。今回は`create-scratch-org.yml`とします。  
ついでにソースコードのチェックアウトまで書いてしまいます。[actions/checkout@v2](https://github.com/actions/checkout)はデフォルトでmasterブランチを、push等のブランチ系アクション場合は対象ブランチをチェックアウトします。

```yml:create-scratch-org.yml
name: スクラッチ組織を作成します。

on:
  push:
    branches:
      - master

jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout source code'
        uses: actions/checkout@v2
```

### 2. SFDXのセットアップ

SFDXとは[Salesforce CLI](https://developer.salesforce.com/ja/tools/sfdxcli)のことです、`Salesforce`がコマンドライン上から操作できるものです。  
通常のセットアップでは、上記リンクからダウンロードしてインストール、npmやbrewによるインストールがあります。GitHubActionsのワークフロー上でも同様の手順でセットアップできます。  
今回はnpmを使います。そのため`package.json`を作成する必要がありますが、これが嫌な場合や、npmが使えない場合は[sfdx-actions/setup-sfdx](https://github.com/sfdx-actions/setup-sfdx)や[forcedotcom/salesforcedx-actions](https://github.com/forcedotcom/salesforcedx-actions)を使うのも良さそうです。  
npmでsfdxをインストールするためには以下のコマンドをたたきます。

```sh
## package.jsonが存在しない場合は作成する
npm init --yes

npm i -D sfdx
```

すると`package.json`と`package-lock.json`が追加されているはずなのでコミットなりステージングなりしておきます。

ワークフローのstepsを追記します。

```yml:create-scratch-org.yml
  jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout source code'
        uses: actions/checkout@v2

      - name: 'node_modulesのキャッシュがあれば使う'
        id: app-cache-npm
        uses: actions/cache@v1
        with:
          path: node_modules
          key: npm-${{ hashFiles('**/package-lock.json') }}
          restore-keys: |
            npm-${{ env.app-cache-name }}-
            npm-

      - name: 'npm ciを実行'
        if: steps.app-cache-npm.outputs.cache-hit != 'true'
        run: npm ci

      - name: 'sfdxが使えるかテスト'
        run: npx sfdx --help
```

これでsfdxコマンドがワークフロー上で使えるようになりました。

### 3. DevHub認証

DevHubの用意が必要です。[組織での Dev Hub の有効化 | Salesforce DX 設定ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.html)  
sfdxでコマンドラインで完結する認証コマンドは`force:auth:sfdxurl:store`のみ？のようなのでこれを使います。このコマンドは`Sfdx Auth Url`を使うため、手元の環境で組織の認証をしておく必要があります。

```sh
## DevHubを使う組織を認証する。
sfdx force:auth:web:login -a ForGitHubAction

## --verboseを付けるとSfdx Auth Urlを表示されます
sfdx force:org:display --verbose -u ForGitHubAction
```

`Sfdx Auth Url`をコピペして、GitHubリポジトリのSecretsに登録しておきます。ワークフローファイルや、リポジトリ内ファイルへのベタ書きはやめたほうが良さそうです。Secretsについては[暗号化されたシークレットの作成と保存 - GitHub ヘルプ](https://help.github.com/ja/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#using-encrypted-secrets-in-a-workflow)を。  
Secretsの登録はGitHubのリポジトリページのSettings > Secretsからできます。

![Secrets画面](/img/2020-03-03-17-01-54.png)

Nameはワークフローからの呼び出しの際に使うのでわかりやすいものを、今回は`SFDX_AUTH_URL`としました。  
ワークフローファイルを追記します。

```yml:create-scratch-org.yml
  jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      # 省略
      - name: 'Secretsに登録したSfdx Auth Urlをファイルへ出力'
        run: 'echo ${{ secrets.SFDX_AUTH_URL }} > ./SFDX_AUTH_URL.txt'

      - name: 'Salesforce組織の認証を得る'
        run: 'npx sfdx force:auth:sfdxurl:store -f ./SFDX_AUTH_URL.txt -d'
```

### 4. スクラッチ組織を作成、セットアップ

普段と同様のスクラッチ組織セットアップ手順を書いていきます。例としてはこんな感じになるかと思います。

```yml:create-scratch-org.yml
  jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      # 省略
      - name: 'スクラッチ組織の作成'
        run: npx sfdx force:org:create -f config/project-scratch-def.json -a TestScratchOrg -d 1

      - name: 'ソースをプッシュ'
        run: npx sfdx force:source:push -u TestScratchOrg
```

スクラッチ組織は作成上限があるので、期限は一日としています。

### 5. ログイン用のURLを表示する

確認しやすくするために、ログイン用のURLも表示しておきます。

```yml:create-scratch-org.yml
  jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      # 省略
      - name: 'ログインURLの表示、期限が短い'
        run: npx sfdx force:org:open -r -u TestScratchOrg

      ## 恒久的なログインURLを作成する
      - name: 'パスワードを発行'
        run: npx sfdx force:user:password:generate -u TestScratchOrg

      - name: 'ID/PWからログインURLを作成する'
        shell: bash
        run: |
          ORG_INFO=$(npx sfdx force:org:display -u TestScratchOrg --json | jq .result)
          INSTANCE_URL=$(echo $ORG_INFO | jq .instanceUrl)
          USER_NAME=$(echo $ORG_INFO | jq .username)
          PASSWORD=$(echo $ORG_INFO | jq .password)
          echo ${INSTANCE_URL}?un=${USER_NAME}\&pw=${PASSWORD}
```
