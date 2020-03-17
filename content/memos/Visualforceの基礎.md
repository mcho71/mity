---
title: "Visualforceの基礎"
date: 2019-11-11T15:50:31+09:00
categories: 
- Salesforce
tags: 
- Visualforce
- Trailhead
archives: 2019-11
---

## Visualforceとは

- Lightning Platformでホストできるモバイル及びデスクトップアプリケーション用のUIフレームワーク
- Salesforceの組み込み機能の拡張、新しいアプリケーションの作成ができる
- 標準またはApexでビジネスロジックを記述する。

## 使用できる場所

- ナビゲーションバーに追加
- 標準ページレイアウト内に表示
- Lightningアプリケーションビルダーでコンポーネントとして追加する
    - [Lightning Experience、Lightning コミュニティ、およびモバイルアプリケーションで利用可能] を有効にする必要がある。
- オブジェクトページの標準ボタンやリンクを上書きして表示する
- オブジェクトページにカスタムボタンやリンクを配置して表示する

## ページの作成

- APIを使用して作成変更できる
- 開発者コンソール
    - エディタがついてる。補完あり
    - LightningExperienceのページから実行でLightningExperienceでプレビュ  $A.get("e.force:navigateToURL").setParams({"url": "/apex/pageName"}).fire();
- xmlベース

## 単純な変数と数式の使用

- グローバル変数 ex. `$User` [グローバル変数 | Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.pages.meta/pages/pages_variables_global.htm)
- 構文 {! expression } を評価して出力してくれる
    - expressionないは大文字小文字区別なし
    - 文字列連結は&
    - メンバーアクセスは`.`(ドット)つなぎ
    - [式の演算子 | Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.pages.meta/pages/pages_variables_operators.html)
- 標準関数 ex. TODAY(), DAY()... [関数 | Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.222.0.pages.meta/pages/pages_variables_functions.htm)

## 標準コントローラの使用

- MVC
- 標準なアクションとデータアクセスを処理できる
- `<apex standardController="Account">`で有効化
- getQueryでコントローラにパラメータを渡せる。ex. `/apex/pageName?id={ObjectID}`

## レコード、項目、テーブルの表示

- `<apex:detail />`等の一括出力コンポーネントがある
- `<apex:outputField value="{! Account.Name }"/>`のようなUIコンポーネントもある
- `<!-->`はテーブルUI
- `<apex:relatedList list="Contacts">`はリスト

## フォームを使用したデータの入力

- `<apex:form>`のデータは`<apex:page>`で指定されたコントローラーを元にする
- プラットフォームのスタイルを使用する要素としない要素がある
    - する
        - `<apex:form>`を使用している場合
        - `<apex:pageBlock>`及び`<apex;pageBlockSection>`内で入力要素を使用する場合
- `<apex:commandButton />`でボタンが作成できる。要素を足すことで色々指定する。`action="{! save }"`,`value="Save"`等々

## 標準リストコントローラの使用

- クエリ可能
- コレクション変数でレコードの使用、絞り込み、ページネーションなども用意されている
- 一度に多数のレコードを操作することを目的としている

```xml
<!-- recordSetVarで作業するオブジェクトを設定 -->
<apex:page standardController="Contact" recordSetVar="contacts">
    <apex:pageBlock title="Contacts List">
        <!-- Contacts List -->
        <!-- テーブルのvalueにrecordSetVarで設定されたオブジェクトを渡す -->
        <apex:pageBlockTable value="{! contacts }" var="ct">
            <apex:column value="{! ct.FirstName }"/>
            <apex:column value="{! ct.LastName }"/>
            <apex:column value="{! ct.Email }"/>
            <apex:column value="{! ct.Account.Name }"/>
        </!-->
    </apex:pageBlock>
</apex:page>
```

- `<apex:datalist>`, `<apex:repeat>`等でリストを作れる

## リンク

- [標準のコンポーネントの参照 | Visualforce 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.pages.meta/pages/pages_compref.htm)