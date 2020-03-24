---
title: 'GitHubActionsからSlackへメッセージを送信する'
date: 2020-03-06T17:34:24+09:00
categories:
  - Development
tags:
  - GitHubActions
  - Slack
keywords:
  - GitHubActions
  - GitHub
  - Slack
  - PullReminders
archives: 2020-03
---

## どうしてやるの

- [GitHubActions で Salesforce のスクラッチ組織を作成する]({{< ref "githubactionsでスクラッチ組織を作成する" >}})のワークフローから Slack にログイン URL を送りたかった。

## なにを使うか

[pullreminders/slack-action: GitHub Action for posting Slack messages](https://github.com/pullreminders/slack-action)を使うことにした。  
今気づいたんですが、これ PullPanda のリポジトリだ

## セットアップ

上記リポジトリの手順通り進める。流れは

1. Slack App を作成
2. Slack App トークンを GitHub に登録
3. GitHub Actions のワークフローを作成

です、詳しくは前述したリポジトリの方見てください。

## セットアップしていく

### 1. Slack App を作成

[Slack API: Applications | Slack](https://api.slack.com/apps)を開いて`Create New App`ボタンをクリックしてアプリを作成します。今回は AppName を`GABot`としました。Slack ワークスペースは追加したい場所を選択してください。

メッセージ送信ができるようにアプリに Bot 用の機能を追加します。アプリの Basic Information ページの上部アコーディオンを開き`Bots`をクリックすると追加できます。

※画像は設定済みのものになります

![bot権限を付与](/img/2020-03-24-16-06-13.png)

Slack ワークスペースに アプリをインストールします。
![Slackワークスペースにインストール](/img/2020-03-24-16-08-09.png)

※private チェンネルの場合は、チャンネルの詳細タブを開いてそこからアプリをインストールしてください。

### 2. Slack App トークンを GitHub に登録

アプリの OAuth & Permissions ページの Bot User OAuth Access Token をコピーして

![Bot User OAuth Access Token](/img/2020-03-24-16-19-59.png)

GitHub の Secrets に登録します。

![GitHubのSecretsに登録](/img/2020-03-24-16-22-21.png)

### 3. GitHub Actions のワークフローを作成

簡単なメッセージを送信するワークフローで試してみます。`.github/workflows`に `hello-slack.yml`を作成して、以下をコピペします。コピペしたら一番下の行の`\"channel\":\"GM84QDF1P\"`を投稿したいチャンネル ID に書き換えます。

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
          args: '{\"channel\":\"GM84QDF1P\",\"text\":\"Hello Slack\"}'
```

## 終わり

以上で GithubActions から Slack へのメッセージ送信の準備はできました。あとは、master ブランチにコミットして push して、Slack チャンネルにメッセージが投稿されることを確認したら完了です。
