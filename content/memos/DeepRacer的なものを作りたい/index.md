---
title: 'DeepRacer的なものを作りたい'
date: 2021-01-29T16:38:09+09:00
categories:
tags:
keywords:
archives: 2021-01
---

[この記事]({{< ref "../AWS DeepRacer: Driven by Reinforcement Learningをやってみた/index.md" >}})の続き

大体の流れは

1. レースゲームを作る。
2. 各パラメータ、関数の調整。
3. 強化学習モデルにゲームを遊ばせる。
4. クリア。できなければ 2 に戻る

となりそう。

見ていて気になった、参考になりそうなもの

- [Gym](https://gym.openai.com/) OpenAI が出している強化学習を試すためのツールキット
  - [openai/retro: Retro Games in Gym](https://github.com/openai/retro) これだと、題材がレトロゲームになってたりしておもしろい
- [強化学習入門 ～これから強化学習を学びたい人のための基礎知識～ - Platinum Data Blog by BrainPad](https://blog.brainpad.co.jp/entry/2017/02/24/121500) OpenAI Gym で Q 学習という単語が出てきてよくわからなかったので調べたら出てきた。Q 値は、状態価値の事で、Q 学習は**Q 値を学習するためのアルゴリズムの一つ**であるらしい。Q 値を学習するためのアルゴリズムは、他に Sarsa、モンテカルロ法、deep Q-network（DQN）等がある。
  - DQN の開発元は DeepMind 社らしい。ただ DeepMind 社が開発した AlphaGo とかは使っていない。[Google が出した囲碁ソフト「AlphaGo」の論文を翻訳して解説してみる。 - 7rpn’s blog: うわああああな日常](http://7rpn.hatenablog.com/entry/2016/06/10/192357)

### ここまできて

Web で動く事を目標にしてたけど、道が長いのでとりあえず OpenAIGym で強化学習を学ぶことに方針転換する。
