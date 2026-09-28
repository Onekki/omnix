#!/usr/bin/env bash
set -euo pipefail

source_file=/etc/nixos/hardware-configuration.nix
profile=desktop
rebuild=true
interactive=true

usage() {
  printf 'Usage: %s [--source FILE] [--profile NAME] [--no-rebuild] [--non-interactive]\n' "$0"
}

while (($#)); do
  case "$1" in
    --source|--profile|--host)
      if (($# < 2)); then
        usage >&2
        exit 2
      fi
      if [[ "$1" == --source ]]; then
        source_file=$2
      else
        profile=$2
      fi
      shift 2
      ;;
    --no-rebuild)
      rebuild=false
      shift
      ;;
    --non-interactive)
      interactive=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if ((EUID == 0)); then
  printf 'Run setup.sh as your regular user; it invokes sudo for the rebuild.\n' >&2
  exit 1
fi

if [[ $interactive == true ]]; then
  if [[ ! -t 0 ]]; then
    printf 'An interactive terminal is required; use --non-interactive to skip prompts.\n' >&2
    exit 2
  fi

  read -r -p "Hardware configuration [${source_file}]: " answer || exit 1
  source_file=${answer:-$source_file}
  read -r -p "Configuration profile [${profile}]: " answer || exit 1
  profile=${answer:-$profile}
fi

if [[ ! "$profile" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
  printf 'Invalid configuration profile: %s\n' "$profile" >&2
  exit 2
fi
target_file="${repo_root}/hosts/${profile}/hardware-configuration.nix"

if [[ ! -f "$source_file" ]]; then
  printf 'Missing hardware configuration: %s\n' "$source_file" >&2
  exit 1
fi
if [[ ! -r "$source_file" ]]; then
  printf 'Hardware configuration is not readable by the current user: %s\n' "$source_file" >&2
  exit 1
fi
if [[ ! -d "${repo_root}/hosts/${profile}" ]]; then
  printf 'Unknown host directory: %s\n' "${repo_root}/hosts/${profile}" >&2
  exit 1
fi
if [[ $rebuild == true ]]; then
  for command in nix nixos-rebuild sudo; do
    if ! command -v "$command" >/dev/null 2>&1; then
      printf 'Required command is unavailable: %s\n' "$command" >&2
      exit 1
    fi
  done
fi

if [[ $interactive == true ]]; then
  printf 'Source: %s\nTarget: %s\n' "$source_file" "$target_file"
  if [[ $rebuild == true ]]; then
    printf 'Then lock: path:%s\nThen rebuild: path:%s#%s\n' "$repo_root" "$repo_root" "$profile"
  else
    printf 'Then skip rebuild (--no-rebuild).\n'
  fi
  read -r -p 'Proceed? [y/N]: ' answer || exit 1
  case "$answer" in
    y|Y|yes|YES) ;;
    *) printf 'Cancelled.\n'; exit 0 ;;
  esac
fi

install -m 0644 -- "$source_file" "$target_file"
printf 'Copied %s to %s\n' "$source_file" "$target_file"

if [[ $rebuild == true ]]; then
  NIX_CONFIG='experimental-features = nix-command flakes' nix flake lock "path:${repo_root}"
  sudo env NIX_CONFIG='experimental-features = nix-command flakes' nixos-rebuild switch --flake "path:${repo_root}#${profile}"
fi
