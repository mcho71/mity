---
title: 'AWS DeepRacer: Driven by Reinforcement Learningをやってみた'
date: 2021-01-29T10:32:42+09:00
categories:
  - MachineLearning
tags:
  - AWS
  - Deep Racer
keywords:
archives: 2021-01
---

きっかけは、この動画を見て興味を持ったこと。

{{< youtube Aut32pR5PQA >}}  
まずはチュートリアルコンテンツを探してみようと思い、[リーグ - AWS DeepRacer | AWS](https://aws.amazon.com/jp/deepracer/league/)から、タイトルの[AWS DeepRacer: Driven by Reinforcement Learning | AWS トレーニングと認定](https://www.aws.training/Details/eLearning?id=32143)を見つけた。

日本語版もある。

DeepRacer 実機は、米 Amazon からの購入になる。
[Amazon.com: AWS DeepRacer Evo - Fully Autonomous 1/18th Scale Race Car for Developers: Amazon Devices](https://www.amazon.com/AWS-DeepRacer-Evo-Car-Sensor/dp/B081GZSJVL/ref=sr_1_1?dchild=1&keywords=deepracer+evo&qid=1606341498&sr=8-1)

AWS DeepRacer でモデルのトレーニングをすると 1 回、$7 はかかる。
[料金 - AWS DeepRacer | AWS](https://aws.amazon.com/jp/deepracer/pricing/?p=drl&exp=hl)

### それでは始めようと思う

強化学習が使われる。試行、評価、学習の繰り返し。コースを学習して周回できる事、その速さを競う事が DeepRacer の主目的。

#### DeepRacer で使われる用語

- Agent: Car 本体のこと
- Environment: 環境、Agent と Action、学習ループごとに新しく定義し直される
- Action : 進む方向やスピード
  - DescreteContinuous : 離散連続
- Reward: 報酬
  - Reward Function
- State: Car の状態
  - Partial State
  - Absolute State
    - Scalar
- Task
- Episode:　コースから外れてやり直しを行うと次のエピソードとして外れた場所からスタート
- Policy: 状態によってどのアクションを取るか決める。今回は NN,CNN である
  - Stochastically: 確率的
  - deterministically: 確定的、State と Action の関係をより直接的に決められる
  - 価値関数 V: 使うのは PRO アルゴリズム、近接ポリシー最適化アルゴリズム
    - StateAction

DeepRacer の裏では、Amazon SageMaker モデルの強化学習 と AWS RoboMaker 仮想空間と仮想環境を作成 が動いている。
SageMaker -> S3 -> RoboMaker -> Redis -> SageMarker

強化学習アルゴリズムを最適化するためのパラメータを指定していく

報酬関数は具体的に自分で書く、Basic/Advanced 選択できる。
報酬関数の評価

ハイパーパラメータ

- バッチサイズ　トレーニングデータの量
- エポック　バッチトレーニングセットを通る回数
- レート　最適探す時の細かさ
- Exploration 　探索と適用　ローカル最大に閉じ込められるのを防ぐ
- エントロピー　新しいアクションのランダム性が比例
- Discount Factor 　即時報酬を求めるか
- Loss Type
  - Huber Loss
  - 平均二乗誤差
- Number Of Episode 　エピソードの数

あとは AWS コンソールから DeepRacer を使って色々やるようだ
