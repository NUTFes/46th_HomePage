#!/usr/bin/env bash
# 非公開リポジトリ（.git-private）の追跡対象を、docs のタグ（local-only / redact）に合わせる。
# 追加・除外をステージするだけで、コミットと push はしない。続けて scripts/pgit commit / push を使う。
set -eu

cd "$(git rev-parse --show-toplevel)"
source scripts/docs-tags-lib.sh

if [[ ! -d .git-private ]]; then
  echo "NG: .git-private がない。先に git --git-dir=.git-private init -b main を実行する" >&2
  exit 2
fi

while IFS= read -r -d '' file; do
  tags=$(doc_tags "$file")
  if has "$tags" local-only || has "$tags" redact; then
    scripts/pgit add -f -- "$file"
  elif scripts/pgit ls-files --error-unmatch -- "$file" > /dev/null 2>&1; then
    scripts/pgit rm -q --cached -- "$file"
    echo "非公開側の追跡から外した: $file"
  fi
done < <(doc_files)

scripts/pgit status --short
