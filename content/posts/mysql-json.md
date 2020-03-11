---
title: "MySQL JSON型の集計"
date: 2019-03-12T14:09:17+09:00
categories: 
- Database
tags: 
- MySQL
keywords: 
- MySQL
- JSON
- 集計
- JSON_TABLE
archives: 2019-03
---

MySQLのJSON型に対するクエリを書く際に苦労したので、それのメモを。  
このページ内で、オブジェクト型、配列型という言葉が出てきますが、造語です。一般的には通じません。

## tl;dr

- `JSON_TABLE`関数を使用するために、MySQLのバージョンを8以上にする。
- 集計対象のJSON型のデータ構造を、集計に適した形にする。
  - 込み入った集計を必要とする場合は、このページの[配列型](#配列型)のようなデータ構造のほうが良さそう。
- `JSON_TABLE`が使用できない場合は、取得したあとに集計処理をするほうが簡潔。
  - ただ、リソースがきつい

## 環境

```sql
CREATE TABLE `target_table` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `info` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
```

次に、`target_table.info`のデータ構造別に集計処理のための前処理的なクエリを作成してみる。

## オブジェクト型

```オブジェクト型.json
{
  "1": {"0": {"foo": 100}},
  "2": {"0": {"foo": 200}},
  ...
}
```

こんな感じのデータ構造、厄介な形だとおもう。
こみいった集計をするには↓のようなデータを取得したくなる

| key1 | key2 | foo |
| ---- | ---- | --- |
| 1    | 0    | 100 |
| 2    | 0    | 200 |

クエリはこんな感じになった

```オブジェクト型集計.sql
SELECT
  key1table.key1,
  key2list.key2,
  JSON_EXTRACT(key1table.key1value, CONCAT('$."', key2list.key2, '".foo')) AS foo
FROM
  (
    SELECT
      key1list.key1,
      JSON_EXTRACT(info, CONCAT('$."', key1list.key1, '"')) AS key1value
    FROM
      target_table,
      JSON_TABLE (
        JSON_KEYS(info),
        '$[*]' COLUMNS (key1 INT PATH '$')
      ) AS key1list
  ) AS key1table,
  JSON_TABLE(
    JSON_KEYS(key1table.key1value),
    '$[*]' COLUMNS (key2 INT PATH '$')
  ) AS key2list
;
```

SQL力の低さも相まってか、大げさなクエリになった。サブクエリじゃないにしてもテーブルを結合する必要が有りそう。

以下、テストデータ作成用

```オブジェクト型データ挿入.sql
DROP PROCEDURE IF EXISTS loop_insert_record;
DELIMITER //
CREATE PROCEDURE loop_insert_record(IN x INT)
BEGIN
  DECLARE i INT;
  DECLARE info CHAR;
  SET i = 0;
  WHILE i < x DO
    SET i = i + 1;
    INSERT INTO `target_table` (info) VALUE (
        REPLACE(
          REPLACE(
            '{"1": {"0": {"foo": %d1}}, "2": {"0": {"foo": %d2}}}',
            '%d1',
            CONVERT(ROUND(RAND() * 100), CHAR)
          ),
          '%d2',
          CONVERT(ROUND(RAND() * 100), CHAR)
        )
      );
  END WHILE;
END
//
delimiter ;
call lop_insert_record(100);
```

## 配列型

```配列型.json
[
  {
    "key1": 1,
    "objectList1": [{"key2": 0, "objectList2": [{"foo": 100}]}]
  },
  {
    "key1": 2,
    "objectList1": [{"key2": 0, "objectList2": [{"foo": 200}]}, {"key2": 1, "objectList2": [{"foo": 200}]}]
  }
]
```

`JSON_TABLE`で集計しやすい形だと思ってる。
前項と同様に、集計を行う際には↓ようなデータを取得したい。

| key1 | key2 | foo |
| ---- | ---- | --- |
| 1    | 0    | 100 |
| 2    | 0    | 200 |

```配列型集計.sql
SELECT
  it.*
FROM
  target_table tt,
  JSON_TABLE (
    tt.info,
    '$[*]' COLUMNS (
      key1 INT PATH '$."key1"',
      NESTED PATH '$."objectList1"[*]' COLUMNS (
        key2 INT PATH '$."key2"',
        NESTED PATH '$."objectList2"[*]' COLUMNS (
          foo INT PATH '$."foo"'
        )
      )
    )
  ) AS it;
```

簡潔に書けた。

以下、テストデータ作成用

```配列型データ挿入.sql
DROP PROCEDURE IF EXISTS loop_insert_record;
DELIMITER //
CREATE PROCEDURE loop_insert_record(IN x INT)
BEGIN
  DECLARE i INT;
  DECLARE info CHAR;
  SET i = 0;
  WHILE i < x DO
    SET i = i + 1;
    INSERT INTO `target_table` (info) VALUE (
        REPLACE(
          REPLACE(
            '[{"key1": 1, "objectList1": [{"key2": "0", "objectList2": [{"foo": %d1}]}]}, {"key1": "2", "objectList1": [{"key2": "0", "objectList2": [{"foo": %d2}]}, {"key2": "1", "objectList2": [{"foo": %d1}]}]}]', 
            '%d1',
            CONVERT(ROUND(RAND() * 100), CHAR)
          ),
          '%d2',
          CONVERT(ROUND(RAND() * 100), CHAR)
        )
      );
  END WHILE;
END
//
delimiter ;
call loop_insert_record(100);
```

## おわりに

`JSON_TABLE`に最適化していくのが吉だと思ったので、積極的に配列型のような形にしていきたい。
オブジェクト型は、中身のデータ構造を気にせずに、キーの有無が大事になる場合が使いどころかな。

## 参考

[MySQL :: MySQL 8.0 Reference Manual :: 12.17.1 JSON Function Reference](https://dev.mysql.com/doc/refman/8.0/en/json-function-reference.html)