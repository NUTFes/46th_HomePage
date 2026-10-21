#!/usr/bin/env bash
# 新しい環境で、非公開リポジトリ（.git-private）を公開側の clone に復元する。
# 先に NUTFes/46th_HomePage を clone しておく。既存のファイルは上書きしない。
set -eu

cd "$(git rev-parse --show-toplevel)"
url=${PRIVATE_URL:-git@github.com:naoto-anzai/46th_HomePage-private.git}

if [[ -e .git-private ]]; then
  echo "NG: .git-private が既にある" >&2
  exit 2
fi

git clone --bare -q "$url" .git-private
printf '# 非公開側は scripts/sync-private.sh が git add -f したものだけ追跡する\n*\n' >> .git-private/info/exclude
scripts/pgit config core.bare false
scripts/pgit config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
scripts/pgit fetch -q origin
scripts/pgit checkout -q main
scripts/pgit branch -q --set-upstream-to=origin/main main
scripts/pgit status -sb
