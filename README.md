# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する macOS / Linux 用の dotfiles。

## ワンライナーセットアップ

新しい mac / Linux マシンで以下を実行するだけで、Homebrew → brew パッケージ → dotfiles 配置 → zinit / dein.vim インストールまで一発で完了する:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply soya-miyoshi
```

初回実行時にいくつかプロンプトが出る (email, 1Password を使うか、Bitwarden を使うか、デフォルト AWS profile)。

### シークレット連携

- 個人用シークレット (API トークン等) は **1Password**
- 共有プロジェクトのシークレットは **Bitwarden**

`op` / `bw` CLI がインストールされてサインイン済みであれば、`chezmoi apply` 時に自動取得される。CI / シークレットマネージャ無しで動かしたい場合:

```sh
CHEZMOI_NO_SECRETS=1 chezmoi apply
```

### 1Password Shell Plugins

`aws`, `gh` などの CLI を 1Password でラップして、credentials をディスクに書かずに使える:

```sh
op plugin init aws
op plugin init gh
```

`run_once_after_04_install_op_plugins.sh.tmpl` が初回 apply 時に対話的に走る (TTY がある場合)。

## このリポジトリ自体を開発する (dev container)

このリポは Claude Code 用の dev container を内蔵していて、別マシンでも同じ環境で開発できる。

### 初回セットアップ

```sh
git clone https://github.com/soya-miyoshi/dotfiles.git
cd dotfiles

# 1. .env を作る (.env.example を雛形に)
cp .env.example .env

# 2. 必要なら PROJECT_NUMBER を変更 (1-99、他プロジェクトと衝突しない値)
#    複数の devcontainer を平行で動かしたい場合はマシン内でユニークに

# 3. ポート番号を .env に埋める
./setup.sh

# 4. devcontainer を起動
docker-compose up -d

# 5. シェルに入る
./dev-exec.sh
```

`.env` 自体は `.gitignore` で除外されているので、マシン固有の設定 (PROJECT_NUMBER 等) を変えても commit 事故にならない。

### コンテナの中で dotfiles をテストする

```sh
make test-local       # /workspace に対して chezmoi apply (隔離 HOME で安全に)
make test-local-shell # 隔離 HOME を使った対話 zsh
```

## クリーンルームテスト (host から)

完全にまっさらな Ubuntu コンテナで Homebrew インストールから全部を E2E テストできる:

```sh
make test-clean       # フル E2E (~15-20 分、Apple Silicon の場合)
make test-clean-fast  # brew install をスキップした smoke test (~1-2 分)
make test-clean-shell # デバッグ用に対話シェル
```

詳細は [`TESTING.md`](./TESTING.md) を参照。

## CI

`.github/workflows/test-dotfiles.yml` で macOS / Linux (Docker) / Ubuntu (Native) の 3 環境で `chezmoi apply` をテストしている。

## ドキュメント

- [`NVIM_GUIDE.md`](./NVIM_GUIDE.md) — Neovim (LazyVim) の操作ガイド。VS Code から terminal IDE への移行用
- [`MIGRATION_PLAN.md`](./MIGRATION_PLAN.md) — chezmoi + 1Password/Bitwarden + LazyVim 移行プラン
- [`TESTING.md`](./TESTING.md) — Docker 経由のテスト手順

## Acknowledgement

[NagayamaRyoga/dotfiles](https://github.com/NagayamaRyoga/dotfiles) を多分に参考にしています。Thank you @NagayamaRyota for great scripts!
