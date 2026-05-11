#!/usr/bin/env bash
# Log consolidation engine
set -euo pipefail

CTX=".ctx"

python3 << 'PYEOF'
import os, re, datetime
from collections import Counter

ctx = ".ctx"
log_path = os.path.join(ctx, "log.md")
decisions_path = os.path.join(ctx, "decisions.md")

# --- Log consolidation ---
if os.path.exists(log_path):
    with open(log_path) as f:
        content = f.read()

    parts = content.split("## Activity History")
    if len(parts) == 2:
        history = parts[1]
        entries = [l.strip() for l in history.split("\n") if l.strip().startswith("- ")]

        if len(entries) >= 10:
            keywords = []
            for e in entries:
                after_dash = e.split("\u2014", 1)[-1] if "\u2014" in e else e
                words = re.findall(r"[a-z]+", after_dash.lower())
                keywords.extend(words)

            common = Counter(keywords).most_common(5)
            patterns = [f"- {word} (seen {count}x)" for word, count in common if count >= 2 and word not in ("session", "the", "and", "for", "ended", "paused")]

            patterns_section = "## Recent Patterns\n\n"
            if patterns:
                patterns_section += "\n".join(patterns) + "\n"
                patterns_section += f"\nLast consolidated: {datetime.date.today().isoformat()}\n"
            else:
                patterns_section += "<!-- No recurring patterns detected yet -->\n"

            keep = entries[-10:]
            archive_entries = entries[:-10]

            if archive_entries:
                archive_dir = os.path.join(ctx, "archive", "logs")
                os.makedirs(archive_dir, exist_ok=True)
                month = datetime.date.today().strftime("%Y-%m")
                archive_path = os.path.join(archive_dir, f"{month}.md")
                with open(archive_path, "a") as f:
                    f.write("\n".join(archive_entries) + "\n")
                print(f"Archived {len(archive_entries)} entries to {archive_path}")

            new_content = "# Log\n\n" + patterns_section + "\n## Activity History\n\n<!-- Append-only per-event entries (episodic memory) -->\n\n"
            new_content += "\n".join(keep) + "\n"

            with open(log_path, "w") as f:
                f.write(new_content)
            print(f"Consolidated log: {len(patterns)} patterns promoted, {len(keep)} entries kept")
        else:
            print(f"Log has {len(entries)} entries (< 10) — skipping consolidation")
    else:
        print("Log format unexpected — skipping")

# --- Decisions consolidation ---
decisions_dir = os.path.join(ctx, "decisions")
if os.path.isdir(decisions_dir):
    adrs = [f for f in os.listdir(decisions_dir) if f.endswith(".md") and not f.startswith("_")]
    if len(adrs) >= 10 and os.path.exists(decisions_path):
        themes = {}
        for adr in sorted(adrs):
            adr_path = os.path.join(decisions_dir, adr)
            with open(adr_path) as f:
                c = f.read()
            title_match = re.search(r"title:\s*(.+?)$", c, re.MULTILINE)
            title = title_match.group(1).strip().strip("\"'") if title_match else adr[:-3]
            status_match = re.search(r"status:\s*(\w+)", c)
            status = status_match.group(1) if status_match else "active"
            themes.setdefault("General", []).append((adr[:-3], title, status))

        lines = ["# Decisions \u2014 Consolidated Summary", "",
                 f"Last consolidated: {datetime.date.today().isoformat()}", "",
                 "## Active Decisions", ""]
        superseded_lines = ["", "## Superseded Decisions", ""]

        for theme, decisions in sorted(themes.items()):
            for did, title, status in decisions:
                if status in ("superseded", "deprecated"):
                    superseded_lines.append(f"- ~~{title}~~ [{did}]")
                else:
                    lines.append(f"- **{title}** [{did}, {status}]")

        lines.extend(superseded_lines)
        with open(decisions_path, "w") as f:
            f.write("\n".join(lines) + "\n")
        print(f"Consolidated {len(adrs)} decisions into decisions.md")
    else:
        print(f"Decisions: {len(adrs)} ADRs — skipping")
else:
    print("No decisions/ ADRs — skipping")
PYEOF
