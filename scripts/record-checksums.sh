#!/usr/bin/env bash
# Records the SHA-256 values of a media-tools release into RainyDM's MediaToolManifest.cs.
# usage: record-checksums.sh checksums.txt path/to/MediaToolManifest.cs
# checksums.txt has one "<sha256>  <file name>" line per file (the output of sha256sum).
set -euo pipefail

checksums=${1:?checksums.txt}
manifest=${2:?MediaToolManifest.cs}

updated=0
while read -r sha file; do
  [ -z "${sha:-}" ] && continue
  file=${file#\*}
  if ! [[ "$sha" =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "skipping '$file': not a SHA-256" >&2
    continue
  fi
  # new("<rid>", Version, Tag, "<file>", "<sha or empty>", "<exe>"); dots in the name match only dots
  name=$(printf '%s' "$file" | sed 's/[.[\*^$/]/\\&/g')
  if grep -q "\"$name\", \"[0-9A-Fa-f]*\"" "$manifest"; then
    sed -i.bak -E "s/(\"$name\", \")[0-9A-Fa-f]*(\")/\1${sha^^}\2/" "$manifest"
    rm -f "$manifest.bak"
    echo "recorded $file"
    updated=$((updated + 1))
  else
    echo "not in the manifest: $file" >&2
  fi
done < "$checksums"

echo "$updated checksum(s) recorded in $manifest"
