#!/usr/bin/env bash
# Promote CHANGELOG.md's [Unreleased] section to a release heading and update the
# compare links. An empty [Unreleased] is filled from commit subjects since the
# previous tag (release-plugin commits excluded). Run from the repository root.
#
# Usage: promote-changelog.sh <version> [<date>]   (date defaults to today, UTC)
set -euo pipefail

version=${1:?usage: $0 <version> [<date>]}
date=${2:-$(date -u +%F)}
file=${CHANGELOG:-CHANGELOG.md}
tag=v$version

fail() { echo "promote-changelog: $*" >&2; exit 1; }

grep -q '^## \[Unreleased\]' "$file" || fail "$file has no [Unreleased] heading"
! grep -q "^## \[$version\]" "$file" || fail "$file already has a [$version] section"
link=$(sed -n 's|^\[Unreleased\]: \(.*\)/compare/\(.*\)\.\.\.HEAD$|\1 \2|p' "$file")
[[ -n $link ]] || fail "$file has no [Unreleased]: <repo>/compare/<tag>...HEAD link"
read -r base prev <<<"$link"

notes=
if ! awk '/^## \[Unreleased\]/ { f = 1; next } f && /^(## |\[)/ { exit } f && NF { found = 1 }
        END { exit !found }' "$file"; then
    notes=$(git log --no-merges --format='- %s' --invert-grep --grep='^\[maven-release-plugin\]' \
        "$prev..HEAD")
    [[ -n $notes ]] || fail "nothing to release: [Unreleased] is empty and there are no commits since $prev"
fi

VERSION=$version DATE=$date TAG=$tag PREV=$prev BASE=$base NOTES=$notes awk '
    /^## \[Unreleased\]/ {
        print; print ""; print "## [" ENVIRON["VERSION"] "] - " ENVIRON["DATE"]
        if (ENVIRON["NOTES"] != "") { print ""; print "### Changed"; print ""; print ENVIRON["NOTES"] }
        next
    }
    /^\[Unreleased\]: / {
        print "[Unreleased]: " ENVIRON["BASE"] "/compare/" ENVIRON["TAG"] "...HEAD"
        print "[" ENVIRON["VERSION"] "]: " ENVIRON["BASE"] "/compare/" ENVIRON["PREV"] "..." ENVIRON["TAG"]
        next
    }
    { print }
' "$file" >"$file.tmp"
mv "$file.tmp" "$file"
