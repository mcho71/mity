---
title: 'TRAILHEADに入門した'
date: 2019-10-31T13:07:17+09:00
categories:
  - Salesforce
tags:
keywords:
archives: 2019-10
---

## TRAILHEAD ってなに

[_Trailhead | 楽しく学ぶ方法_](https://trailhead.salesforce.com/ja/home)

Salesforce が運営している学習サイト、コンテンツは主に Salesforce 関連で、経営者、営業、開発向けが用意されている。
Salesforce 関連以外も Blockchain や、IOS アプリケーション開発のコンテンツもある。

## やり始める前の認識

- 無数にある PaaS の一つ
  - SaaS も提供してる
- セールス・顧客系に強い
- アプリやコンポーネントをリリースできる

以下、とりあえず[Trailmix by ルーキー会 Salesforce DeveloperGroup](https://trailhead.salesforce.com/ja/users/00550000007HqDdAAK/trailmixes/start-develop)を順にメモする

## Salesforce テクノロジモデル

- 信頼の基準、最も信頼されるために行ってきた投資
  - [Salesforce Trust](https://trust.salesforce.com/ja/) でシステムの状況や、セキュリティ対策が見れる
- 個別の企業以上のセキュリティを提供する方法
  - マルチテナンシー型で提供する
    - 利益となるイノベーションに注力できる
    - 高級マンションの建物を想像して
      - ドアマン、備え付き洗濯機...
      - 自分専用のスペース
      - インフラ系は大家が管理
    - Salesforce は大家の役割
    - 小さい企業から大きい企業まで同じコードベースを利用することで利益を得ることができる
- 規則の厳しい業種が Salesforce に最も重要なデータを委ねる理由
  - 上記の通り
- メタデータ
  - データのためのデータ？
  - カスタムタグ、カスタム項目、自動アラート、標準レポート、Chatte 等、全てがメタデータ
  - カスタム機能と標準機能のすべてを含む Salesforce インスタンスの構造
  - カスタマイズは特別なメタデータレイヤに分離している
    - バックグラウンドの更新やプラットフォームの更新・改善を行うことができる
- アプリケーション開発
  - カスタマイズや変更が可能なインフラを提供することが使命
  - メタデータ駆動型で速度が出る
    - ケーキにクリームを塗るように
  - ポイント&クリックかカスタムコードで開発

## Salesforce Platform の使用開始

- 標準機能
  - リードと商談
  - 顧客サポートのためのケースとコミュニティ
  - モバイルアプリ
  - 会社とつながるための Chatter とコミュニティ
  - カスタマージャーニーを管理するための MarketingCloud
  - あまり良くわかってない
- 用語
  - アプリケーション
    - ビジネスプロセスをサポートするオブジェクト、項目、その他の機能のセット
  - オブジェクト
    - 特定の種類の情報が保存される、DB のテーブル
    - 標準とカスタムがある
  - データベース
    - 巨大なスプレッドシートを想像
  - レコード
    - オブジェクトデータベーステーブルの行
  - 項目
    - オブジェクトデータベーステーブルの列
  - 組織
    - Salesforce の特定のインスタンス
- 実際にポイント&クリックで作ってみた
  - データベースへカスタムフィールドを追加できた
  - データベーステーブルのレコード詳細画面で追加されたフィールドの入力欄が表示された
- Salesforce アーキテクチャ
  - 何層にも重なってる
  - マルチテナンシー
- 設定
  - 上部ギアメニューから開く
  - 組織情報、ユーザ、プロファイル、設定変更履歴の参照、ログイン履歴等見れる
- AppExchange の戦略と、アプリケーションのインストール
  - 使用予定の部門を特定
  - 要望を最大限に満たすものを調査
    - ビジネスの問題
    - 最も苦労している点
    - 何人のユーザが必要としているか
    - 予算
    - 期限
  - そうすることで最適なアプリケーションを見つけやすくなる
  - テスト環境にダウンロード、インストールして、競合がないか確認する
  - 候補が複数ある場合はテストした内容を、使用できない機能や不要な機能がないか検討。関係者にフィードバックを依頼
  - 本番にインストール、トレーニング、ドキュメントの提供

## データモデリング

- Sales プラットフォームでオブジェクトを使用するメリット
  - オブジェクトはデータベーステーブルのこと、テーブルの列が項目、行がレコードとみなされる
  - データモデルはオブジェクトと項目のコレクション
  - 標準オブジェクト
    - Salesforce に含まれるオブジェクト
    - 取引先、取引先責任者、リード、商談などの一般的なビジネスオブジェクト
  - カスタムオブジェクト
    - 会社や業種に固有の情報を保存するために作成するオブジェクト
    - プラットフォームによっては作成にフックして、UI のページレイアウトが作成される
  - 設定の新規からオブジェクト作成と、オブジェクトの項目とリレーションの新規ボタンからフィールド追加を行った
  - スキーマビルダーという MySQL で言う ER 図のようなツールもある

## プラットフォーム開発の基礎

- Dream House Realty っていうアプリを作っていってみる
- Apex
- SOQL Salesforce Object Query Language
- Apex 上の SOQL は実行されてレコードに変換される
- Apex で書いた Controller を Visualforce ページから利用できる
- Heroku がでてきた
- REST や SOAP API も使える
- Heroku Connect で Salesforce のオブジェクトを Heroku Postgre に変換できる

## Apex の基礎とデータベース

- 小文字と大文字が区別されない
- 開発者コンソールの Debug > 匿名実行みたいなやつが便利
- sObject は汎用 Type、標準オブジェクト、カスタムオブジェクトのレコードに使用できる
- insert, upsert, merge といった便利なデータ更新用 DML ステートメントがある
- Database 配下に DML ステートメントと同じ物があって、それの第二引数に false を渡すと例外の代わりに Result オブジェクトを返すことができる
- SOSL 組織全体のレコードから特定の情報を検索、部分一致検索、どのオブジェクトのフィールドを対象とするか選べる

## Apex トリガ

- データベースの beforeSave とかのこと
- `trigger SoqlTriggerBulk on Account(after update) {` で定義する。このトリガ内で`Trigger`を呼び出せて、そこに色々情報が詰まってる
- レコードごとに処理すると思いし、制限に引っかかるから SOQL とか DML とか駆使してやろうね

## Apex テスト

- `@isTest`を使うとパラメータを指定できる。知らなかった。
- `Test > RunAll`でやるとコードカバレッジが出せる
- [Limits、startTest、および stopTest の使用 | Apex 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.apexcode.meta/apexcode/apex_testing_tools_start_stop_test.htm)

## Visualforce の基礎

- Lightning Platform でホストできるモバイル及びデスクトップアプリケーション用の UI フレームワーク
- Salesforce の組み込み機能の拡張、新しいアプリケーションの作成ができる
- 標準または Apex でビジネスロジックを記述する。

### 使用できる場所

- ナビゲーションバーに追加
- 標準ページレイアウト内に表示
- Lightning アプリケーションビルダーでコンポーネントとして追加する
  - [Lightning Experience、Lightning コミュニティ、およびモバイルアプリケーションで利用可能] を有効にする必要がある。
- オブジェクトページの標準ボタンやリンクを上書きして表示する
- オブジェクトページにカスタムボタンやリンクを配置して表示する

### ページの作成

- API を使用して作成変更できる
- 開発者コンソール
  - エディタがついてる。補完あり
  - LightningExperiense のページから実行で LightningExperiense でプレビュ \$A.get("e.force:navigateToURL").setParams({"url": "/apex/pageName"}).fire();
- xml ベース

### 単純な変数と数式の使用

- グローバル変数 ex. \$[User グローバル変数 | Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.pages.meta/pages/pages_variables_global.htm)
- 構文 {! expression } を評価して出力してくれる
  - expression ないは大文字小文字区別なし
  - 文字列連結は&
  - 式の演算子 | [Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.pages.meta/pages/pages_variables_operators.htm)
- 標準関数 ex. TODAY(), DAY()... [関数 | Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.pages.meta/pages/pages_variables_functions.htm)

### 標準コントローラの使用

- MVC
- 標準なアクションとデータアクセスを処理できる
- `<apex standardController="Account">`で有効化
- getQuery でコントローラにパラメータを渡せる。ex. /apex/pageName?id={ObjectID}

### レコード、項目、テーブルの表示

- <apex:detail />等の一括出力コンポーネントがある
- <apex:outputField value="{! Account.Name }"/>のような UI コンポーネントもある
- <apex:pageBlockTable>はテーブル UI
- <apex:relatedList list="Contacts">はリスト

### フォームを使用したデータの入力

- <apex:form>のデータは<apex:page>で指定されたコントローラーを元にする
- プラットフォームのスタイルを使用する要素としない要素がある
  - する
    - <apex:form>を使用している場合
    - <apex:pageBlock>及び<apex;pageBlockSection>内で入力要素を使用する場合
- <apex:commandButton />でボタンが作成できる。要素を足すことで色々指定する。action="{! save }",value="Save"等々

### レコードのリスト

- html の要素もそのまま書ける
- `<apex: repeat value="{! accounts }" var="a">`とするとなかで`{!a.id}`とかできる。

- `{! URLFOR($Resource.vfimagetest, 'cats/kitten1.jpg') }`とかの URLresolve 便利系がある
- 静的リソースは設定の静的リソースから追加できる

## 開発者コンソールの基礎

- ワークスペース分けできるらしい
- Log パネル、Save Perspective で配置を保存できる
-
