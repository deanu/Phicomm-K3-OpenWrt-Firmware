#!/usr/bin/env bash
set -euo pipefail

CONFIG_GENERATE='package/base-files/files/bin/config_generate'
AUTOCORE_INDEX='package/lean/autocore/files/arm/index.htm'
MINIUPNPD_CONFIG='feeds/packages/net/miniupnpd/files/upnpd.config'

if [[ -n "${MODIFY_HOSTNAME:-}" ]]; then
  echo '>>> Update Hostname >>>'
  if [[ ! "${MODIFY_HOSTNAME}" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,62}$ ]]; then
    echo "Invalid hostname: ${MODIFY_HOSTNAME}" >&2
    exit 1
  fi

  if grep -q "hostname='" "${CONFIG_GENERATE}"; then
    sed -Ei "s|hostname='[^']*'|hostname='${MODIFY_HOSTNAME}'|g" "${CONFIG_GENERATE}"
    grep -nF "hostname='${MODIFY_HOSTNAME}'" "${CONFIG_GENERATE}" || true
  else
    echo "Warning: hostname entry not found in ${CONFIG_GENERATE}; skipped hostname update" >&2
  fi
  echo '<<< Completed Update Hostname <<<'
fi

echo '>>> Remove Autocore Benchmark Display >>>'
sed -i 's/ <%=luci.sys.exec("cat \/etc\/bench.log") or ""%>//g' "${AUTOCORE_INDEX}"
echo '<<< Completed Remove Autocore Benchmark Display <<<'

# echo '>>> Remove Argon Console Log >>>'
# sed -i '/console.log(mainNodeName);/d' "${ARGON_SCRIPT}"
# echo '<<< Completed Remove Argon Console Log <<<'

# echo '>>> Update MiniUPnPd Lease Path >>>'
# sed -i 's/\/var\/upnp.leases/\/tmp\/upnp.leases/g' "${MINIUPNPD_CONFIG}"
# grep -n 'upnp_lease_file=/tmp/upnp.leases' "${MINIUPNPD_CONFIG}"
# echo '<<< Completed Update MiniUPnPd Lease Path <<<'
