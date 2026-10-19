# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# `inherit-parent` or `auto` as a value: the role runs on the parent chat model (omit the subagent `model`). Alias entries in a panel list still count toward its fan-out.
# budget: large (xhigh)
#
# my-pstack template for Claude Code. Install path: ~/.claude/rules/pstack-models.md (no frontmatter).
# Format per the official adapter (docs/harness/claude-code.md): `<model> <effort>`, model in opus|sonnet|haiku|fable.
# Every role names a Claude model explicitly instead of relying on the adapter's "non-Claude slug -> session model" fallback.
# Panels list Claude twice or more on purpose. my-mode section 2 gives each entry a different reviewing lens.
feature, refactoring: sonnet xhigh
bug-fix: sonnet xhigh
perf-issue: sonnet xhigh
hillclimb: sonnet xhigh
judgment and prose: opus xhigh
hardest tasks: opus xhigh
how explorer: sonnet high
how explainer: opus xhigh
why investigators: sonnet high
why synthesizer: opus xhigh
reflect tooling: sonnet high
reflect judgment, divergent, synthesizer: opus xhigh
arena runners: opus xhigh, sonnet xhigh
arena cross-judge pool: opus xhigh, sonnet xhigh
swarm workers: sonnet high
architect runners: opus xhigh, sonnet xhigh
interrogate reviewers: opus xhigh, sonnet xhigh, sonnet xhigh, sonnet xhigh
