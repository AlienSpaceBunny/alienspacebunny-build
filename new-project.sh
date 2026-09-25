#!/usr/bin/env bash
# Create a new Maven project from template/, inheriting the current alienspacebunny-parent.
#
#   ./new-project.sh <artifactId> <java.package> [display name] [target dir]
#
# Example: ./new-project.sh widget com.alienspacebunny.widget "Widget"
# Target dir defaults to a sibling of this repository (../<artifactId>).
set -euo pipefail

usage() {
    sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 2
}

[[ $# -ge 2 && $# -le 4 ]] || usage
artifact=$1
package=$2
name=${3:-$artifact}
here=$(cd "$(dirname "$0")" && pwd)
target=${4:-$(dirname "$here")/$artifact}

[[ "$artifact" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "artifactId must match [a-z][a-z0-9-]*: $artifact" >&2; exit 2; }
[[ "$package" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$ ]] || { echo "invalid Java package: $package" >&2; exit 2; }
[[ "$name" != *'|'* && "$name" != *'\'* && "$name" != *'&'* ]] || { echo "display name may not contain | \\ or &" >&2; exit 2; }
[[ ! -e "$target" ]] || { echo "target already exists: $target" >&2; exit 1; }

# New projects start on the newest released parent (tag vX.Y.Z), never the -SNAPSHOT
# that parent/pom.xml carries between releases.
latest_tag=$(git -C "$here" tag -l 'v[0-9]*' --sort=-v:refname | head -1)
[[ -n "$latest_tag" ]] || { echo "no vX.Y.Z release tag found; run git fetch --tags" >&2; exit 1; }
parent_version=${latest_tag#v}
package_path=${package//.//}

cp -a "$here/template" "$target"

# Rename token paths deepest-first so parents are renamed after their children.
find "$target" -depth -name '*__*__*' | while read -r path; do
    base=$(basename "$path")
    base=${base//__ARTIFACT__/$artifact}
    base=${base//__PACKAGE_PATH__/$package_path}
    dest="$(dirname "$path")/$base"
    mkdir -p "$(dirname "$dest")"
    mv "$path" "$dest"
done

find "$target" -type f ! -name 'mvnw.cmd' ! -name 'mvnw' -print0 | xargs -0 sed -i \
    -e "s|__ARTIFACT__|$artifact|g" \
    -e "s|__PACKAGE__|$package|g" \
    -e "s|__NAME__|$name|g" \
    -e "s|__PARENT_VERSION__|$parent_version|g"

if leftover=$(grep -rlE '__(ARTIFACT|PACKAGE|PACKAGE_PATH|NAME|PARENT_VERSION)__' "$target"); then
    echo "unreplaced template tokens in: $leftover" >&2
    exit 1
fi

cat <<EOF
Created $target (alienspacebunny-parent $parent_version).
Next:
  cd $target
  git init && git config core.hooksPath .githooks
  ./mvnw verify
EOF
