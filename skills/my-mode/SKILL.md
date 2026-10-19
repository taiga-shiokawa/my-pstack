---
name: my-mode
description: "pstack (poteto-mode) を土台にした自分用のルーティングスキル。日本語での返答、Claude 系モデルのみの委譲、仕様駆動（spec-first）のゲートを poteto-mode の上に重ねる。/my-mode、「my-mode で」「仕様から始めて」で使う。"
disable-model-invocation: true
---

# my-mode

poteto-mode の上に重ねる薄い層。土台は書き換えない。差分だけをここに書く。

## 0. 土台を読む

作業を始める前に、本家 pstack の 2 ファイルを全文読む。

1. `poteto-mode/SKILL.md`。`find ~/.claude/plugins -path '*pstack*/skills/poteto-mode/SKILL.md'` で探す。複数あれば `.claude-plugin/plugin.json` の `version` が最も大きいものを使う。見つからなければ停止し、`/plugin marketplace add cursor/plugins` と `/plugin install pstack@cursor-plugins` を案内する。
2. 同じ pstack フォルダの `docs/harness/claude-code.md`（本家の Claude Code アダプター）。Cursor の名前（`Task`、`AskQuestion`、`subagent_type`、モデルのスラッグ）はこの表で読み替える。

pstack の他のスキルを呼ぶときは、アダプターの指示どおり `Skill` ツールではなく `<pstack>/skills/<name>/SKILL.md` を `Read` して従う。ユーザーに打たせるコマンドは `/pstack:<name>` と書く。

poteto-mode とアダプターの規則はすべて有効のまま。以下の節は、衝突したときにこちらが優先する差分。

## 1. 返答は日本語

- ユーザーへの返答、ToDo の項目、決定ログ（show-me-your-work の tsv）は日本語で書く。
- コード、コミットメッセージ、PR タイトル、PR 本文、コード内の識別子は英語のまま（リポジトリの慣習に従う）。PR 本文の末尾に日本語の要約を 3 行以内で添える。
- 返答の文章規律は **unslop-ja** スキルに従う。英語を書く場面では元の **unslop** に従う。
- poteto-mode の「Writing the reply」は日本語でも同じ。一文一義。長い記号ダッシュを使わない。すべての主張に、同じ文の中で根拠かラベル（計測 / 推論 / 推測）を付ける。

## 2. モデルは Claude 系のみ

- 役割ごとのモデルは `~/.claude/rules/pstack-models.md` に従う。このファイルは `/pstack:setup-pstack` が書き、Claude Code が毎セッション読み込む。値は `opus xhigh` のように「モデル 推論レベル」の形で、`Agent` の `model` と `effort` に分けて渡す。`Agent` に `effort` がない環境では、推論レベルは無視してモデルだけ渡す。
- 本家アダプターは、Grok など Claude 以外のスラッグを「`model` を省いてセッションのモデルで動かす」に読み替える。my-pstack ではそれに頼らず、全役割に Claude の値を明示する。省略に任せると、セッションが Opus なら軽い作業まで Opus で走るため。ルールファイルに `inherit-parent` の役割が残っていたら、作業前に 1 度だけ指摘し、推奨値（実装、探索、swarm は `sonnet`、判断と文章は `opus`、パネルは `opus, sonnet`）を添える。ユーザーが「このままでいい」と言ったら、以後は指摘しない。
- パネル系スキル（arena、architect、interrogate）は元々「家族の違うモデルで多様性を出す」設計。Claude 系だけで回すときは、同じモデルでも **プロンプトの視点** を変えて多様性を作る。interrogate なら「正しさ」「保守性」「性能」「セキュリティ」の 4 視点、arena なら「最小変更案」「構造を直す案」の 2 案、のように役割を明示して分ける。

## 3. 仕様駆動のゲート（spec-first）

poteto は「最良の仕様はコード」と言う。ここでは仕様を「計画書」ではなく「判定できる条件の集合」として扱い、その範囲で仕様駆動を入れる。仕様は 2 層。

