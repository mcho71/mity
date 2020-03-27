---
title: 'Salesforceで開発中のスクラッチ組織を非技術者に簡単に見てもらうためにやったこと'
date: 2020-03-26T17:13:09+09:00
categories:
  - Salesforce
tags:
  - GitHubActions
  - SFDX
  - Slack
  - pullreminders
keywords:
  - セールスフォース
  - CI
  - npm
  - urlencode
archives: 2020-03
---

## どうしてやろうとしたのか

SFDX プロジェクトの開発中に、変更された箇所を確認するための手間を省きたいので、やろうと思いました。

## どうやってやるのか

プロジェクトの内容が変更されたら、自動的にスクラッチ組織を作成して、Slack に通知する、という流れです。
今回のプロジェクトは GitHub で管理されているため、具体的には以下の流れでやりました。

1. GitHub の master ブランチが更新される
2. 変更されたソースを元にスクラッチ組織を作成/セットアップする
3. Slack にスクラッチ組織のログイン URL を通知する

詳しい手順はそれぞれ、[GitHubActions でスクラッチ組織を作成する]({{< ref "GitHubActionsでスクラッチ組織を作成する.md" >}})と[GitHubActions から Slack へメッセージを送信する]({{< ref "GitHubActionsからSlackへメッセージを送信する.md" >}})に書いてあります。この記事は二つの記事をまとめたものになります。

## プロジェクトの状態

- GitHub の private リポジトリで管理されている
- セットアップはコマンドで完結できる
- npm パッケージを含んでいる

## 実現するまでにやったこと

### GitHubActions でスクラッチ組織を作成する

