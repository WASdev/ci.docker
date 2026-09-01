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

# Used in multi-stage Dockerfiles: --install collects package files + .so deps
# into /tmp/pkg-files (builder); --copy copies missing files into the micro image.

if [ "${VERBOSE}" != "true" ]; then
  exec >/dev/null 2>&1
fi

set -Eeo pipefail

PKG_DIR="${PKG_DIR:-/tmp/pkg-files}"

usage() {
  echo "Usage: $0 --install <pkg> [<pkg> ...]  |  --copy [<from-dir>]" >&2
  exit 1
}

[ "$#" -eq 0 ] && usage

MODE="$1"; shift

# Normalise compat symlink prefixes so all paths land under /usr.
normalise_path() {
  local p="$1"
  p="${p/#\/lib64\//\/usr\/lib64\/}"
  p="${p/#\/lib\//\/usr\/lib\/}"
  p="${p/#\/bin\//\/usr\/bin\/}"
  p="${p/#\/sbin\//\/usr\/sbin\/}"
  printf '%s' "$p"
}

# Extract every resolved absolute library path from ldd output.
collect_ldd_deps() {
  ldd "$1" 2>/dev/null \
    | awk '
      /=>/ && $3 ~ /^\// { print $3; next }
      $1 ~ /^\/[^ ]/ && !/=>/ { print $1 }
    ' \
    | grep -v '^$' || true
}

