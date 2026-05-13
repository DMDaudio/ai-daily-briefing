# push-briefing.ps1
# Commits and pushes briefings.json from a local repo clone to GitHub.
#
# Usage:
#   .\push-briefing.ps1 -RepoPath "C:\Files\VibeCoding\ai-daily-briefing" -Date "2026-05-13"
#
# Assumes:
#   - The repo at RepoPath already has an up-to-date briefings.json on disk
#     (the scheduled task writes it before calling this).
#   - Git credentials are configured (credential manager or SSH key).

param(
    [Parameter(Mandatory = $true)]
    [string]$RepoPath,

    [Parameter(Mandatory = $true)]
    [string]$Date,

    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $RepoPath)) {
    Write-Error "Repo path not found: $RepoPath"
    exit 1
}

$jsonPath = Join-Path $RepoPath "briefings.json"
if (-not (Test-Path $jsonPath)) {
    Write-Error "briefings.json not found at $jsonPath. Write it before calling this script."
    exit 1
}

Push-Location $RepoPath
try {
    # Stage and check for changes
    git add briefings.json | Out-Null

    $diff = git diff --cached --name-only
    if (-not $diff) {
        Write-Host "No changes to briefings.json. Nothing to push."
        exit 0
    }

    $msg = "Daily AI briefing $Date"
    git commit -m $msg | Out-Null
    Write-Host "Committed: $msg"

    git push origin $Branch
    Write-Host "Pushed to origin/$Branch. GitHub Pages will rebuild within ~60 seconds."
}
finally {
    Pop-Location
}
