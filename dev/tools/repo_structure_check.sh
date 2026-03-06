#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

errors=0

allowed_root_entries=(
  ".editorconfig"
  ".gitattributes"
  ".github"
  ".gitignore"
  "AGENTS.md"
  "Makefile"
  "README.md"
  "addons"
  "content"
  "default_bus_layout.tres"
  "dev"
  "docs"
  "icon.svg"
  "icon.svg.import"
  "main_theme.tres"
  "project.godot"
  "references"
  "runtime"
)

allowed_references_entries=(
  "README.md"
  "slay_the_spire_cn"
  "tutorial_baseline"
)

required_paths=(
  "README.md"
  "docs/repo_conventions.md"
  "runtime"
  "runtime/scenes"
  "runtime/modules"
  "runtime/global"
  "content"
  "content/art"
  "content/characters"
  "content/enemies"
  "content/effects"
  "content/custom_resources"
  "dev/tools"
  "docs/roadmap"
  "docs/roadmap/README.md"
  "docs/archive"
  "docs/session"
  "docs/session/task_plan.md"
  "docs/session/findings.md"
  "docs/session/progress.md"
  "references"
)

deprecated_paths=(
  "plan"
  "scenes"
  "modules"
  "global"
  "art"
  "characters"
  "enemies"
  "effects"
  "custom_resources"
  "tools"
  "task_plan.md"
  "findings.md"
  "progress.md"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "[repo-structure-check] missing required path: $path" >&2
    errors=$((errors + 1))
  fi
done

for path in "${deprecated_paths[@]}"; do
  if [[ -e "$path" ]]; then
    echo "[repo-structure-check] deprecated root path still exists: $path" >&2
    errors=$((errors + 1))
  fi
done

root_entries=()
while IFS= read -r entry; do
	[[ -z "$entry" ]] && continue
	root_entries+=("$entry")
done < <(
	{
		git -c core.quotepath=false ls-files
		git -c core.quotepath=false ls-files --others --exclude-standard --directory --no-empty-directory
	} | sed '/^$/d' | cut -d/ -f1 | sort -u
)

for entry in "${root_entries[@]}"; do
	allowed=0
	for expected in "${allowed_root_entries[@]}"; do
		if [[ "$entry" == "$expected" ]]; then
			allowed=1
			break
		fi
	done

	if [[ "$allowed" -ne 1 ]]; then
		echo "[repo-structure-check] unexpected root entry: $entry" >&2
		errors=$((errors + 1))
	fi
done

tracked_local_state="$(git -c core.quotepath=false ls-files | rg '^(\.godot/|\.claude/|\.cursor/|\.ruff_cache/)|(^|/)\.DS_Store$' || true)"
if [[ -n "$tracked_local_state" ]]; then
	echo "[repo-structure-check] local state files must not be tracked:" >&2
	echo "$tracked_local_state" >&2
	errors=$((errors + 1))
fi

if [[ -d "references" ]]; then
	reference_entries=()
	while IFS= read -r entry; do
		[[ -z "$entry" ]] && continue
		reference_entries+=("$entry")
	done < <(find references -maxdepth 1 -mindepth 1 | sed 's#^references/##' | sort)

	for entry in "${reference_entries[@]}"; do
		allowed=0
		for expected in "${allowed_references_entries[@]}"; do
			if [[ "$entry" == "$expected" ]]; then
				allowed=1
				break
			fi
		done

		if [[ "$allowed" -ne 1 ]]; then
			echo "[repo-structure-check] unexpected references entry: references/$entry" >&2
			errors=$((errors + 1))
		fi
	done
fi

if [[ "$errors" -gt 0 ]]; then
  echo "[repo-structure-check] failed with $errors issue(s)." >&2
  exit 1
fi

echo "[repo-structure-check] passed."
