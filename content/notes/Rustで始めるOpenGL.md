---
title: 'Rustで始めるOpenGLをやっている'
date: 2019-11-12T15:23:06+09:00
categories:
  - Development
tags:
  - Rust
  - OpenGL
keywords:
  - Rust
  - OpenGL
archives: 2019-11
---

## これはなに

[[DL 版] Rust ではじめる OpenGL - toyamaguchi - BOOTH](https://toyamaguchi.booth.pm/items/1557536)をなぞった際のメモです。

## 目次を読む

ライブラリごとに章が区切られている

1. 環境準備
2. SDL
3. OpenGL
4. Dear ImGui
5. 3D オブジェクト
6. テクスチャ

ほとんど触れたことがないな、とりあえず上からやっていこう
ソースコード →[toyamaguchi/start_opengl_in_rust](https://github.com/toyamaguchi/start_opengl_in_rust)

## 環境

- [Rust Programming Language](https://www.rust-lang.org/)に従って Rust をインストール
  - version は 1.39 だった
  - crate は[crates.io: Rust Package Registry](https://crates.io/)で検索できる
  - VSCode の rls、rustup のパスを通してやる必要があった。`"rust-client.rustupPath": "~/.cargo/bin/rustup"`

## SDL

SDL は、グラフィックやサウンドの機能を持ったマルチメディアライブラリ。
[SDL - Wikipedia](https://ja.wikipedia.org/wiki/SDL)  
これだけでも十分な機能を持つゲームを作成可能らしい

Rust からの利用は`crate「sdl2」`を利用する。[Rust-SDL2/rust-sdl2: SDL2 bindings for Rust](https://github.com/Rust-SDL2/rust-sdl2)  
`sd12`は C 言語で書かれたライブラリを間接的に利用するラッパーのため SDL のインストールも必要。

SDL を使ってソフトに必要な構造を作って OpenGL で描画をしていく。基本的な構造とは、ウィンドウやメインループ、イベント処理のような部分。

### 準備

- [Rust-SDL2/rust-sdl2: SDL2 bindings for Rust](https://github.com/Rust-SDL2/rust-sdl2) の手順通り SDL をインストール
- `cargo.toml`に`sd12`を追加

### 作成

`sdl2`の crates.io ページを見る。

## OpenGL

SDL のウィンドウに描画していく

### 準備

`cargo.toml`に`gl`(OpenGL の API を利用可能に),`cgmath`(CG 用の数学関連機能),`c_str_macro`(C 言語とコンパチビリティんのある文字列型を生成できる`c_str!`マクロが使えるようになる)を追加

### 作成

HelloWorld は難しいらしいので三角形を描画する

シェーダーという言葉が出てきた

写経辛いのでコピペに切り替えていく

OpenGL3.1 を使う、このバージョンは丁度 API が一新されたバージョンで、`Core`(新しい API のみ)と`Compability`(古い API もサポート)パッケージがある。今回は`Core`

描画はシェーダと呼ばれる描画プログラムを通してデータを送る  
シェーダなしのサンプルコードは古い可能性があるので注意  
呼び名は  
あり: Programmable Pipeline  
なし: Fixed Function Pipeline  
などというらしい

シェーダは実行時にソースコードをコンパイルして使えるプログラムなのでこういった名称になってる

今回具体的には Vertex シェーダと Fragment シェーダを使った

#### Vertex シェーダ

Vertex はそもそも頂点のこと、辺と辺を結ぶ点。3D 空間内の頂点座標を画面上の座標にするまでに必要な計算をこのシェーダでやってる

描画したい頂点が、3D 空間の中でどの位置にあるのかを表すモデル行列  
カメラの一を考慮したビュー行列  
カメラから見た 3D 空間をどのように画面に描画するかを表す射影行列  
3 つの行列をかけ合わせて最終的な画面上の座標になる

#### Fragment シェーダ

色を計算するシェーダ、Vertex シェーダから座標を得てテクスチャの中から適切な位置の色情報を計算して描画につかう

どちらも GLSL を使って実装する。  
GLSL(OpenGL Shading Language)はシェーダ専用の言語、GPU や前段のシェーダからの情報、扱える変数に独特のルールがある。  
GPU での動作なので並列計算できる、画面上に多くの 3D オブジェクトを描画したいならシェーダを使って効果的に描画する必要がある。

GLSL のバージョンは 3.3

VBO(Vertex Buffer Object)は CPU から GPU に情報を渡すための入れ物、頂点データだったり色情報だったり  
VAO(Vertex Array Object)は VBO をどのようなまとまりで使うのかを設定するもの

WebGL の話ものってそう

サンプルコードが動かない → 動いた、sample リポジトリの rsc フォルダを追加すればよかっただけだった。章の最後に書いてあった。

```log
RUST_BACKTRACE=1 cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.03s
     Running `target/debug/rust-opengl`
OK: init OpenGL: version=3.1
thread 'main' panicked at 'failed to open file: rsc/shader/shader.vs', src/shader.rs:28:33
stack backtrace:
   0: backtrace::backtrace::libunwind::trace
             at /Users/runner/.cargo/registry/src/github.com-1ecc6299db9ec823/backtrace-0.3.37/src/backtrace/libunwind.rs:88
   1: backtrace::backtrace::trace_unsynchronized
             at /Users/runner/.cargo/registry/src/github.com-1ecc6299db9ec823/backtrace-0.3.37/src/backtrace/mod.rs:66
   2: std::sys_common::backtrace::_print_fmt
             at src/libstd/sys_common/backtrace.rs:76
   3: <std::sys_common::backtrace::_print::DisplayBacktrace as core::fmt::Display>::fmt
             at src/libstd/sys_common/backtrace.rs:60
   4: core::fmt::write
             at src/libcore/fmt/mod.rs:1030
   5: std::io::Write::write_fmt
             at src/libstd/io/mod.rs:1412
   6: std::sys_common::backtrace::_print
             at src/libstd/sys_common/backtrace.rs:64
   7: std::sys_common::backtrace::print
             at src/libstd/sys_common/backtrace.rs:49
   8: std::panicking::default_hook::{{closure}}
             at src/libstd/panicking.rs:196
   9: std::panicking::default_hook
             at src/libstd/panicking.rs:210
  10: std::panicking::rust_panic_with_hook
             at src/libstd/panicking.rs:473
  11: std::panicking::continue_panic_fmt
             at src/libstd/panicking.rs:380
  12: std::thread::local::fast::Key<T>::try_initialize
  13: rust_opengl::shader::Shader::new::{{closure}}
             at src/shader.rs:28
  14: core::result::Result<T,E>::unwrap_or_else
             at /rustc/4560ea788cb760f0a34127156c78e2552949f734/src/libcore/result.rs:818
  15: rust_opengl::shader::Shader::new
             at src/shader.rs:27
  16: rust_opengl::main
             at src/main.rs:52
  17: std::rt::lang_start::{{closure}}
             at /rustc/4560ea788cb760f0a34127156c78e2552949f734/src/libstd/rt.rs:64
  18: std::rt::lang_start_internal::{{closure}}
             at src/libstd/rt.rs:49
  19: std::panicking::try::do_call
             at src/libstd/panicking.rs:292
  20: __rust_maybe_catch_panic
             at src/libpanic_unwind/lib.rs:80
  21: std::panicking::try
             at src/libstd/panicking.rs:271
  22: std::panic::catch_unwind
             at src/libstd/panic.rs:394
  23: std::rt::lang_start_internal
             at src/libstd/rt.rs:48
  24: std::rt::lang_start
             at /rustc/4560ea788cb760f0a34127156c78e2552949f734/src/libstd/rt.rs:64
  25: rust_opengl::main
note: Some details are omitted, run with `RUST_BACKTRACE=full` for a verbose backtrace.
```

できた。
![](/img/2019-11-12-18-08-05.png)

頂点情報はこういう感じで書いていた

```rust
    // set buffer
    #[rustfmt::skip]
    let buffer_array: [f32; BUF_LEN] = [
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0,
        0.0, 1.0, 0.0,
    ];
```

## Dear ImGui

[ocornut/imgui](https://github.com/ocornut/imgui)

OpenGL に様々な GUI を追加できるライブラリ

これを使って SDL2 のウィンドウに新たにウィンドウを追加する。

出た

![](/img/2019-12-17-15-49-08.png)

![](/img/2019-12-17-15-59-28.png)

### 効果的な使い方

パラメータの微調節を行えるように、ここの値をスライダーで調節できるようにすると良いらしい
FPS を表示も
