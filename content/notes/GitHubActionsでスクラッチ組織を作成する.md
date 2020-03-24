---
title: 'GitHubActionsでSalesforceのスクラッチ組織を作成する'
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
- GitHubActions が正式リリースされた。

## ワークフローの流れ

1. ソースをチェックアウト
2. SFDX のセットアップ
3. DevHub 認証
4. スクラッチ組織を作成、セットアップ
5. ログイン用の URL を表示する

## 完成品

完成品のコードです、このままコピペするだけじゃ使えません。`2. SFDXのセットアップ`と`3. DevHubへログインする`をする必要があります。  
フック条件は master ブランチの push になっています。

```yml:create-scratch-org.yml
name: スクラッチ組織の情報をリストアする

on:
  push:
    branches:
      - master

env:
  PROJECT_PREFIX: ci-dev

jobs:
  create-scratch-org:
    runs-on: ubuntu-latest
    steps:
      - name: 'Checkout source code'
        uses: actions/checkout@v2
      - name: 'node_modulesのキャッシュがあったら使う。'
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

      - name: 'Secretsに登録したSfdx Auth Urlをファイルへ出力'
        run: echo ${{ secrets.SFDX_AUTH_URL }} > ./SFDX_AUTH_URL.txt

      - name: 'Salesforce組織の認証を得る'
        run: npx sfdx force:auth:sfdxurl:store -f ./SFDX_AUTH_URL.txt -d

      - name: 'スクラッチ組織の作成'
        run: npx sfdx force:org:create -f config/project-scratch-def.json -a TestScratchOrg -d 1

      - name: 'ソースをプッシュ'
        run: npx sfdx force:source:push -u TestScratchOrg

      - name: 'パスワードを発行'
        run: npx sfdx force:user:password:generate -u TestScratchOrg

      - name: 'ID/PWからログインURLを作成する'
        shell: bash
        run: |
          ORG_INFO=$(npx sfdx force:org:display -u TestScratchOrg --json | jq .result)
          INSTANCE_URL=$(echo $ORG_INFO | jq .instanceUrl)
          USER_NAME=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1].strip('\"'))) $(echo $ORG_INFO | jq .username))
          PASSWORD=$(python3 -c "import sys, urllib.parse as ul; print (ul.quote_plus(sys.argv[1].strip('\"'))) $(echo $ORG_INFO | jq .password))
          echo "##[set-output name=login-url;]$(echo ${INSTANCE_URL}?un=${USER_NAME}\&pw=${PASSWORD})"

      - name: '期限のないログインURLを表示'
        run: echo ${{ steps.make-login-url.outputs.login-url }}
```

## 各ステップについてなど

### ファイル作成と 1. ソースコードのチェックアウト

