# 移行計画: chezmoi + Bitwarden & マルチ OS 対応

## 背景と目的

現状の dotfiles 運用には以下の課題がある:

1. **chezmoi を活かせていない**: 実質シンボリックリンク管理ツールとしてしか使っておらず、テンプレート / シークレット統合 / OS 分岐といった本来の強みを使っていない。
2. **`$HOME/private-dotfiles/` という別リポを手動運用している**: API トークン類、AWS 認証、個人 alias などがここに入っていて、新しいマシンで復元するのに手動作業が必要。
3. **マルチ OS サポートが無い**: 現状は mac 前提。Linux でも使いたい。
4. **新しいマシンでコマンド一発で動かない**: エントリポイントが未定義。

このプランはこれらを一括で解決する。

## 全体戦略

| 層 | 役割 |
|---|---|
| **public dotfiles (このリポ)** | 全ファイルをテンプレート化可能。OS 分岐もここで |
| **Bitwarden** | すべての secrets。チーム共有の Bitwarden アカウント |
| **private-dotfiles (別リポ)** | 段階的に廃止 |

## シークレット扱いの分類

| タイプ | 方式 | 具体例 |
|---|---|---|
| Bitwarden | `.tmpl` + `bitwardenFields` / `bitwarden` | API キー、DB URL、各種 credential |
| 非機密 | そのままコミット | OS 分岐、alias、キーバインド |

**原則**: シークレットは平文でリポに入れず、`bw` CLI 経由で apply 時に取得 → `~/.tokens` (chmod 600) に展開する。

## OS 分岐

chezmoi のテンプレート変数 `{{ .chezmoi.os }}` で分岐する:

```gotemplate
{{ if eq .chezmoi.os "darwin" }}
# macOS 限定 (brew パス、pbcopy 等)
{{ else if eq .chezmoi.os "linux" }}
# Linux 限定 (Ubuntu/Debian 系想定)
{{ end }}
```

適用箇所:

- `dot_zshrc.lazy.sh.tmpl` (brew パス、`pbcopy` 等)
- `run_once_before_02_install_brew_packages.sh.tmpl` (mac は cask 含む、linux は formulae のみ)

## `.chezmoi.toml.tmpl` プロンプト設計

初回 `chezmoi init` で対話式に収集:

```gotemplate
{{- $email := promptStringOnce . "email" "Git email" "soya.miyoshi@gmail.com" -}}
{{- $name := promptStringOnce . "name" "Git name" "Soya Miyoshi" -}}
{{- $useBitwarden := promptBoolOnce . "use_bitwarden" "Use Bitwarden for secrets?" true -}}
{{- $awsDefaultProfile := promptStringOnce . "aws_default_profile" "Default AWS profile" "default" -}}
{{- $ci := env "CI" | empty | not -}}
{{- $noSecrets := or $ci (env "CHEZMOI_NO_SECRETS" | empty | not) -}}
```

ポイント:

- **`.ci`** = `CI=1` の時だけ true。brew install / dein 等の重い処理をスキップ。
- **`.no_secrets`** = `CI=1` または `CHEZMOI_NO_SECRETS=1` で true。Bitwarden の取得をスキップ。
- **CI では secrets 無しで apply が通る**
- `promptStringOnce` / `promptBoolOnce` は初回のみ尋ねて以後は値を再利用

## 移行対象 (private-dotfiles → このリポ)

| 現在のファイル | 移行先 | 方式 |
|---|---|---|
| `.tokens` | `private_dot_tokens.tmpl` (→ `~/.tokens`) | Bitwarden テンプレート展開、`chmod 600` |
| `.aws-default-profile` | `.chezmoi.toml.tmpl` のプロンプトに統合 | 変数として永続化 |
| `dot_zshrc.private` | `dot_zshrc.lazy.sh.tmpl` に統合するか別ファイルに分離 | 中身次第 |
| AWS コンソールログインスクリプト | `dot_dotconfig/scripts/bin/` | Bitwarden 展開 or env 変数経由 |
| `dot_zshrc.lazy.sh` の `source private-dotfiles/*` 行 | 削除 | |

## 段階的ロードマップ

### フェーズ 1: 土台作り (secrets 無しで動く状態) ✅

1. ✅ `.chezmoi.toml.tmpl` を作成、プロンプトと CI 判定を実装
2. ✅ `dot_zshrc.lazy.sh` を `.tmpl` 化して OS 分岐導入
3. ✅ `private-dotfiles` 参照行を条件付きに (`{{ if not .no_secrets }}`)
4. ✅ CI が secrets 無しでグリーン

### フェーズ 2: Bitwarden 連携 ⏳

5. ⏳ `private_dot_tokens.tmpl` に Bitwarden の `bitwardenFields` 呼び出しを追加
6. ⏳ `.aws-default-profile` を `.chezmoi.toml.tmpl` のプロンプト変数 `aws_default_profile` に統合 ✅
7. ⏳ `dot_zshrc.private` の中身を確認し、共通/個人/会社固有で振り分け
8. ⏳ `bw login` / `bw unlock` の手順を README に追記

### フェーズ 3: Linux 対応の実働確認 ✅

9. ✅ `run_once_before_02_install_brew_packages.sh.tmpl` に Linux 分岐追加
10. ✅ `Dockerfile.clean-test` を作成し、ローカルから E2E テスト可能に
11. ✅ CI (`.github/workflows/test-dotfiles.yml`) で Linux 側が apply 成功することを確認

### フェーズ 4: private-dotfiles 廃止 ⏳

12. ⏳ 全項目の移行を確認後、`dot_zshrc.lazy.sh.tmpl` の `source private-dotfiles/*` を削除
13. ⏳ private-dotfiles リポをアーカイブ

### フェーズ 5: ターミナル IDE 化 (LazyVim 移行) ✅

「VS Code を捨てて iTerm + tmux + nvim だけで開発する」目的の整理。

14. ✅ dein.vim → LazyVim 移行 (`dot_dotconfig/nvim/init.lua` ベース)
15. ✅ 言語拡張 (TS / JSON / YAML / Docker / Terraform / Go / Rust / Python / Markdown) を `lazy.lua` で有効化
16. ✅ Harpoon, vim-tmux-navigator を `lua/plugins/user.lua` に追加
17. ✅ tmux.conf を vim-tmux-navigator 対応に更新 (Ctrl+hjkl で nvim と tmux の境界を越える)
18. ✅ `lazygit`, `bat`, `eza`, `glow`, `yazi` を brew パッケージに追加
19. ✅ 操作ガイド `NVIM_GUIDE.md` を作成
20. ⏳ Karabiner で Caps Lock → Esc, Cmd+H 無効化 (これは Karabiner 設定リポ側)
21. ⏳ `claudecode.nvim` を試して必要なら有効化
22. ⏳ 1〜2 週間使ってキーバインドが体に馴染んだら customize

## 新マシンでのセットアップ (ゴール像)

ロードマップ完了後、新しい mac / linux マシンで以下のワンライナーで全復元できる状態を目指す:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply soya-miyoshi
```

必要な前提:

- (Bitwarden secrets を取り込みたい場合のみ) `bw` CLI でログイン + unlock 済み
  ```sh
  bw login
  export BW_SESSION=$(bw unlock --raw)
  ```

シークレット連携無しで動かしたい時は `CHEZMOI_NO_SECRETS=1 chezmoi apply`。

## 参考リンク

- chezmoi templates: https://www.chezmoi.io/user-guide/templating/
- chezmoi + Bitwarden: https://www.chezmoi.io/user-guide/password-managers/bitwarden/
