# Neovim (LazyVim) 操作ガイド

このリポは [LazyVim](https://www.lazyvim.org/) ベースの Neovim 設定に移行済み。
ターミナル内だけで VS Code 的な開発体験ができることを目指している。

このガイドは「VS Code は使えるけど vim はあまり知らない」状態から、
**ガイドを横に置きながら 1〜2 週間使えば慣れる** くらいの分量に絞ってある。
読み物として全部覚える必要はない。**まず最初に "Day 1 必修" だけ覚えて、
あとは詰まったタイミングで該当章を引く** スタイルで使ってほしい。

---

## 目次

1. [初回起動](#初回起動)
2. [モード概念 (vim を使ったことが無い人向け)](#モード概念)
3. [Day 1 必修 — これだけ覚えれば操作できる](#day-1-必修)
4. [ファイルを開く・探す](#ファイルを開く探す)
5. [ファイル間移動 (Harpoon, バッファ, タブ)](#ファイル間移動)
6. [編集系 — ジャンプ, 検索, 置換](#編集系)
7. [LSP — 補完, 定義ジャンプ, リネーム, リファクタ](#lsp)
8. [Git 操作](#git-操作)
9. [ターミナル統合 / tmux 連携](#ターミナル統合)
10. [Claude Code との併用パターン](#claude-code-との併用)
11. [プラグインの追加・削除・カスタマイズ](#プラグインのカスタマイズ)
12. [トラブルシュート](#トラブルシュート)
13. [チートシート (印刷推奨)](#チートシート)

---

## 初回起動

```sh
nvim
```

初回は LazyVim が自動で:

1. `~/.local/share/nvim/lazy/lazy.nvim` を clone
2. すべてのプラグインを並列ダウンロード (進捗 UI が表示される)
3. Treesitter parser をビルド
4. Mason が LSP サーバ / formatter をダウンロード

すべて終わったら `q` で UI を閉じる。**プラグインインストール中は何もせず待つ** こと。
2 回目以降は瞬時に起動する。

LSP やフォーマッタのインストール状況を見るには `:Mason` を開く。
プラグインを更新するには `:Lazy update` または `:Lazy sync`。

---

## モード概念

vim には複数のモードがある。これが vim 最大の壁。
最低限これだけ知っていれば動ける:

| モード | 入り方 | 何ができる | 抜け方 |
|---|---|---|---|
| **Normal** | (デフォルト) | カーソル移動, 削除, ヤンク, コマンド | (このモードがホーム) |
| **Insert** | `i`, `a`, `o`, `I`, `A`, `O` | 文字を打ち込む | `Esc` または `Ctrl+[` |
| **Visual** | `v` (文字), `V` (行), `Ctrl+v` (矩形) | 範囲選択 | `Esc` |
| **Command** | `:` | `:w`, `:q`, `:Telescope` などコマンド実行 | `Esc` または `Enter` |

**重要**: VS Code で「カーソルを置いて文字を打つ」感覚が Insert モード。
それ以外の操作 (移動, コピー, 削除等) は **Normal モードに戻ってから** やる。

最初は混乱するが、**Esc を頻繁に押す癖** をつけると慣れる。
Caps Lock を Esc にリマップする人が多い (このリポでは Karabiner でやる想定)。

---

## Day 1 必修

これだけ覚えれば 1 日使い物になる。リーダーキーは **スペース**。

### ファイル操作
| キー | 動作 |
|---|---|
| `<space><space>` | ファイル検索 (VS Code の `Cmd+P`) |
| `<space>/` | プロジェクト全文検索 (VS Code の `Cmd+Shift+F`) |
| `<space>e` | ファイルツリー (左サイドバー) を開く/閉じる |
| `<space>w` | 現在のファイルを保存 |
| `<space>bd` | 現在のバッファを閉じる |
| `<space>qq` | nvim を終了 |

### 移動
| キー | 動作 |
|---|---|
| `h j k l` | 左下上右に 1 文字/行 |
| `w` / `b` | 単語の先頭へ進む/戻る |
| `0` / `$` | 行頭 / 行末 |
| `gg` / `G` | ファイル先頭 / 末尾 |
| `Ctrl+d` / `Ctrl+u` | 半画面下/上 (中央寄せ) |
| `<C-h/j/k/l>` | 隣の split / tmux ペインへ |

### 編集
| キー | 動作 |
|---|---|
| `i` | カーソル位置から挿入モード |
| `a` | カーソルの 1 文字後ろから挿入 |
| `o` / `O` | 下/上に新規行を追加して挿入 |
| `x` | カーソル位置の 1 文字削除 |
| `dd` | 1 行カット |
| `yy` | 1 行コピー (yank) |
| `p` / `P` | カーソルの後/前にペースト |
| `u` | undo |
| `Ctrl+r` | redo |

### LSP (覚えると一気に世界が変わる)
| キー | 動作 |
|---|---|
| `gd` | 定義へジャンプ |
| `gr` | 参照一覧 |
| `K` | カーソル下のシンボルにホバー (型情報, ドキュメント) |
| `<space>cr` | リネーム (refactor rename) |
| `<space>ca` | コードアクション (auto-import 等) |
| `]d` / `[d` | 次/前の診断 (lint エラー) へジャンプ |

### Git
| キー | 動作 |
|---|---|
| `<space>gg` | LazyGit を開く (フル機能 git TUI) |
| `<space>gb` | 現在行の git blame |

### 検索系 (Telescope)
| キー | 動作 |
|---|---|
| `<space>sk` | 全キーマップを fuzzy 検索 (**何ができるか分からない時の救命ボタン**) |
| `<space>sh` | nvim ヘルプを fuzzy 検索 |
| `<space>sc` | コマンド履歴 |

> **覚えにくくなったら `<space>sk` を押せばそこから何でも引ける。**
> これだけ覚えていれば「キー忘れた…」で詰まらない。

---

## ファイルを開く・探す

LazyVim は **Telescope** を中心にあらゆる検索ができる。

| キー | 何を探す |
|---|---|
| `<space><space>` | git 管理下のファイル名 |
| `<space>fF` | git 管理外も含む全ファイル |
| `<space>fr` | 最近開いたファイル (recent) |
| `<space>/` | プロジェクト全体の文字列 grep (ripgrep ベース) |
| `<space>fb` | 開いているバッファ一覧 |
| `<space>ss` | LSP シンボル一覧 (このファイル内の関数/クラス) |
| `<space>sS` | LSP ワークスペース全体のシンボル |
| `<space>fc` | nvim 設定ファイルを編集 |

Telescope の中では:
- `Ctrl+j` / `Ctrl+k` または矢印で候補を移動
- `Enter` で開く
- `Ctrl+x` / `Ctrl+v` で水平/垂直 split で開く
- `Ctrl+t` で新しいタブで開く
- `Esc` でキャンセル

---

## ファイル間移動

VS Code のタブに相当するのは nvim では **バッファ**。

### バッファ
| キー | 動作 |
|---|---|
| `<S-h>` | 前のバッファ |
| `<S-l>` | 次のバッファ |
| `<space>bd` | 現在のバッファを閉じる |
| `<space>bD` | 強制閉じる (未保存破棄) |
| `<space>bb` | 直前のバッファに戻る |
| `<space>fb` | バッファ一覧から選ぶ |

### Harpoon (ピン留めジャンプ — VS Code に無い便利機能)

頻繁に行き来するファイルを 1〜4 番に「ピン留め」して、1 キーで切り替える機能。
プロジェクトで触る中心ファイル 4 つ程度を登録すると劇的に速くなる。

| キー | 動作 |
|---|---|
| `<space>H` | 現在のファイルを Harpoon に追加 |
| `<space>h` | Harpoon メニューを開く (登録中ファイル一覧) |
| `<space>1` | スロット 1 のファイルにジャンプ |
| `<space>2` | スロット 2 |
| `<space>3` | スロット 3 |
| `<space>4` | スロット 4 |

### ファイルツリー (neo-tree)
| キー | 動作 |
|---|---|
| `<space>e` | 開く / 閉じる |
| `<space>E` | 現在のファイル位置で開く |

ツリー内では:
- `j/k` 上下移動
- `Enter` 開く
- `a` 新規ファイル/フォルダ作成
- `d` 削除
- `r` リネーム
- `c` コピー
- `x` カット
- `p` ペースト
- `H` 隠しファイル表示切替
- `?` ヘルプ

---

## 編集系

### 移動・テキストオブジェクト

vim の最大の強みは **「動詞 + 対象」で編集を表現する** こと。

例: `ciw` = **C**hange **I**nside **W**ord = カーソル下の単語を変更

| 動詞 | 意味 |
|---|---|
| `c` | change (削除して insert に入る) |
| `d` | delete |
| `y` | yank (copy) |
| `v` | visual select |

| 対象 (テキストオブジェクト) | 意味 |
|---|---|
| `iw` | inner word (単語の中身) |
| `aw` | a word (単語 + 前後の空白) |
| `i"` `a"` | "" の中身 / "" 含む |
| `i(` `a(` | () の中身 / () 含む |
| `it` `at` | HTML タグの中身 / タグ含む |
| `ip` `ap` | パラグラフ |

組み合わせ例:
- `ci"` = `""` の中身を変更
- `da(` = `()` 含む全削除
- `yip` = パラグラフをコピー
- `vip` = パラグラフを選択

これを覚えると編集スピードが 3 倍になる。

### 検索・置換
| キー | 動作 |
|---|---|
| `/word` | 下方向に検索 |
| `?word` | 上方向に検索 |
| `n` / `N` | 次 / 前の一致 |
| `*` | カーソル下の単語を検索 |
| `<space>nh` | 検索ハイライトをクリア |
| `:s/old/new/g` | 現在行の置換 |
| `:%s/old/new/g` | ファイル全体置換 |
| `:%s/old/new/gc` | 確認しながら置換 |

### マルチカーソル相当
LazyVim には組み込みのマルチカーソルは無いが、**`flash.nvim`** で代替できる:
- `s` を押すと画面内の任意の文字 2 個入力でジャンプ
- visual モードで `S` で同様

慣れると VS Code の Cmd+D 連打よりむしろ速い。

---

## LSP

LSP (Language Server Protocol) で言語ごとに補完・診断・リファクタが効く。
LazyVim では Mason で LSP サーバを管理する。

### よく使う LSP キー
| キー | 動作 |
|---|---|
| `gd` | 定義へジャンプ |
| `gD` | 宣言へジャンプ |
| `gr` | 参照一覧 (Telescope で開く) |
| `gI` | 実装へジャンプ |
| `gy` | 型定義へジャンプ |
| `K` | ホバー (型情報, ドキュメント) |
| `<space>ca` | コードアクション (import, fix, refactor) |
| `<space>cr` | シンボルリネーム |
| `<space>cf` | フォーマット |
| `]d` / `[d` | 次 / 前の診断 |
| `<space>cd` | 行の診断詳細 |
| `<space>xx` | 全診断を Trouble に表示 |

### Mason で LSP サーバを追加する

```vim
:Mason
```

UI が開く。`i` で installable 一覧。`Enter` でインストール/アンインストール。
言語拡張 (`lazyvim.plugins.extras.lang.*`) を有効にしていれば、その言語の
LSP サーバは自動で入る。手動追加したい時だけ `:Mason` を使う。

---

## Git 操作

### LazyGit (推奨)

```
<space>gg
```

これで LazyGit が開く。**git CLI を直接叩く必要はほぼ無くなる**。

LazyGit 内のキー (一部):
- `Tab` / `[` / `]` でタブ切替 (Status, Files, Branches, Commits, Stash)
- `Space` でファイルをステージ/アンステージ
- `c` でコミット (エディタが開く)
- `P` で push, `p` で pull
- `b` でブランチメニュー
- `?` でヘルプ

### nvim 内の git 機能 (gitsigns)
| キー | 動作 |
|---|---|
| `]h` / `[h` | 次 / 前の hunk へジャンプ |
| `<space>ghs` | hunk をステージ |
| `<space>ghr` | hunk をリセット (変更を捨てる) |
| `<space>ghp` | hunk をプレビュー |
| `<space>gb` | 現在行の blame |
| `<space>ghd` | diff ビューを開く |

---

## ターミナル統合

### nvim 内のターミナル
| キー | 動作 |
|---|---|
| `<C-/>` | フローティングターミナルを開く / 閉じる |
| `<C-_>` | 同上 (端末によってはこっち) |
| `<space>fT` | 新規ターミナル (フローティング) |
| `<space>ft` | ターミナル (root dir) |

ターミナル内で Normal モードに戻る: `<C-\><C-n>`

### tmux ペインとの連携

`vim-tmux-navigator` で **`Ctrl+h/j/k/l` が nvim の split と tmux のペインを区別なく行き来する**。
つまり以下のようなレイアウトを組めば、すべて Ctrl+方向で移動できる:

```
+--------------------+----------+
|                    |          |
|                    | Claude   |
|       nvim         | Code     |
|                    |          |
|                    |          |
+--------------------+----------+
|         shell / lazygit       |
+-------------------------------+
```

### tmux 主要キー (このリポの設定)

prefix は `C-b` (デフォルト)。

| キー | 動作 |
|---|---|
| `prefix + |` | 縦分割 (現在のディレクトリ継承) |
| `prefix + -` | 横分割 |
| `prefix + c` | 新ウィンドウ |
| `prefix + 1..9` | ウィンドウ切替 |
| `prefix + d` | デタッチ |
| `prefix + r` | tmux.conf 再読込 |
| `Ctrl+h/j/k/l` | ペイン移動 (vim と統合) |
| `prefix + [` | コピーモード (vi キー) |

---

## Claude Code との併用

推奨レイアウト:

```sh
# tmux セッション内で
tmux new-window -n code

# 縦に分割: 左 nvim、右 Claude Code
prefix + |
# 右ペインで:
claude
```

これで `Ctrl+h` / `Ctrl+l` でエディタと Claude を行き来できる。
nvim でファイルを編集 → Claude に「このファイル直して」と頼む → 戻って差分確認 → コミット、
というサイクルがマウスゼロで回る。

ファイルパスを Claude に渡したい時は nvim で `<space>fy` (または `:lua vim.fn.setreg('+', vim.fn.expand('%:p'))`) で
絶対パスをクリップボードにコピーできる。

将来的に nvim と Claude Code をもっと密に統合したくなったら、
`lua/plugins/user.lua` の `claudecode.nvim` セクションをコメント解除すると
バッファの内容を直接送れるようになる。

---

## プラグインのカスタマイズ

### 新しいプラグインを追加

`~/.dotconfig/nvim/lua/plugins/user.lua` にエントリを追加:

```lua
return {
  -- 既存のプラグイン...

  {
    "github/copilot.vim",  -- 例: GitHub Copilot
    event = "InsertEnter",
  },
}
```

保存して `:Lazy sync` を実行すると LazyVim が自動でインストールする。

### LazyVim の language extra を追加

`lua/config/lazy.lua` の `spec` テーブルに 1 行追加:

```lua
{ import = "lazyvim.plugins.extras.lang.haskell" },
```

利用可能な extras: https://www.lazyvim.org/extras

### キーマップを追加

`lua/config/keymaps.lua` に追記:

```lua
vim.keymap.set("n", "<leader>x", function() print("hi") end, { desc = "Say hi" })
```

### 設定オプションを変更

`lua/config/options.lua` に追記:

```lua
vim.opt.colorcolumn = "100"
```

### 既存のプラグインをカスタマイズ

`lua/plugins/user.lua` で **同じプラグイン名で再宣言** すると `opts` がマージされる:

```lua
{
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      layout_strategy = "vertical",
    },
  },
},
```

---

## トラブルシュート

### `:checkhealth`
nvim の全プラグインの健全性をチェック。最初に困ったらこれ。

### `:Lazy`
プラグインの状態 UI。インストール失敗、更新待ち、ロード時間などが見える。
- `U` で全更新
- `S` で sync (lock ファイル通りに揃える)
- `X` で選択プラグインを clean

### `:Mason`
LSP / formatter / linter / DAP の管理 UI。
- `i` でインストール一覧
- `Enter` でインストール / アンインストール

### `:LspInfo`
今のバッファに紐づく LSP の状態。LSP が動かない時はここで原因が分かる。

### よくある問題

**Q: `:Mason` で LSP が入らない**
A: 内部で `cargo` / `npm` / `go` 等が必要なツールがある。それらを brew で先に入れる。

**Q: nvim が遅い**
A: `:Lazy profile` で起動時間の内訳を見る。怪しいプラグインを `enabled = false` で外す。

**Q: 設定変更が反映されない**
A: nvim を再起動 (`<space>qq` → `nvim`)。`init.lua` の変更には再起動が必須。

**Q: 古いプラグインが残ってる**
A: `:Lazy clean`

---

## チートシート

スペース = leader。Esc は省略してある。

```
ファイル検索  : <space><space>
全文検索      : <space>/
ファイルツリー: <space>e
保存          : <space>w
終了          : <space>qq
バッファ閉じる: <space>bd

定義ジャンプ  : gd
参照一覧      : gr
ホバー        : K
リネーム      : <space>cr
コードアクション: <space>ca
診断ジャンプ  : ]d / [d

Harpoon追加   : <space>H
Harpoonメニュー: <space>h
Harpoon 1-4   : <space>1..4

LazyGit       : <space>gg
git blame行   : <space>gb
hunkステージ  : <space>ghs
hunkリセット  : <space>ghr

ペイン移動    : Ctrl+h/j/k/l (vim+tmux共通)
ターミナル    : Ctrl+/

検索ハイライトクリア: <space>nh
キーマップ全検索: <space>sk  ← 困ったらこれ

undo / redo   : u / Ctrl+r
編集対象      : ciw caw ci" ca( ci{ ...
削除対象      : diw daw di" da( ...
ヤンク対象    : yiw yip ...

行頭/末       : 0 / $
ファイル先頭/末: gg / G
半画面下/上   : Ctrl+d / Ctrl+u
```

---

## 学習リソース

- [LazyVim 公式](https://www.lazyvim.org/) — プラグイン一覧, デフォルトキーマップ, FAQ
- [vimtutor](https://github.com/vim/vim/blob/master/runtime/tutor/tutor) — `vimtutor` コマンドで起動。30 分の対話チュートリアル。**最初にこれをやるのが一番効率的**
- [Learn Vim For the Last Time: A Tutorial and Primer](https://danielmiessler.com/blog/vim/) — 1 時間で vim 哲学を理解
- [ThePrimeagen の YouTube](https://www.youtube.com/@ThePrimeagen) — Harpoon 作者。実践的な vim 動画が大量
- `<space>sh` で nvim ヘルプ全文検索 — 公式ヘルプは超充実してる

---

**最後に**: vim は最初の 1 週間が一番つらい。VS Code で 5 秒でできることが
30 秒かかる。でも 2 週間後には逆転する。**慣れれば確実に速くなる** ので、
最初の壁を諦めずに乗り越えてほしい。

困ったら `<space>sk` でキーマップを引く。これだけ覚えていれば、
このガイドを忘れても何とかなる。
