# docs タグ一覧

`docs/` の資料は、先頭の frontmatter に `tags: [...]` を付けて管理する。1つの資料に複数のタグを付けられる。
公開リポジトリに入れてよいかを、コミット前に `scripts/check-docs-tags.sh` で機械的に確認する。

## A. 公開判断のタグ（リスクの種類）

| タグ | 付ける基準 |
|---|---|
| `pii` | 実名・あだ名・連絡先など、個人を特定できる情報を含む |
| `internal-link` | Notion・Figma・Drive・Docs など、限定共有の内部リンクを含む |
| `copyrighted` | 書籍や他者の資料を転載・書き起こしている |
| `org-internal` | 実行委員会の内情（反省、運営の事情、他局への評価）を含む |
| `unreviewed` | 内容を確認できていない、または判断を保留している |

## B. 資料の性質のタグ

| タグ | 意味 |
|---|---|
| `handover` | 前年度から受け継いだ資料 |
| `meeting` | 議事録、MT資料 |
| `draft` | 作成途中で、確定前の資料 |
| `survey` | アンケート・ヒアリングの設問や集計 |
| `reference` | 外部の参考資料や、その要約 |
| `prev-year` | 45th 以前の資料。現行の方針ではない |

## C. 保管方針のタグ（人が決める。1資料に1つだけ）

| タグ | 意味 |
|---|---|
| `publish` | 公開リポジトリにコミットしてよい |
| `local-only` | ローカルにだけ残し、`.gitignore` で除外する |
| `redact` | 該当箇所を伏せれば公開できる。伏せるまではコミットしない（`.gitignore` で除外） |

規則:

- A のタグが1つでもある資料は `publish` にしない。
- `local-only` と `redact` の資料は `.gitignore` に入れる。
- `publish` の資料は `.gitignore` に入れない。
- `redact` の資料を伏せ終えたら、A のタグを外して `publish` に変える。

## 2つのリポジトリの運用

同じ作業フォルダを、2つの git で使い分ける。

| | 公開側 | 非公開側 |
|---|---|---|
| git ディレクトリ | `.git` | `.git-private`（公開側の `.gitignore` で除外） |
| remote | `NUTFes/46th_HomePage` | `naoto-anzai/46th_HomePage-private`（個人・private） |
| 追跡するもの | `publish` の資料と、コード・設定 | `local-only` と `redact` の資料 |
| 操作 | `git ...` | `scripts/pgit ...`（`git` と同じ使い方） |

手順:

1. 資料のタグを変えたら、`scripts/sync-private.sh` で非公開側の追跡対象をタグに合わせる。
2. 公開側の `.gitignore` の除外リストも、タグに合わせて直す。
3. `scripts/check-docs-tags.sh` で、タグと両側の追跡対象が一致していることを確認する。
4. 資料の変更は `scripts/pgit add` / `commit` / `push`、それ以外は `git` を使う。
5. `redact` の資料を伏せ終えて `publish` に変えるときは、非公開側から外し（`sync-private.sh`）、公開側に追加する。

内部メンバーへの共有は、非公開側の資料を Notion に書き出して行う。

## 資料の一覧（仮タグ。2026-10-17 時点）

| 資料 | タグ | 理由 |
|---|---|---|
| `Homepage2026引き継ぎ資料.md` | pii, internal-link, org-internal, handover, prev-year, redact | 実名1名とあだ名、Figma・Docs・Notion のリンク、前年度の反省 |
| `2026-10-08_HomePage_MT.md` | pii, internal-link, org-internal, meeting, redact | 参加者4名の実名、Notion・Figma・Drive のリンク |
| `45th HP のアンケートヒアリング まとめ.md` | pii, internal-link, org-internal, meeting, survey, prev-year, redact | あだ名、Figma・Drive のリンク、他局への評価の設問 |
| `45th_新執行部ヒアリング資料.md` | pii, internal-link, org-internal, survey, prev-year, redact | あだ名、Docs のリンク |
| `アンケート草稿.md` | pii, org-internal, survey, draft, redact | あだ名、配布先の運用方針 |
| `局別アンケート草稿.md` | pii, org-internal, survey, draft, redact | あだ名、各局の運用への評価の設問 |
| `ヒアリング見直し_MT資料.md` | org-internal, meeting, draft, reference, redact | 執行部ヒアリングの進め方の内部検討。付録に書籍の要点（言い換え）を含む |
| `デザインのためのヒアリング.md` | copyrighted, reference, local-only | 書籍本文のほぼそのままの抜粋 |
| `デザインのためのヒアリング_正本.md` | copyrighted, reference, local-only | 書籍48ページ分の書き起こし |
