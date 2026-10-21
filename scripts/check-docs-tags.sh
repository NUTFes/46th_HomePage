#!/usr/bin/env bash
# docs/*.md の frontmatter タグが docs/TAGS.md の規則に従っているかを確認する。
# 公開側の git に非公開の資料が入っていないこと、非公開側（.git-private）の追跡対象がタグと一致することも確認する。
# 違反があれば内容を表示して終了コード 1 で終わる。
set -u

cd "$(git rev-parse --show-toplevel)" || exit 2
source scripts/docs-tags-lib.sh

errors=0

fail() {
  echo "NG: $1: $2"
  errors=$((errors + 1))
}

while IFS= read -r -d '' file; do
  name=$(basename "$file")

  tags=$(doc_tags "$file")
  if [[ -z "$tags" ]]; then
    fail "$name" "tags がない（.md は frontmatter、それ以外は docs/TAGS.md の表に書く）"
    continue
  fi

  keep=()
  risks=()
  for t in $tags; do
    if ! has "$DOCS_VOCAB" "$t"; then
      fail "$name" "未定義のタグ: $t"
    fi
    if has " publish local-only redact " "$t"; then keep+=("$t"); fi
    if has "$DOCS_RISK" "$t"; then risks+=("$t"); fi
  done

  if [[ ${#keep[@]} -ne 1 ]]; then
    fail "$name" "保管方針のタグ(publish/local-only/redact)がちょうど1つではない: ${keep[*]:-なし}"
    continue
  fi

  if git check-ignore -q "$file"; then ignored=1; else ignored=0; fi
  if git ls-files --error-unmatch -- "$file" > /dev/null 2>&1; then public_tracked=1; else public_tracked=0; fi

  case "${keep[0]}" in
    publish)
      [[ ${#risks[@]} -gt 0 ]] && fail "$name" "publish だが公開判断のタグがある: ${risks[*]}"
      [[ $ignored -eq 1 ]] && fail "$name" "publish だが .gitignore で除外されている"
      ;;
    local-only | redact)
      [[ $ignored -eq 0 ]] && fail "$name" "${keep[0]} だが .gitignore に入っていない"
      [[ $public_tracked -eq 1 ]] && fail "$name" "${keep[0]} だが公開側の git が追跡している（git rm --cached が必要。履歴に残っていれば要対応）"
      if [[ -d .git-private ]]; then
        scripts/pgit ls-files --error-unmatch -- "$file" > /dev/null 2>&1 \
          || fail "$name" "${keep[0]} だが非公開側が追跡していない（scripts/sync-private.sh を実行する）"
      fi
      ;;
  esac

  grep -qF "\`$name\`" docs/TAGS.md || fail "$name" "docs/TAGS.md の資料一覧にない"
done < <(doc_files)

# 非公開側が、タグで決まった対象以外を追跡していないこと
if [[ -d .git-private ]]; then
  while IFS= read -r -d '' tracked; do
    tags=$(doc_tags "$tracked" 2> /dev/null || true)
    if ! has "$tags" local-only && ! has "$tags" redact; then
      fail "$tracked" "非公開側が追跡しているが、local-only / redact のタグがない"
    fi
  done < <(scripts/pgit ls-files -z)
fi

if [[ $errors -eq 0 ]]; then
  echo "OK: docs のタグ、公開側・非公開側の追跡対象はすべて規則どおり"
else
  echo "$errors 件の違反"
  exit 1
fi