まずは、GitHubActions で[Salesforce CLI](https://developer.salesforce.com/ja/tools/sfdxcli)を使えるようにするために `package.json` の `devDependencies` に含めます。

```sh
npm i -D sfdx-cli
```

次に、 DevHub が有効になっている組織の認証を得る必要があります。コマンドライン上で完結する認証コマンドは`force:auth:sfdxurl:store`です。これを使うために。`Sfdx Auth Url`を以下のコマンドで表示、コピーして GitHub の Secrets に登録します。

```sh
## 事前にDevHubを使用する組織にログインしておいてください
sfdx force:org:display --verbose -u ForGitHubAction
```

Secrets の登録は GitHub のリポジトリページの Settings > Secrets からできます。

![Secrets画面](/img/2020-03-03-17-01-54.png)

最後に、スクラッチ組織を作成する GitHubActions のワークフローを作成して準備は完了です。以下のコードを`.github/workflows/create-scratch-org.yml`に貼り付けてコミットプッシュします。

```yml
name: スクラッチ組織のログインURLをSlackに通知する

on:
  push:
    branches:
      - master

jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      - name: 'ソースコードをチェックアウトする'
        uses: actions/checkout@v2

      - name: 'node_modulesのキャッシュがあったら使う'
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

      - name: 'Secretsに登録したSfdx Auth Urlをファイルへ出力'
        run: echo ${{ secrets.DEVHUB_SFDX_URL }} > ./SFDX_AUTH_URL.txt

      - name: 'Salesforce組織にログインする'
        run: npx sfdx force:auth:sfdxurl:store -f ./SFDX_AUTH_URL.txt -d

      - name: 'スクラッチ組織を作成する'
        run: npx sfdx force:org:create -f config/project-scratch-def.json -a TestScratchOrg -d 1

      - name: 'ソースをプッシュ'
        run: npx sfdx force:source:push -u TestScratchOrg

      - name: 'パスワードを発行'
        run: npx sfdx force:user:password:generate -u TestScratchOrg

      - name: 'ID/PWからログインURLを作成する'
        id: make-login-url
        shell: bash
        run: |
          ORG_INFO=$(npx sfdx force:org:display -u TestScratchOrg --json | jq .result)
          INSTANCE_URL=$(echo $ORG_INFO | jq .instanceUrl)
          USER_NAME=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1][1:-1]))" $(echo $ORG_INFO | jq .username))
          PASSWORD=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1][1:-1]))" $(echo $ORG_INFO | jq .password))
          echo "##[set-output name=login-url;]$(echo ${INSTANCE_URL}?un=${USER_NAME}\&pw=${PASSWORD})"

      - name: '期限のないログインURLを表示'
        run: echo ${{ steps.make-login-url.outputs.login-url }}
```

うまくいくと Actions のログにログイン URL が表示されます。

### Slack へログイン URL を通知する

このログイン URL を Slack に通知するために、[pullreminders/slack-action: GitHub Action for posting Slack messages](https://github.com/pullreminders/slack-action)を使います。セットアップ手順はリンク先にもありますのでそちらも参考にしてください。

それではセットアップしていきます。

#### Slack App を作成

[Slack API: Applications | Slack](https://api.slack.com/apps)を開いて`Create New App`ボタンをクリックしてアプリを作成します。今回は AppName を`GABot`としました。Slack ワークスペースは適宜追加したい場所を選択してください。

メッセージ送信ができるようにアプリに Bot 用の機能を追加します。アプリの Basic Information ページの上部アコーディオンを開き`Bots`をクリックすると追加できます。

※画像は設定済みのものになります

![bot権限を付与](/img/2020-03-24-16-06-13.png)

Slack ワークスペースに アプリをインストールします。
![Slackワークスペースにインストール](/img/2020-03-24-16-08-09.png)

※private チェンネルの場合は、チャンネルの詳細タブを開いてそこからアプリをインストールしてください。

#### Slack App の Bot User OAuth Access Token トークンを GitHub に登録

アプリの OAuth & Permissions ページの Bot User OAuth Access Token をコピーして

![Bot User OAuth Access Token](/img/2020-03-24-16-19-59.png)

GitHub の Secrets に登録します。

![GitHubのSecretsに登録](/img/2020-03-24-16-22-21.png)

### GitHub Actions のワークフローを作成

簡単なメッセージを送信するワークフローで試してみます。`.github/workflows/hello-slack.yml`を作成して、以下をコピペします。コピペしたら一番下の行の`\"channel\":\"GM84QDF1P\"`を投稿したいチャンネル ID に書き換えます。

```yml
name: GABotでHelloSlack

on:
  push:
    branches:
      - master

jobs:
  hello-slack:
    runs-on: ubuntu-latest
    steps:
      - name: 'Hello Slack'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.GA_BOT_TOKEN }}
        uses: pullreminders/slack-action@master
        with:
          args: '{\"channel\":\"GM84QDF1P\",\"text\":\"Hello world\"}'
```

args に指定するメッセージのフォーマットは[Formatting text for app surfaces | Slack](https://api.slack.com/reference/surfaces/formatting)を参考に、適宜調節します。  
以上で GithubActions から Slack へのメッセージ送信の準備はできました。あとは、master ブランチにコミットして push して、Slack チャンネルにメッセージが投稿されることを確認したら完了です。

![Hello Slack](/img/2020-03-27-15-23-30.png)

## 完成したワークフロー

上記二つのワークフローが、うまく動くことを確かめたら、二つをマージします。完成したワークフローは以下になります、ファイル名をわかりやすく`.github/workflows/create-scratch-org-and-notification-to-slack.yml`として保存しました。

```yml
name: スクラッチ組織のログインURLをSlackに通知する

on:
  push:
    branches:
      - master

jobs:
  create-scratch-org-and-notification-to-slack:
    runs-on: ubuntu-latest
    steps:
      - name: 'ソースコードをチェックアウトする'
        uses: actions/checkout@v2

      - name: 'node_modulesのキャッシュがあったら使う'
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

      - name: 'Secretsに登録したSfdx Auth Urlをファイルへ出力'
        run: echo ${{ secrets.DEVHUB_SFDX_URL }} > ./SFDX_AUTH_URL.txt

      - name: 'Salesforce組織にログインする'
        run: npx sfdx force:auth:sfdxurl:store -f ./SFDX_AUTH_URL.txt -d

      - name: 'スクラッチ組織を作成する'
        run: npx sfdx force:org:create -f config/project-scratch-def.json -a TestScratchOrg -d 1

      - name: 'ソースをプッシュ'
        run: npx sfdx force:source:push -u TestScratchOrg

      - name: 'パスワードを発行'
        run: npx sfdx force:user:password:generate -u TestScratchOrg

      - name: 'ID/PWからログインURLを作成する'
        id: make-login-url
        shell: bash
        run: |
          ORG_INFO=$(npx sfdx force:org:display -u TestScratchOrg --json | jq .result)
          INSTANCE_URL=$(echo $ORG_INFO | jq .instanceUrl)
          USER_NAME=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1][1:-1]))" $(echo $ORG_INFO | jq .username))
          PASSWORD=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1][1:-1]))" $(echo $ORG_INFO | jq .password))
          echo "##[set-output name=login-url;]$(echo ${INSTANCE_URL}?un=${USER_NAME}\&pw=${PASSWORD})"

      - name: 'ログインURLをスラックに通知する'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.GA_BOT_TOKEN }}
        uses: pullreminders/slack-action@v1.0.7
        with:
          args: '{
            \"channel\": \"GM84QDF1P\",
            \"attachments\": [
              {
                \"fallback\": \"メッセージの投稿に失敗しました...\",
                \"color\": \"#36a64f\",
                \"title\": \"masterブランチが更新されました！\",
                \"text\": \"下記URLからスクラッチ組織にログインすることが出来ます。\n${{ steps.make-login-url.outputs.login-url }}\"
              }
            ]
          }'
```

これをコミットして master ブランチ更新して push すると、ログイン URL を含んだ以下のメッセージが指定の Slack チャンネルに送られてくれば完成です！

![ログインURLをSlackに通知](/img/2020-03-27-15-58-51.png)

## 終わり

以上です、Slack からこのワークフローをトリガーできたりしたら更に便利になりそうです。
