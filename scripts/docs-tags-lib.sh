#!/usr/bin/env bash
# docs のタグを読むための共通関数。source して使う。

readonly DOCS_VOCAB=" pii internal-link copyrighted org-internal unreviewed handover meeting draft survey reference prev-year publish local-only redact "
readonly DOCS_RISK=" pii internal-link copyrighted org-internal unreviewed "

has() { [[ " $1 " == *" $2 "* ]]; }

# 引数のファイルのタグをスペース区切りで出力する。なければ何も出さない。
# .md は frontmatter から、それ以外（.pptx など）は docs/TAGS.md の資料一覧の表から読む。
doc_tags() {
  local line name
  if [[ "$1" == *.md ]]; then
    line=$(awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} /^tags:/ {print; exit}' "$1")
    [[ -z "$line" ]] && return 0
    echo "$line" | sed -E 's/^tags:[[:space:]]*\[//; s/\][[:space:]]*$//; s/,/ /g'
  else
    name=$(basename "$1")
    awk -F'|' -v n="\`$name\`" '
      { c = $2; gsub(/^ +| +$/, "", c) }
      c == n { t = $3; gsub(/^ +| +$/, "", t); gsub(/,/, " ", t); print t; exit }
    ' docs/TAGS.md
  fi
}

# docs 直下の資料（TAGS.md を除く）を NUL 区切りで出力する。
doc_files() {
  find docs -maxdepth 1 -type f ! -name 'TAGS.md' -print0 | sort -z
}
