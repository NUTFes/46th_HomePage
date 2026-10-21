#!/usr/bin/env bash
# docs のタグを読むための共通関数。source して使う。

readonly DOCS_VOCAB=" pii internal-link copyrighted org-internal unreviewed handover meeting draft survey reference prev-year publish local-only redact "
readonly DOCS_RISK=" pii internal-link copyrighted org-internal unreviewed "

has() { [[ " $1 " == *" $2 "* ]]; }

# 引数のファイルの frontmatter から tags をスペース区切りで出力する。なければ何も出さない。
doc_tags() {
  local line
  line=$(awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} /^tags:/ {print; exit}' "$1")
  [[ -z "$line" ]] && return 0
  echo "$line" | sed -E 's/^tags:[[:space:]]*\[//; s/\][[:space:]]*$//; s/,/ /g'
}

# docs 直下の資料（TAGS.md を除く）を NUL 区切りで出力する。
doc_files() {
  find docs -maxdepth 1 -name '*.md' ! -name 'TAGS.md' -print0 | sort -z
}