# Copy a file and every symlink hop in its chain into PKG_DIR.
copy_to_pkg_dir() {
  local pkg_dir="$1" current="$2"

  [[ "$current" = /* ]] || { echo "WARNING: skipping non-absolute path: $current" >&2; return; }

  local visited=()
  while true; do
    local v
    for v in "${visited[@]+"${visited[@]}"}"; do
      if [ "$v" = "$current" ]; then
        echo "WARNING: symlink loop at $current, stopping" >&2
        return
      fi
    done
    visited+=("$current")

    if [ ! -e "$current" ] && [ ! -L "$current" ]; then
      echo "WARNING: path not found, skipping: $current" >&2
      return
    fi

    mkdir -p "${pkg_dir}$(dirname "$current")"

    if [ -L "$current" ]; then
      local link_target dest_link
      link_target="$(readlink "$current")"
      dest_link="${pkg_dir}${current}"
      if [ ! -e "$dest_link" ] && [ ! -L "$dest_link" ]; then
        cp -P "$current" "$dest_link"
        echo "  symlink  $current -> $link_target"
      fi
      if [[ "$link_target" = /* ]]; then
        current="$link_target"
      else
        current="$(realpath -m "$(dirname "$current")/$link_target")"
      fi
    elif [ -f "$current" ]; then
      local dest_file="${pkg_dir}${current}"
      if [ ! -e "$dest_file" ]; then
        cp -a "$current" "$dest_file"
        echo "  file     $current"
      fi
      break
    else
      echo "WARNING: unexpected file type, skipping: $current" >&2
      break
    fi
  done
}

cmd_install() {
  [ "$#" -eq 0 ] && { echo "ERROR: --install requires at least one package name" >&2; exit 1; }
  echo "-- install-packages --install $*"

  local pkg_dir="${PKG_DIR}"
  local pre_install post_install diff_pkgs all_pkgs pkg rpm_file

  echo "Updating image"
  microdnf -y update
  microdnf clean all

  # Remove individually so a missing package doesn't skip the rest; ensures
  # packages already in the builder image appear in the pre/post diff.
  for pkg in "$@"; do
    microdnf -y remove "$pkg" || true
  done

  pre_install="$(rpm -qa --queryformat '%{NAME}\n' | sort)"

  echo "Installing: $*"
  microdnf -y install "$@"
  microdnf clean all

  post_install="$(rpm -qa --queryformat '%{NAME}\n' | sort)"
  diff_pkgs="$(comm -13 <(echo "$pre_install") <(echo "$post_install") 2>&1)" || {
    echo "WARNING: comm failed resolving package diff, auto-deps may be incomplete: ${diff_pkgs}" >&2
    diff_pkgs=""
  }

  all_pkgs="$(printf '%s\n' "$@" "${diff_pkgs}" | sort -u)"
  echo "Packages to collect: $(echo "$all_pkgs" | tr '\n' ' ')"

  declare -A SEEN

  for pkg in $all_pkgs; do
    if ! rpm -q "$pkg" &>/dev/null; then
      echo "WARNING: package not found in RPM db, skipping: $pkg" >&2
      continue
    fi
    while IFS= read -r rpm_file; do
      case "$rpm_file" in
        /usr/bin/*|/usr/sbin/*|/usr/libexec/*)
          [[ "$rpm_file" == "/usr/sbin/init" ]] && continue
          [ -e "$rpm_file" ] && SEEN["$rpm_file"]=1 ;;
        /usr/lib64/*.so*|/usr/lib/*.so*)
          [ -e "$rpm_file" ] && SEEN["$rpm_file"]=1 ;;
      esac
    done < <(rpm -ql "$pkg" 2>/dev/null || true) || true
  done

  echo "Resolving transitive .so dependencies via ldd"
  local changed=1 path lib keys
  while [ "$changed" -eq 1 ]; do
    changed=0
    keys=("${!SEEN[@]}")
    for path in "${keys[@]}"; do
      [ -f "$path" ] || continue
      [[ "$(head -c 4 "$path" 2>/dev/null)" == $'\x7fELF' ]] || continue
      while IFS= read -r lib; do
        lib="$(normalise_path "$lib")"
        if [ -n "$lib" ] && [ -e "$lib" ] && [ -z "${SEEN[$lib]+x}" ]; then
          SEEN["$lib"]=1
          changed=1
        fi
      done < <(collect_ldd_deps "$path") || true
    done
  done

  echo "Total paths to collect: ${#SEEN[@]}"
  [[ "${#SEEN[@]}" -eq 0 ]] && echo "WARNING: nothing to collect — check package names and filters" >&2 || true

  mkdir -p "${pkg_dir}"
  for path in "${!SEEN[@]}"; do
    copy_to_pkg_dir "$pkg_dir" "$path"
  done

  echo "Total files: $(find "${pkg_dir}" -type f | wc -l)"
}

cmd_copy() {
  local from_dir="${1:-${PKG_DIR}}"


  if [ ! -d "$from_dir" ]; then
    echo "ERROR: source directory not found: $from_dir" >&2
    exit 1
  fi

  echo "Copying missing files from ${from_dir} into /"

  local copied=0 skipped=0 warned=0
  while IFS= read -r src; do
    local dest="${src#"${from_dir}"}"
    [ -z "$dest" ] && continue

    # Skip absolute-target symlinks whose target is absent from PKG_DIR.
    if [ -L "$src" ]; then
      local link_target
      link_target="$(readlink "$src")"
      if [[ "$link_target" = /* ]]; then
        if [ ! -e "${from_dir}${link_target}" ] && [ ! -L "${from_dir}${link_target}" ]; then
          echo "WARNING: symlink $dest -> $link_target has no target in PKG_DIR, skipping" >&2
          (( warned++ )) || true
          continue
        fi
      fi
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

  echo "Done. Copied: ${copied}, skipped: ${skipped}, warned: ${warned}"

  local dangling=0
  while IFS= read -r link; do
    echo "WARNING: dangling symlink in image: $link -> $(readlink "$link")" >&2
    (( dangling++ )) || true
  done < <(find / -xdev -type l ! -exec test -e {} \; -print 2>/dev/null || true)
  [ "$dangling" -gt 0 ] && echo "WARNING: ${dangling} dangling symlink(s) found after copy" >&2 || true
}

case "$MODE" in
  --install) cmd_install "$@" ;;
  --copy)    cmd_copy    "$@" ;;
  *)         usage ;;
esac
