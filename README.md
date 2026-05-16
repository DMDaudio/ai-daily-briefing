# AI Daily Briefing Site

Single-file static site that renders a rolling archive of daily AI news briefings. Hosted free on GitHub Pages, updated automatically each weekday by a scheduled task.

**Live URL:** https://dmdaudio.github.io/ai-daily-briefing/

## Architecture

One file holds everything: HTML, CSS, the renderer JS, and the briefings data array.

```
index.html
├─ <style> ... full styles ...
├─ <body> masthead, archive sidebar, main content
└─ <script>
 // === BRIEFINGS_DATA_START ===
 const briefings = [ ... ]; // newest first
 // === BRIEFINGS_DATA_END ===
 // renderer code
```

The daily task surgically replaces ONLY the array between the delimiters. Everything else (styles, layout, renderer) is preserved automatically.

## Repository layout

The repo lives inside the scheduled task folder so there's a single source of truth:

```
C:\Files\VibeCoding\Scheduled tasks\AI briefing\
├─ index.html [tracked] the public site
├─ README.md [tracked] this file
├─ .gitignore [tracked]
├─ SKILL.md [ignored] the scheduled task definition
├─ ai-briefing-*.md [ignored] daily markdown briefings
└─ ai-briefing-artifact.html [ignored] legacy artifact (no longer used)
```

The `.gitignore` keeps the task's private files (SKILL.md, daily markdowns) out of the public repo.

## Daily flow

1. Scheduled task runs each weekday at 12:00 Tbilisi time.
2. Researches AI news via WebSearch (5+ queries).
3. Writes daily markdown to `ai-briefing-YYYY-MM-DD.md`.
4. Reads existing `index.html`, parses the briefings array.
5. Prepends today's entry (or replaces if same date already exists).
6. Writes the merged HTML back to `index.html`.
7. Commits and pushes to GitHub.
8. GitHub Pages rebuilds in ~60 seconds.

See `SKILL.md` for the full task definition.

## One-time setup (for reference)

If you ever need to rebuild this from scratch:

1. Create a public GitHub repo `ai-daily-briefing` (private requires GitHub Pro for Pages).
2. Generate an SSH key and add the public key to your GitHub account.
3. Initialize git in the scheduled task folder, point origin at the repo, push `index.html`.
4. Enable GitHub Pages: Settings > Pages > Source: Deploy from a branch, Branch: `main`, Folder: `/ (root)`.
5. Wait ~60 seconds for the URL to appear.

## Manual update (sanity check)

```powershell
cd "C:\Files\VibeCoding\Scheduled tasks\AI briefing"
# edit index.html by hand
git add index.html
git commit -m "Manual update"
git push
```

GitHub Pages rebuilds in 30 to 60 seconds.

## Critical rules

1. **Preserve the archive.** Never write a single-entry array. If parsing the existing array fails, ABORT rather than wiping history.
2. **Push is required.** A failed push is a failed run. Retry once with `git pull --rebase`, then flag for intervention.
3. **No em-dashes** in any prose written into the briefings. Use commas or periods.
4. **Idempotent.** Re-running for the same date REPLACES the existing entry, never duplicates.

## Switching hosts later

The page is fully static and self-contained (zero external dependencies). Drop the file into Netlify, Cloudflare Pages, S3, Vercel, or any static host without changes.
