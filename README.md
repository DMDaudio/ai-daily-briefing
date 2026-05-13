# AI Daily Briefing Site

Static HTML page that renders a rolling archive of AI daily briefings for Georgia Capital. The page loads `briefings.json` at runtime, so updates only need to overwrite that one file.

## Files

| File | Purpose |
|---|---|
| `index.html` | Single-page renderer. No build step. Loads `briefings.json` via fetch. |
| `briefings.json` | Array of briefings, newest first. This is the only file the daily task touches. |
| `push-briefing.ps1` | PowerShell helper. Takes a path to a fresh `briefings.json`, copies it in, commits, and pushes. |
| `.gitignore` | Ignores local scratch files. |

## One-time setup

1. Create a new public repo on GitHub. Suggested name: `ai-daily-briefing`.
2. Clone it locally. Suggested path: `C:\Files\VibeCoding\ai-daily-briefing`.
3. Copy `index.html`, `briefings.json`, `push-briefing.ps1`, and `.gitignore` into the clone.
4. Initial commit and push to `main`.
5. In the repo's **Settings -> Pages**, set Source to `Deploy from a branch`, Branch `main` / `/ (root)`. Save.
6. After a minute the site will be live at `https://<your-username>.github.io/ai-daily-briefing/`.

If you'd rather keep the site reachable only by people who know the URL, leave the repo public but skip linking it anywhere. The URL is not indexed unless you submit it.

## How the daily scheduled task updates the site

The existing `daily-ai-briefing` scheduled task already writes a fresh briefings entry into the local artifact each day. To also publish to GitHub, append one extra step to the task:

1. Build the new briefing JSON object (already done in step 7a of the task).
2. Read the repo's `briefings.json`, prepend or replace the new entry (idempotent on re-runs), write it back.
3. Run `push-briefing.ps1 -RepoPath "C:\Files\VibeCoding\ai-daily-briefing" -Date "YYYY-MM-DD"`.

See `SKILL-update-instructions.md` in the same delivery folder for the exact diff to add to the task's SKILL.md.

## Git credentials

For the auto push to work unattended, configure one of:

- **HTTPS with credential manager.** Run `git config --global credential.helper manager` once. The first push opens a browser to authenticate; after that pushes are silent.
- **SSH key.** Generate with `ssh-keygen -t ed25519`, add the public key to your GitHub account under **Settings -> SSH and GPG keys**, set the repo remote to the `git@github.com:...` form.

SSH is more reliable for headless scheduled runs.

## Manual update (sanity check)

To push a one-off update without the scheduled task:

```powershell
cd C:\Files\VibeCoding\ai-daily-briefing
# edit briefings.json by hand or replace from elsewhere
git add briefings.json
git commit -m "Manual briefing update"
git push
```

GitHub Pages rebuilds in 30 to 60 seconds.

## Switching hosts later

The page is fully static, so any static host works. Drop the folder into Netlify, Cloudflare Pages, S3, or Vercel without changes. Only the `briefings.json` fetch path needs to be relative for hosts that serve from a subpath.
