---
title: "MySQL JSON型の集計"
date: 2019-03-12T14:09:17+09:00
categories: 
- Database
tags: 
- MySQL
keywords: 
- MySQL
---

MySQLのJSON型に対するクエリを書く際に苦労したので、それのメモを。

## tl;dr

- `JSON_TABLE`関数を使用するために、MySQLのバージョンを8以上にする。
- 集計対象のJSON型のデータ構造を、集計に適した形にする。
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

ここからは、`target_table.info`のデータ構造と、集計クエリについて書いていく

## オブジェクト型

```キーバリュー.json
{
  "1": {"0": {"foo": 100}},
  "2": {"0": {"foo": 200}},
  ...
}
```

こんな感じのデータ構造、厄介な形だとおもう。
こみいった集計をするには↓のようなデータを取得したくなる

key1|key2|foo
---|---|---
1|0|100
2|0|200

クエリはこんな感じかな？

```sql
SELECT
  key1table.key1,
  key2list.key2,
  JSON_EXTRACT(key1table.key1value, CONCAT('$."', key2list.key2, '".foo'))
FROM
  (
    SELECT
      key1list.key1,
      JSON_EXTRACT(info, CONCAT('$."', key1list.key1, '"')) AS key1value
    FROM
      target_table,
      JSON_TABLE (
        JSON_KEYS(info),
        '$[*]' COLUMNS (key1 VARCHAR(100) PATH '$')
      ) AS key1list
  ) AS key1table,
  JSON_TABLE(
    JSON_KEYS(key1table.key1value),
    '$[*]' COLUMNS (key2 VARCHAR(100) PATH '$')
  ) AS key2list
;
```

今の僕のSQL力だとこんな感じになってしまう、サブクエリじゃないにしてもテーブルを結合する必要が有ると思う。

以下、テストデータ作成用

```データ挿入.sql
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

追記する。

## 参考

[MySQL :: MySQL 8.0 Reference Manual :: 12.17.1 JSON Function Reference](https://dev.mysql.com/doc/refman/8.0/en/json-function-reference.html)