---
title: Macのセットアップでやること
date: 2019-10-25T17:44:59+09:00
categories: 
- Mac
archives: 2019-10
---

## これはなに

新しいMacを手に入れたり、初期化した際にすることのメモ

## 最初にする事

- ソフトウェア・アップデート
- App store
  - magnetをインストール
  - すべてをアップデート

## システム環境設定系

### ネットワーク

- 適宜Wi-Fi、優先でつなぐ

### Dock

- 位置を左に
- 自動的に表示/非表示にチェック
- 不要なアプリをDockから除いておく

### トラックパッド

- `スクロールの方向: ナチュラル`以外のすべてのチェックボックスをオン
- 軌跡の速さをやや速めに設定

### デスクトップとスクリーンセーバ

- ホットコーナーに画面ロックを追加

### ディスプレイ

- Night Shift
  - 全日かかるように開始終了時刻設定
  - 今日の終了設定時刻までオンするをチェック

### キーボード

※ GoogleIMEのインストールと、外部キーボードの接続を終えてから

- 外部キーボード設定
- 入力ソースをGoogleIMEのひらがなと英数のみにする

### Mission Control

- キーボードとマウスのショートカットのMission Controlにマウスボタン3を割り当てる

### サウンド

- メニューバーに音量を表示をチェック

### iCloud・インターネットアカウント

- 適宜ログイン

### 日付と時刻

- 日付を表示にチェック

## アプリケーション

### 最初にすること

- `xcode-select --install`でxcodeを更新する
- dotfilesをクローンする。`git clone https://github.com/MamoruMachida/dotfiles $HOME/dotfiles`
- 設定スクリプトを実行する。`sh ~/dotfiles/init_osx.sh`
  - スクリプトは完璧ではないので適宜確認しつつ
- 再起動

### 言語系〇〇env

- 何かしらコマンド利用がある`nodenv`は必須
  - `nodenv install --list` で適宜良さそうなバージョンを決める
  - `nodenv install {version} && nodenv global {version}`

### iTerm

- 設定ファイルを読み込む
  - General > Preferences の設定ファイルを置くフォルダを`~/dotfiles`にして再起動
- Hotkey Window を有効にする
  - Keys > Hotkey からホットキーウィンドを作成する

### 入力ソース

- IME等インストールが済んでいるので、システム環境設定のキーボード > 入力ソースを変更する
- vim用のカスタムキー設定をする
  - ![GoogleIMEのカスタムキー設定](/img/2019-10-29-22-09-59.png)
