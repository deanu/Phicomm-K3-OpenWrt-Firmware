#!/usr/bin/env bash
set -euo pipefail

append_feed_if_missing() {
  local line="$1"
  grep -qxF "$line" feeds.conf.default || echo "$line" >> feeds.conf.default
}

clone_repo() {
  local repo_url="$1"
  local branch="$2"
  local dst="$3"

  rm -rf "$dst"

  if [[ -n "$branch" ]]; then
    git clone -b "$branch" --single-branch --depth 1 "$repo_url" "$dst"
  else
    git clone --depth 1 "$repo_url" "$dst"
  fi
}

FIRMWARE_URL='https://raw.githubusercontent.com/coolsnowwolf/lede/refs/heads/master/package/lean/k3-firmware/files/brcmfmac4366c-pcie.bin'
FIRMWARE_PATH='package/lean/k3-firmware/files/brcmfmac4366c-pcie.bin'

echo '>>> Add Passwall Feed >>>'
append_feed_if_missing 'src-git passwall https://github.com/openwrt-passwall/openwrt-passwall-packages'
echo '<<< Completed Add Passwall Feed <<<'

echo '>>> Clone Passwall Package >>>'
clone_repo 'https://github.com/openwrt-passwall/openwrt-passwall' 'main' 'package/lean/luci-app-passwall'
echo '<<< Completed Clone Passwall Package <<<'

echo '>>> Clone Glass LuCI Theme >>>'
clone_repo 'https://github.com/rchen14b/luci-theme-glass.git' 'main' 'package/lean/luci-theme-glass'
echo '<<< Completed Clone Glass LuCI Theme <<<'

echo '>>> Clone Additional LuCI Packages >>>'
KENZOK_REPO='package/lean/kenzok8-packages'
clone_repo 'https://github.com/kenzok8/openwrt-packages.git' 'master' "$KENZOK_REPO"

for package in luci-app-advanced luci-app-store luci-app-gost gost luci-lib-taskd luci-lib-xterm taskd; do
  rm -rf "package/lean/$package"
  mv "$KENZOK_REPO/$package" "package/lean/$package"
done

rm -rf package/lean/luci-app-lucky package/lean/lucky
mv "$KENZOK_REPO/luci-app-lucky/luci-app-lucky" package/lean/luci-app-lucky
mv "$KENZOK_REPO/luci-app-lucky/lucky" package/lean/lucky
rm -rf "$KENZOK_REPO"
echo '<<< Completed Clone Additional LuCI Packages <<<'

echo '>>> Clone K3 Screen App >>>'
clone_repo 'https://github.com/yangxu52/luci-app-k3screenctrl.git' '' 'package/lean/luci-app-k3screenctrl'
echo '<<< Completed Clone K3 Screen App <<<'

echo '>>> Clone K3 Screen Driver >>>'
clone_repo 'https://github.com/yangxu52/k3screenctrl_build.git' '' 'package/lean/k3screenctrl'
echo '<<< Completed Clone K3 Screen Driver <<<'

echo '>>> Fetch LEDE Wireless Firmware >>>'
mkdir -p "$(dirname "$FIRMWARE_PATH")"
wget -nv "$FIRMWARE_URL" -O "$FIRMWARE_PATH"
echo '<<< Completed Fetch LEDE Wireless Firmware <<<'
