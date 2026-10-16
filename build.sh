#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
upstream_dir="$(mktemp -d)"
source_dir="${UPSTREAM_SOURCE_DIR:-}"

cleanup() {
  rm -rf "${upstream_dir}"
}
trap cleanup EXIT

# The upstream GitHub Release tag is the version authority for this app, so
# build the newest release instead of a moving branch.
resolve_release_tag() {
  curl --fail --silent --show-error --location --retry 3 --retry-all-errors \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/jellydeck/moocup/releases?per_page=20" \
    | python3 "${project_root}/scripts/pick-release-tag.py"
}

if [[ -z "${source_dir}" ]]; then
  release_tag="$(resolve_release_tag)"
  test -n "${release_tag}"
  printf "Building upstream release %s\n" "${release_tag}"

  source_dir="${upstream_dir}/source"
  mkdir -p "${source_dir}"
  curl --fail --location --retry 3 --retry-all-errors \
    "https://codeload.github.com/jellydeck/moocup/tar.gz/refs/tags/${release_tag}" \
    | tar -xz --strip-components=1 -C "${source_dir}"
else
  source_dir="$(cd "${source_dir}" && pwd)"
  printf "Building local source tree %s\n" "${source_dir}"
fi

test -f "${source_dir}/pnpm-lock.yaml"
cd "${source_dir}"

if ! command -v pnpm >/dev/null 2>&1; then
  corepack enable 2>/dev/null || true
fi
if ! command -v pnpm >/dev/null 2>&1; then
  npm install --global pnpm
fi
pnpm --version

# pnpm blocks dependency postinstall unless the script is approved. Upstream
# ships the older onlyBuiltDependencies key, so write the allowBuilds form.
printf "allowBuilds:\n  esbuild: true\n" > "${source_dir}/pnpm-workspace.yaml"

pnpm install --frozen-lockfile
pnpm build

rm -rf "${project_root}/dist"
cp -a build "${project_root}/dist"
