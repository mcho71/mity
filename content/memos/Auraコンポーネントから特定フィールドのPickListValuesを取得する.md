---
title: "Auraコンポーネントから特定フィールドのPickListValuesを取得する"
date: 2020-03-09T15:54:48+09:00
categories: 
- Salesforce
tags: 
- Apex
- Aura
keywords: 
- 敬称
- Salutation
- PersonAccount
- 個人
- 取引先
- Account
- Aura
- Salesforce
- PickListValues
- 選択リスト
archives: 2020-03
---

## やりたいこと

AuraコンポーネントからオブジェクトのPickListフィールドのPickListValuesを取得したい。具体的には取引先(個人)の敬称フィールドの選択肢を取得したい。

## 取得する

ui-apiかApexコントローラーで取得できそう。ui-apiは試したらCSPが必要だったので、Apexコントローラーで取得する。

単純にやると、`Account.Salutation.getDescribe().getPicklistValues()`でできる。

汎用的にするには

```apex
SObject sObj = (SObject)Type.forName(sObjectName).newInstance();
Schema.DescribeSObjectResult describeSObj = sObj.getSObjectType().getDescribe();
Schema.SObjectField field = describeSObj.fields.getMap().get(fieldName);
field.getDescribe().getPicklistValues();
```

という感じになる。`Schema.DescribeSObjectResult`の`fields.getMap().get(fieldName)`で`SObjectField`を取得するところが味噌っぽい

## 参考

[Making API Calls from Components | Lightning Aura Components Developer Guide | Salesforce Developers](https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/js_api_calls_platform.htm)  
[DescribeSObjectResult クラス | Apex 開発者ガイド | Salesforce Developers](https://developer.salesforce.com/docs/atlas.ja-jp.apexcode.meta/apexcode/apex_methods_system_sobject_describe.htm)
