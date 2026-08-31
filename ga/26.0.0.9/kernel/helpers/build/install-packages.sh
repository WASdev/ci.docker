#!/bin/bash
# (C) Copyright IBM Corporation 2026.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Used in multi-stage Dockerfiles: --install stages package files + .so deps
# into /staging (builder); --copy installs missing files into the micro image.

set -Eeo pipefail

STAGING_DEFAULT="/staging"

usage() {
  echo "Usage: $0 --install <pkg> [<pkg> ...]  |  --copy [<from-dir>]" >&2
  exit 1
}

[ "$#" -eq 0 ] && usage

MODE="$1"; shift

## Normalise compat symlink prefixes so all paths land under /usr.
## /lib64/... -> /usr/lib64/...  etc.
normalise_path() {
  local p="$1"
  p="${p/#\/lib64\//\/usr\/lib64\/}"
  p="${p/#\/lib\//\/usr\/lib\/}"
  p="${p/#\/bin\//\/usr\/bin\/}"
  p="${p/#\/sbin\//\/usr\/sbin\/}"
  printf '%s' "$p"
}

## Run ldd and extract every resolved absolute library path.
collect_ldd_deps() {
  local binary="$1"
  ldd "$binary" 2>/dev/null \
    | awk '
      /=>/ && $3 ~ /^\// { print $3; next }
      $1 ~ /^\/[^ ]/ && !/=>/ { print $1 }
    ' \
    | grep -v '^$' || true
}

## Copy a path and every symlink hop in its chain into the staging dir.
## Handles .so, .so.1, .so.1.2.3 — any versioned name — transparently.
copy_to_staging() {
  local staging="$1" current="$2"

  [[ "$current" = /* ]] || { echo "WARNING: skipping non-absolute path: $current"; return; }

  local visited=()
  while true; do
    local v
    for v in "${visited[@]+"${visited[@]}"}"; do
      if [ "$v" = "$current" ]; then
        echo "WARNING: symlink loop at $current, stopping"
        return
      fi
    done
    visited+=("$current")

    if [ ! -e "$current" ] && [ ! -L "$current" ]; then
      echo "WARNING: path not found, skipping: $current"
      return
    fi

    mkdir -p "${staging}$(dirname "$current")"

    if [ -L "$current" ]; then
      local link_target dest_link
      link_target="$(readlink "$current")"
      dest_link="${staging}${current}"
      if [ ! -e "$dest_link" ] && [ ! -L "$dest_link" ]; then
        cp -P "$current" "$dest_link"
        echo "  symlink  $current -> $link_target"
      fi
      if [[ "$link_target" = /* ]]; then
        current="$link_target"
      else
        current="$(dirname "$current")/$link_target"
      fi
    elif [ -f "$current" ]; then
      local dest_file="${staging}${current}"
      if [ ! -e "$dest_file" ]; then
        cp -a "$current" "$dest_file"
        echo "  file     $current"
      fi
      break
    else
      break
    fi
  done
}

cmd_install() {
  [ "$#" -eq 0 ] && { echo "ERROR: --install requires at least one package name" >&2; exit 1; }

  local staging="${STAGING_DEFAULT}"
  local pre_install post_install diff_pkgs all_pkgs pkg f

  # Remove each package individually so a missing package doesn't skip the rest.
  # Ensures all requested packages appear in the post-install diff even if
  # already present in the builder image.
  echo "Removing packages (if present) before snapshotting: $*"
  for pkg in "$@"; do
    microdnf -y remove "$pkg" 2>/dev/null || true
  done

  echo "Snapshotting pre-install package list"
  pre_install="$(rpm -qa --queryformat '%{NAME}\n' | sort)"

  echo "Installing packages: $*"
  microdnf -y install "$@"
  microdnf clean all

  echo "Resolving newly installed packages"
  post_install="$(rpm -qa --queryformat '%{NAME}\n' | sort)"
  diff_pkgs="$(comm -13 <(echo "$pre_install") <(echo "$post_install") || true)"

  # Union: explicitly requested + any auto-pulled dependencies
  all_pkgs="$(printf '%s\n' "$@" $diff_pkgs | sort -u)"
  echo "Packages to stage: $(echo "$all_pkgs" | tr '\n' ' ')"

  # Collect every bin/lib file owned by those packages via rpm -ql.
  declare -A SEEN

  for pkg in $all_pkgs; do
    if ! rpm -q "$pkg" &>/dev/null; then
      echo "WARNING: package not found in RPM db, skipping: $pkg"
      continue
    fi
    while IFS= read -r f; do
      case "$f" in
        /usr/bin/*|/usr/sbin/*|/usr/libexec/*)
          [ -e "$f" ] && SEEN["$f"]=1 ;;
        /usr/lib64/*.so*|/usr/lib/*.so*)
          [ -e "$f" ] && SEEN["$f"]=1 ;;
      esac
    done < <(rpm -ql "$pkg" 2>/dev/null || true) || true
  done

  echo "RPM file list: ${#SEEN[@]} paths"

  # Snapshot keys each iteration to avoid iterating a live-modified map
  echo "Resolving transitive .so dependencies via ldd"
  local changed=1 path lib keys
  while [ "$changed" -eq 1 ]; do
    changed=0
    keys=("${!SEEN[@]}")
    for path in "${keys[@]}"; do
      [ -f "$path" ] || continue
      while IFS= read -r lib; do
        lib="$(normalise_path "$lib")"
        if [ -n "$lib" ] && [ -e "$lib" ] && [ -z "${SEEN[$lib]+x}" ]; then
          SEEN["$lib"]=1
          changed=1
        fi
      done < <(collect_ldd_deps "$path") || true
    done
  done

  echo "Total paths to stage after ldd expansion: ${#SEEN[@]}"
  echo "Staging into ${staging}"
  mkdir -p "${staging}"

  for path in "${!SEEN[@]}"; do
    copy_to_staging "$staging" "$path"
  done

  echo "Done. Staged files:"
  find "${staging}/usr/bin" "${staging}/usr/sbin" "${staging}/usr/libexec" \
    -type f 2>/dev/null | sed "s|${staging}||" | sort | while IFS= read -r f; do
    echo "  bin  $f"
  done || true
  find "${staging}/usr/lib64" "${staging}/usr/lib" \
    -type f -name '*.so*' 2>/dev/null | sed "s|${staging}||" | sort | while IFS= read -r f; do
    echo "  lib  $f"
  done || true
  echo "Total staged file count: $(find "${staging}" -type f | wc -l)"
}

cmd_copy() {
  local from_dir="${1:-${STAGING_DEFAULT}}"

  if [ ! -d "$from_dir" ]; then
    echo "ERROR: source directory not found: $from_dir" >&2
    exit 1
  fi

  echo "Copying missing files from ${from_dir} into /"

  local copied=0 skipped=0
  while IFS= read -r src; do
    local dest="${src#"${from_dir}"}"
    if [ -z "$dest" ]; then
      continue
    fi

    if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
      mkdir -p "$(dirname "$dest")"
      cp -a "$src" "$dest"
      echo "  copied  $dest"
      (( copied++ )) || true
    else
      (( skipped++ )) || true
    fi
  done < <(find "$from_dir" \( -type f -o -type l \) | sort)

  echo "Done. Copied: ${copied}, already present (skipped): ${skipped}"
}

case "$MODE" in
  --install) cmd_install "$@" ;;
  --copy)    cmd_copy    "$@" ;;
  *)         usage ;;
esac
