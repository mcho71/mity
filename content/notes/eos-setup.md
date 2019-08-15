---
title: EOSIOのGettingStartedをやった
date: 2019-04-12T22:07:40+09:00
categories: 
- Blockchain
tags: 
- Blockchain
- EOSIO
keywords: 
- EOSIO
- EOS
- Blockchain
- C++
---

[EOSIO Developer Portal - EOSIO Development Documentation](https://developers.eos.io/)の[GETTING STARTED](https://developers.eos.io/eosio-home/docs)をやったので、振り返りなどを

## DEVELOPMENT ENVIRONMENT

CLIツールのインストールと、各CLIを使ってEOSチェーンを使うための手順を確認する工程

[1.2 Before You Begin](https://developers.eos.io/eosio-home/docs/setting-up-your-environment)に沿って、`eosio/eosio`をインストールすると、[nodeos](https://developers.eos.io/eosio-nodeos/docs)/[cleos](https://developers.eos.io/eosio-cleos/docs)/[keosd](https//developers.eos.io/keosd/docs)の3つのコマンドが追加される。それぞれノードの構築、ノードに対する問い合わせ、ウォレットの生成、を行うことができる。わかりやすい相関図が、[1.3 About the Stack](https://developers.eos.io/eosio-home/docs/how-it-all-fits-together)に記載されていたので、参考になった。

### ノードを立てたりする

このチュートリアルでは、nodeosでノードを立てる際には以下のコマンドを叩いていた。

```sh
nodeos -e -p eosio \
  --plugin eosio::producer_plugin \
  --plugin eosio::chain_api_plugin \
  --plugin eosio::http_plugin \
  --plugin eosio::history_plugin \
  --plugin eosio::history_api_plugin \
  --access-control-allow-origin='*' \
  --contracts-console \
  --http-validate-host=false \
  --verbose-http-errors >> nodeos.log 2>&1 &
```

ノードを立てる際には`--plugin`で拡張を追加することができるようだ。
他のオプションについてはnodeos自体に対するものと、プラグインに対するものとがある。
`--contracts-console`は`nodeos`に対して、`--http-validate-host=false`は、`eosio::http_plugin`に対してのオプションとなっている。

また、このオプションは`config.ini`に記述することもできる、書き方は、[Configuration](https://developers.eos.io/eosio-nodeos/v1.0/docs/configuration-file)を参考に。記述した際には`nodeos --config path/to/config.ini`などとして起動する。

また、ノードの停止方法の記載がなかったような気がする、止めたいときは`pkill nodeos`で止めていた。
また、チェーンを再構築する際には`--delete-all-blocks`を付与して立ち上げれば良い。

### ウォレットを作る

[1.6 Create Development Wallet](https://developers.eos.io/eosio-home/docs/wallets)のウォレット作成コマンドは以下のように記されていた。

```sh
cleos wallet create --to-console
```

実行してみると`default`は既に作成済みで、keyも忘れていたので新しい名前でウォレットを作成した。

```sh
cleos wallet create --to-console -n hoge
```

このコマンドは、`hoge`という名前のウォレットを作成している。
このようにウォレット作成した場合は以降の`cleos wallet`コマンドには大体`-n hoge`を付与していくことになる。
まずは、前項で発行したウォレットを、ユーザー`eosio`にインポートする。private keyの入力が求められ、ユーザー`eosio`のprivate keyを入力する必要がある。

若干前後するが、次項のアカウント`eosio`をウォレット`hoge`にインポートする。

```sh
cleos wallet import -n hoge
```

### アカウントを発行する

EOSチェーンを立ち上げると、`system user`の`eosio`というアカウントが自動で発行される。このアカウントを使って、新規アカウントを発行するような形になっている。
新規アカウントの発行は以下のコマンドで行っていた。

```sh
# cleos create account <creater> <new-account-name> <owner-key> <active-key (optional)>
cleos create account eosio bob <eosio private-key>
```

owner-key、active-keyに対しては、permissionが付与されており、owner-keyに対応する秘密鍵を知っていれば、active-keyの変更が可能。
active-keyが指定されていない場合はowner-keyと同一のものとなるが、実運用時には分けることを推奨していた。

## SMART CONTRACT DEVELOPMENT

コードに関しては深く理解していないので、分かり次第コミットしていきたい。

なんとなくの流れとしては、C++をwasmに変換して、前項で用意したアカウントに書き込み、CLI経由で実行/確認、という感じ。

トークンの発行は、EthereumのERC20に当たる`eosio.token`は公式リポジトリに用意されており、それを元に、必要な処理を付け足したりして行くことになるようだ。

## おわり

このチュートリアルをこなす分にはC++の知識はそこまで必要なさそうではあった。ただ、記法を全て理解しようとすると時間は掛かりそう、EOSに関わる部分を追っていきつつ、C++の知識を入れていく感じになりそう。

アカウントベースで、実行、変更の権限を複数の秘密鍵で管理できるのはいいなと思ってる。また、アカウントにEOSを持たせることで、スマートコントラクトの動作のためのCPUやメモリが確保されるらしい、ここらへんは実運用する場合は、把握する必要がありそう。