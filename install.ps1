# my-pstack installer for Claude Code on Windows (PowerShell).
# Same steps as install.sh: copy overlay skills, write the Claude-only model rule if absent.
$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillsDir = Join-Path $HOME ".claude\skills"
$rulesDir = Join-Path $HOME ".claude\rules"
$rulesFile = Join-Path $rulesDir "pstack-models.md"
$pluginsDir = Join-Path $HOME ".claude\plugins"

$found = $false
if (Test-Path $pluginsDir) {
  $found = (Get-ChildItem -Path $pluginsDir -Recurse -Filter SKILL.md -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*pstack*" -and $_.DirectoryName -like "*poteto-mode" }).Count -gt 0
}
if ($found) {
  Write-Host "[1/3] official pstack plugin found under $pluginsDir"
} else {
  Write-Host "[1/3] official pstack plugin not found. In Claude Code, run:"
  Write-Host "        /plugin marketplace add cursor/plugins"
  Write-Host "        /plugin install pstack@cursor-plugins"
  Write-Host "      (continuing anyway)"
}

Write-Host "[2/3] copying overlay skills to $skillsDir"
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
foreach ($s in @("my-mode", "spec-first", "unslop-ja", "requirements-interview")) {
  $dst = Join-Path $skillsDir $s
  if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
  Copy-Item -Recurse -Path (Join-Path $here "skills\$s") -Destination $dst
  Write-Host "      $s"
}

if (Test-Path $rulesFile) {
  Write-Host "[3/3] $rulesFile exists, left untouched. Compare with $here\config\pstack-models.md"
} else {
  Write-Host "[3/3] writing Claude-only model rule to $rulesFile"
  New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null
  Copy-Item -Path (Join-Path $here "config\pstack-models.md") -Destination $rulesFile
}

Write-Host ""
Write-Host "done. next:"
Write-Host "  1. restart Claude Code, type / and check my-mode appears"
Write-Host "  2. run /pstack:setup-pstack once if you have not"
Write-Host "  3. try: /requirements-interview"
