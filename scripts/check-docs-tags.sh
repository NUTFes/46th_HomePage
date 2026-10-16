#!/usr/bin/env bash
# docs/*.md の frontmatter タグが docs/TAGS.md の規則に従っているかを確認する。
# 違反があれば内容を表示して終了コード 1 で終わる。
set -u

cd "$(git rev-parse --show-toplevel)" || exit 2

readonly VOCAB=" pii internal-link copyrighted org-internal unreviewed handover meeting draft survey reference prev-year publish local-only redact "
readonly RISK=" pii internal-link copyrighted org-internal unreviewed "
errors=0

fail() {
  echo "NG: $1: $2"
  errors=$((errors + 1))
}

has() { [[ " $1 " == *" $2 "* ]]; }

while IFS= read -r -d '' file; do
  name=$(basename "$file")
  [[ "$name" == "TAGS.md" ]] && continue

  line=$(awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} /^tags:/ {print; exit}' "$file")
  if [[ -z "$line" ]]; then
    fail "$name" "frontmatter に tags がない"
    continue
  fi
  tags=$(echo "$line" | sed -E 's/^tags:[[:space:]]*\[//; s/\][[:space:]]*$//; s/,/ /g')

  keep=()
  risks=()
  for t in $tags; do
    if ! has "$VOCAB" "$t"; then
      fail "$name" "未定義のタグ: $t"
    fi
    if has " publish local-only redact " "$t"; then keep+=("$t"); fi
    if has "$RISK" "$t"; then risks+=("$t"); fi
  done

  if [[ ${#keep[@]} -ne 1 ]]; then
    fail "$name" "保管方針のタグ(publish/local-only/redact)がちょうど1つではない: ${keep[*]:-なし}"
    continue
  fi

  if git check-ignore -q "$file"; then ignored=1; else ignored=0; fi
  case "${keep[0]}" in
    publish)
      [[ ${#risks[@]} -gt 0 ]] && fail "$name" "publish だが公開判断のタグがある: ${risks[*]}"
      [[ $ignored -eq 1 ]] && fail "$name" "publish だが .gitignore で除外されている"
      ;;
    local-only | redact)
      [[ $ignored -eq 0 ]] && fail "$name" "${keep[0]} だが .gitignore に入っていない"
      ;;
  esac

  grep -qF "\`$name\`" docs/TAGS.md || fail "$name" "docs/TAGS.md の資料一覧にない"
done < <(find docs -maxdepth 1 -name '*.md' -print0 | sort -z)

if [[ $errors -eq 0 ]]; then
  echo "OK: docs のタグはすべて規則どおり"
else
  echo "$errors 件の違反"
  exit 1
fi