[ワークフローを設定する - GitHub ヘルプ](https://help.github.com/ja/actions/configuring-and-managing-workflows/configuring-a-workflow#creating-a-workflow-file)に沿って`.github/workflows`フォルダ内へ適当にワークフローファイルを設置します。今回は`create-scratch-org.yml`とします。  
ついでにソースコードのチェックアウトまで書いてしまいます。[actions/checkout@v2](https://github.com/actions/checkout)はデフォルトで master ブランチを、push 等のブランチ系アクション場合は対象ブランチをチェックアウトします。

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

### 2. SFDX のセットアップ

SFDX とは[Salesforce CLI](https://developer.salesforce.com/ja/tools/sfdxcli)のことです、`Salesforce`がコマンドライン上から操作できるものです。  
通常のセットアップでは、上記リンクからダウンロードしてインストール、npm や brew によるインストールがあります。GitHubActions のワークフロー上でも同様の手順でセットアップできます。  
今回は npm を使います。そのため`package.json`を作成する必要がありますが、これが嫌な場合や、npm が使えない場合は[sfdx-actions/setup-sfdx](https://github.com/sfdx-actions/setup-sfdx)や[forcedotcom/salesforcedx-actions](https://github.com/forcedotcom/salesforcedx-actions)を使うのも良さそうです。  
npm で sfdx をインストールするためには以下のコマンドをたたきます。

```sh
## package.jsonが存在しない場合は作成する
npm init --yes

npm i -D sfdx
```

すると`package.json`と`package-lock.json`が追加されているはずなのでコミットなりステージングなりしておきます。

ワークフローの steps を追記します。

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

これで sfdx コマンドがワークフロー上で使えるようになりました。

### 3. DevHub 認証

DevHub の用意が必要です。[組織での Dev Hub の有効化 | Salesforce DX 設定ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.sfdx_setup.meta/sfdx_setup/sfdx_setup_enable_devhub.html)  
sfdx でコマンドラインで完結する認証コマンドは`force:auth:sfdxurl:store`のみ？のようなのでこれを使います。このコマンドは`Sfdx Auth Url`を使うため、手元の環境で組織の認証をしておく必要があります。

```sh
## DevHubを使う組織を認証する。
sfdx force:auth:web:login -a ForGitHubAction

## --verboseを付けるとSfdx Auth Urlが表示されます
sfdx force:org:display --verbose -u ForGitHubAction
```

`Sfdx Auth Url`をコピペして、GitHub リポジトリの Secrets に登録しておきます。ワークフローファイルや、リポジトリ内ファイルへのベタ書きはやめたほうが良さそうです。Secrets については[暗号化されたシークレットの作成と保存 - GitHub ヘルプ](https://help.github.com/ja/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets#using-encrypted-secrets-in-a-workflow)を。  
Secrets の登録は GitHub のリポジトリページの Settings > Secrets からできます。

![Secrets画面](/img/2020-03-03-17-01-54.png)

Name はワークフローからの呼び出しの際に使うのでわかりやすいものを、今回は`SFDX_AUTH_URL`としました。  
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

スクラッチ組織のセットアップを行います。例としてはこんな感じになるかと思います。

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
`config/project-scratch-def.json`がない場合は、[スクラッチ組織定義の設定値](https://developer.salesforce.com/docs/atlas.ja-jp.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_def_file_config_values.htm)を参考にしてください。一応下に最低限の物を置いておきます。

```json:config/project-scratch-def.json
{
  "orgName": "testOrg",
  "edition": "Developer",
  "features": []
}
```

### 5. ログイン用の URL を表示する

確認しやすくするために、ログイン用の URL も表示しておきます。  
`sfdx force:org:open -r`でインスタントなログイン URL を取得できますが、恒久的にログインしたかったので、そちらも載せています。

```yml:create-scratch-org.yml
jobs:
create-scratch-org:
  runs-on: ubuntu-latest
  steps:
    # 省略
    ## 期限が短いログインURLを表示
    - name: 'ログインURLの表示、期限が短い'
      run: npx sfdx force:org:open -r -u TestScratchOrg

    ## 期限のないログインURLを作成する
    - name: 'パスワードを発行'
      run: npx sfdx force:user:password:generate -u TestScratchOrg

    - name: 'ID/PWからログインURLを作成する'
      shell: bash
      run: |
        ORG_INFO=$(npx sfdx force:org:display -u TestScratchOrg --json | jq .result)
        INSTANCE_URL=$(echo $ORG_INFO | jq .instanceUrl)
        USER_NAME=$(echo $ORG_INFO | jq .username)
        PASSWORD=$(echo $ORG_INFO | jq .password)
        echo "##[set-output name=login-url;]$(echo ${INSTANCE_URL}?un=${USER_NAME}\&pw=${PASSWORD})

    - name: '期限のないログインURLを表示'
      run: echo ${{ steps.make-login-url.outputs.login-url }}
```

## おわりに

日毎にスクラッチ組織の作成数上限があるので、プルリク push でトリガしたりする際は注意が必要ですが、Apex テストまでやってくれると結構便利になると思います。  
あとはこのワークフローを Slack 連携させて拡張したりします。
