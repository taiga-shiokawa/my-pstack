# my-pstack

Lauren Tan (poteto) の pstack を土台にした、自分用の上書き層。土台は変更しない。差分だけを持つ。

## 変えたこと

| 層 | 変更 | ファイル |
|---|---|---|
| ルーター | poteto-mode を全文読んでから、日本語・Claude 系・仕様ゲートの 3 つを上書き | `skills/my-mode/SKILL.md` |
| 文章規律 | 日本語版 unslop。ルール番号 101 から（元の 3 から 31 と衝突しない） | `skills/unslop-ja/SKILL.md` |
| 上位仕様 | 対話で要件定義書（目的、不変条件 R-xx、非目標、用語、決定記録）を作るスキルとテンプレート | `skills/requirements-interview/` |
| 機能仕様 | 1 画面の仕様を「判定できる完了条件」として書くスキル。満たす R-xx を書く | `skills/spec-first/SKILL.md` |
| プレイブック | Feature の前後に仕様の読み書きを足した 24 本目 | `skills/my-mode/playbooks/spec-driven-feature.md` |
| モデル | Claude 系のみを全役割に明示（`~/.claude/rules/` に置く）。パネルは視点を変えて多様性を作る | `config/pstack-models.md` |

## 変えていないこと

24 の原則、23 のプレイブック、how / why / arena / interrogate などの機能スキルは上流のまま使う。上流は Claude Code の `/plugin` で本家マーケットプレイスから入れるので、プラグインの更新だけで追従できる。

## インストール

1. Claude Code で本家 pstack を入れる（2026 年 10 月時点で公式に Claude Code 対応）

```
/plugin marketplace add cursor/plugins
/plugin install pstack@cursor-plugins
```

2. 上書き層を入れる

```
./install.sh        # macOS / Linux / Git Bash / WSL
.\install.ps1       # Windows PowerShell
```

PowerShell で `install.ps1` が実行ポリシーで拒否されたら `powershell -ExecutionPolicy Bypass -File .\install.ps1` で実行する。

3. Claude Code 内で `/pstack:setup-pstack` を一度実行し、`~/.claude/rules/pstack-models.md` のモデルを確認する。

本家のコマンドはプラグイン接頭辞付き（`/pstack:poteto-mode`、`/pstack:interrogate`）。my-pstack のスキルはユーザースキルなので `/my-mode`、`/spec-first` のまま。

## 使い方

```
/requirements-interview
/my-mode 仕様から始めて、CSV エクスポートに idempotency-key を足して
/my-mode この PR、スクロールが 750ms ごとにずれる。再現してから直して
/spec-first 通知の再送ロジック
```

## 仕様駆動と poteto の「最良の仕様はコード」の折り合い

仕様は 2 層。プロジェクトに 1 つの `docs/REQUIREMENTS.md`（不変条件と非目標が中心、100 行以内、変更は `docs/decisions/` の決定記録を伴う）と、機能ごとの `docs/specs/<slug>.md`。my-mode は作業前に上位仕様の不変条件と非目標だけを読み、矛盾する依頼では止まり、未記載の依頼は既定値で進めて報告する。

仕様を計画書にしない。書くのは「実行すれば真偽が分かる完了条件」「データの形（TypeScript の型）」「非目標」「検証スクリプトの場所」だけ。仕様だけの PR は作らず、実装と同じ PR に入れる。実験で決まることはユーザーに聞かず Prototype で決める。仕様で止まるのは、ユーザーが「承認してから進めて」と言ったときだけ。

## 自分の色をさらに足すには

1. しばらく `/my-mode` で作業する
2. `/reflect` で学びをスキル修正として残す
3. 同じ指摘を 2 回したら `/correct` でルールを構造（lint、型、CI）に落とす
4. 自分の原則が見えてきたら `skills/principle-<name>/SKILL.md` を足し、`my-mode/SKILL.md` の末尾に索引を 1 行追加する

## License

MIT. 上流 pstack © 2026 Lauren Tan (MIT)。
