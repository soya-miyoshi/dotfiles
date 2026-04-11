# 移行計画: chezmoi + 1Password/Bitwarden 統合 & マルチ OS 対応

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
| **1Password** | 個人の secrets。Shell Plugin 優先、駄目ならテンプレート展開 |
| **Bitwarden** | 共有プロジェクト (個人開発で複数人共有) の secrets。Shell Plugin 無しなので常にテンプレート展開 |
| **private-dotfiles (別リポ)** | 段階的に廃止 |

## シークレット扱いの分類

| タイプ | 方式 | 具体例 |
|---|---|---|
| 1P Shell Plugin 対応 CLI | `op plugin init <tool>` | `aws`, `gh`, `glab`, `cargo publish`, `terraform` 等 |
| 1P にあるが生の env var が必要 | `.tmpl` + `onepasswordRead` | `ANTHROPIC_API_KEY`, `OPENAI_API_KEY` |
| Bitwarden (共有) | `.tmpl` + `bitwardenFields` | 共有プロジェクトの DB URL, API キー等 |
| 非機密 | そのままコミット | OS 分岐、alias、キーバインド |

**原則**: ディスクに平文の secret を書かないで済む方法 (Shell Plugin) を最優先する。テンプレート展開が必要な場合は `~/.tokens` 等を `chmod 600` で配置する。

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

- `dot_zshrc.lazy.sh` (brew パス、`pbcopy` 等)
- `run_once_install_brew_packages.sh.tmpl` (mac は cask 含む、linux は方針未決)
- `executable_aws-console` (mac は `open`、linux は `xdg-open`)

## `.chezmoi.toml.tmpl` プロンプト設計

初回 `chezmoi init` で対話式に収集:

```toml
{{- $email := promptStringOnce . "email" "Email" "soya.miyoshi@gmail.com" -}}
{{- $name := promptStringOnce . "name" "Name" "Soya Miyoshi" -}}
{{- $useOnepassword := promptBoolOnce . "use_onepassword" "Use 1Password?" true -}}
{{- $useBitwarden := promptBoolOnce . "use_bitwarden" "Use Bitwarden (shared)?" false -}}
{{- $ci := env "CI" | not | not -}}

[data]
  email = {{ $email | quote }}
  name = {{ $name | quote }}
  use_onepassword = {{ $useOnepassword }}
  use_bitwarden = {{ $useBitwarden }}
  ci = {{ $ci }}
```

ポイント:

- **CI では secrets 無しで apply が通る** (`{{ if .use_onepassword }}` で分岐)
- `promptStringOnce` / `promptBoolOnce` は初回のみ尋ね、2 回目以降は再利用される
- 環境変数 `CI` の有無で自動判定

## 移行対象 (private-dotfiles → このリポ)

| 現在のファイル | 移行先 | 方式 |
|---|---|---|
| `.tokens` | `dot_tokens.tmpl` (→ `~/.tokens`) | 1P テンプレート展開、`chmod 600` |
| `.aws-default-profile` | `.chezmoi.toml.tmpl` のプロンプトに統合 | 変数として永続化 |
| `dot_zshrc.private` | `dot_zshrc.lazy.sh` に統合するか `dot_zshrc.local.tmpl` に | 中身次第 |
| AWS コンソールログインスクリプト | `dot_dotconfig/scripts/bin/executable_aws-console` | **1P Shell Plugin で素のまま** |
| `dot_zshrc.lazy.sh:54-56` の `source private-dotfiles/*` 行 | 削除 | |

## 段階的ロードマップ

### フェーズ 1: 土台作り (secrets 無しで動く状態)

1. `.chezmoi.toml.tmpl` を作成、プロンプトと CI 判定を実装
2. `dot_zshrc.lazy.sh` を `.tmpl` 化して OS 分岐導入
3. `private-dotfiles` 参照行を条件付きに (`{{ if not .ci }}`)
4. CI (既存の `.github/workflows/test-dotfiles.yml`) が secrets 無しでグリーンになることを確認

### フェーズ 2: 1P Shell Plugins 移行 (最も効果の高いもの)

5. `run_once_after_install_op_plugins.sh.tmpl` を追加 (`op plugin init aws` 等)
6. AWS コンソールログインスクリプトをこのリポに移動 (テンプレート化は不要)
7. `gh` CLI も同様に移行

### フェーズ 3: テンプレート展開が必要な secrets

8. `dot_tokens.tmpl` を作成 (1P から `ANTHROPIC_API_KEY` 等を取得)
9. `.aws-default-profile` を `.chezmoi.toml.tmpl` のプロンプト変数に統合
10. `dot_zshrc.private` の中身を確認し、会社固有/個人固有で振り分け

### フェーズ 4: Linux 対応の実働確認

11. `run_once_install_brew_packages.sh.tmpl` に Linux 分岐追加 (linuxbrew 前提か apt かを決める)
12. `Dockerfile.test` で CI を回し、Linux 側が apply 成功することを確認

### フェーズ 5: private-dotfiles 廃止

13. 全項目の移行を確認後、`dot_zshrc.lazy.sh` の `source private-dotfiles/*` を削除
14. private-dotfiles リポをアーカイブ

## 新マシンでのセットアップ (ゴール像)

ロードマップ完了後、新しい mac / linux マシンで以下のワンライナーで全復元できる状態を目指す:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply soya-miyoshi
```

必要な前提:

- 1Password CLI (`op`) でサインイン済み
- (共有プロジェクトに触る場合のみ) Bitwarden CLI (`bw`) でアンロック済み

## 未決事項 / 決めてほしいこと

1. **この順番で進めて OK?** それとも別の優先順位 (例: 先に AWS コンソールスクリプトだけやる)
2. **Linux は何を想定?** Ubuntu/Debian 系だけで OK? それとも Arch や Fedora も? (パッケージマネージャ分岐に影響)
3. **Linux でも brew を使う?** それとも apt 直で行く? (linuxbrew は遅い/重いが、mac と同じパッケージリストを使える)
4. **dev コンテナ (今 claude が動いている環境) は対象に含める?** 含めるなら CI とほぼ同じ扱い (secrets 無し apply)

## 参考リンク

- chezmoi templates: https://www.chezmoi.io/user-guide/templating/
- chezmoi + 1Password: https://www.chezmoi.io/user-guide/password-managers/1password/
- chezmoi + Bitwarden: https://www.chezmoi.io/user-guide/password-managers/bitwarden/
- 1Password Shell Plugins: https://developer.1password.com/docs/cli/shell-plugins/
