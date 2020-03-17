---
title: "Aura コンポーネントのため Lightning データサービスの基本"
date: 2020-03-04T17:47:57+09:00
categories: 
- Salesforce
tags: 
- Trailhead
- Aura
keywords: 
- Salesforce
- Trailhead
- Aura
archives: 2020-03
---

## やる前

`force:recordData`を使うと楽にデータを取得、操作できるということでやってみる。

## メモ

`<aura:component implements="flexipage:availableForRecordHome, force:hasRecordId">`のように、implementsがないとLightningAppBuilderでレコードページへ追加する際に表示されない、ハマった。また、`force:hasRecordId`は`v.recordId`にアクセスできることを明示できる。[force:hasRecordId - documentation - Salesforce Lightning Component Library](https://developer.salesforce.com/docs/component-library/bundle/force:hasRecordId/documentation)  
レコードの保存はこんな感じの関数をボタンのクリック等に紐付けておこなう。`recordLoader`は`force:recordData`の`aura:id`。

```javascript
({
    save : function(cmp, event, helper) {
        var recordLoader = cmp.find("recordLoader");
        recordLoader.saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "ERROR") {
                ...
            } else {
                ...
            }
        }));
    }
})
```