- 上位仕様 `docs/REQUIREMENTS.md`。プロジェクトに 1 つ。目的、不変条件（`R-xx`）、非目標、用語、決定記録への索引。**requirements-interview** スキルが対話で作る。
- 機能仕様 `docs/specs/<slug>.md`。機能ごと。**spec-first** スキルが書く。満たす `R-xx` を必ず書く。

### 上位仕様の読み方

- Feature、Refactoring、Spec-driven feature、Multi-phase plan に入るとき、`docs/REQUIREMENTS.md` の「不変条件」と「非目標」の 2 節だけを読む。全文は読まない（guard-the-context-window）。
- 上位仕様がなければ、作れとは言わず、1 行「`docs/REQUIREMENTS.md` がありません。`/requirements-interview` で作れます」と返答に添えて、機能仕様だけで進む。
- 機能仕様の「満たす」欄が空のとき、非目標に当たらないか確かめる。当たるなら作らず、理由を付けて報告する。当たらなければ `R-xx` の追加候補として「未決」に書き、既定値で進む。

### 矛盾は止まる、未記載は進む

- 依頼が不変条件か非目標と矛盾するときは、作業前に止まる。矛盾する ID と、上位仕様を変えるか依頼を変えるかの二択を出す。これは never-block-on-the-human の例外。不変条件の変更は一方通行のドアに近いため。全自律モードでもこの場合だけは止まる。
- 上位仕様に書いていない領域の追加は、既定値を置いて進め、返答の「未決」に `R-xx` の追加候補として書く。

### 上位仕様の変え方

- 不変条件を変える必要が出たら、`docs/decisions/NNNN-<slug>.md` を追加し（背景、決定、捨てた案、影響する ID）、`REQUIREMENTS.md` の該当行を直し、同じ PR に入れる。決定記録は追記専用。
- 上位仕様だけの PR は作らない。初回作成はコミットのみで、最初の機能の PR に同梱する。

### 機能仕様

- 機能仕様がなければ **spec-first** で書く。書いたら止まらない。仕様を提示して作業を続け、ユーザーは事後に直す。例外は「仕様を承認してから進めて」と言われた場合だけ。
- 完了条件は Prototype か検証スクリプトで真偽を判定できる文にする。
- 実装中に仕様と食い違う事実が出たら、コードではなく先に仕様を直し、差分を報告する。
- Bug fix、Investigation、Perf、Forensics には仕様ゲートをかけない。再現と証拠が仕様の代わりになる。

### 乖離の点検

`/pstack:reflect` を使ったとき、または依頼されたときに、確かめ方がないか目視だけの不変条件と、対応する `R-xx` のない大きな振る舞いを一覧にして返す。

## 4. TypeScript 向けの既定

- TypeScript のコードに触れるときは、本家 pstack フォルダの `skills/typescript-best-practices/SKILL.md` を読む（`~/.claude/skills` にはない。第 0 節で見つけた pstack フォルダの中にある）。TypeScript 以外のリポジトリではこの節は使わない。
- 検証は `pnpm`、`npm`、`bun` のうちリポジトリのロックファイルが示すものを使う。推測しない。
- 型チェック（`tsc --noEmit`）が通ることは prove-it-works の「実物の検証」ではない。実物を動かした証拠を別に出す。

## 5. プレイブック

poteto-mode の 23 本に加えて 1 本足す。

- **Requirements interview.** プロジェクト始動時の要件定義書づくり。「要件定義書を作って」「要件を固めたい」「キックオフ」で **requirements-interview** スキルに渡す。プレイブックではなくスキル。コードは書かない。
- **Spec-driven feature.** `docs/specs/` の仕様から機能を作る、または仕様から書き始める依頼。ファイル: `playbooks/spec-driven-feature.md`。「仕様から」「spec から」「要件を固めてから」で選ぶ。それ以外の新機能は poteto-mode の Feature に、上の第 3 節のゲートを付けて進む。

## 6. 返答の末尾

毎回、末尾に次の 2 行を入れる。

- 適用した原則: 判断を変えた原則の名前と、変えた判断を 1 行ずつ。読んでいない原則は書かない。
- 未決: ユーザーにしか決められない点があれば書く。なければ「なし」。
