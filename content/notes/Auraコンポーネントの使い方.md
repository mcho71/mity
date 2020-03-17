---
title: "Auraコンポーネントの使い方"
date: 2020-02-21T16:10:26+09:00
categories: 
- Salesforce
tags: 
- Aura
- LightningComponent
keywords: 
- Salesforce
- Aura
- LightningComponent
archives: 2020-02
---

`Hoge.cmp`: Viewテンプレートファイル、変数の定義やライフサイクルへの関数のハンドルもやる
`HogeController.js`: `cmpファイル`で`c`から呼び出せる
`HogeHelper.js`: `HogeController.js`の`doInit: function(component, event, helper) { ... }`の`helper`に渡される。

## Hoge.cmp

- レコードのデータは`{! v.simpleRecord.Name }`のような感じでアクセスできる
    - actionで開いたモーダル内のコンポーネントだと`v.simpleRecord`と`v.record`は`undefined`だった
- コントローラーのメソッドには`c`からアクセスできる。
    - `<aura:component controller=“DirectoryConversionController”>`とすると`@AuraEnabled`のメソッドが`c`から呼べる。cは`Controller.js`の関数も含む。ハマった

## HogeController.js | HogeHelper.js

コントローラーの関数は3つの引数がデフォルトで用意されている。`doInit: function(component, event, helper) { ... }`。  
`Hoge.cmp`の`{! v.simpleRecord }`といった変数には、`component.get('v.simpleRecord')`,`component.set('v.AnyAttr', 'any')`といった感じでアクセス可能。  

## 参考

- [コンポーネントのバンドル内の JavaScript コードの共有 | Lightning Aura Components Developer Guide (Lightning Aura コンポーネント開発者ガイド) | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.lightning.meta/lightning/js_helper.htm)
- `$A`はデフォルトのネームスペース [What is $A and $A.util in lightning ? - Salesforce Developer Community](https://developer.salesforce.com/forums/?id=9060G0000005UinQAE)
- レコードのデータは`{! v.simpleRecord.Name }`のような感じでアクセスできる
    - actionで開いたモーダル内のコンポーネントだと`v.simpleRecord`と`v.record`は`undefined`だった
