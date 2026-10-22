#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "$0")" && pwd)"
bash -n "$ROOT/build.sh" "$ROOT/validate.sh" "$ROOT/hooks/090-openclaw.hook.chroot"
for f in "$ROOT"/overlay/usr/local/bin/* "$ROOT"/overlay/etc/skel/.xinitrc; do
  sh -n "$f"
done
python3 - "$ROOT" <<'PY'
import sys, json, xml.etree.ElementTree as ET
from pathlib import Path
r=Path(sys.argv[1])
ET.parse(r/'overlay/etc/skel/.jwmrc')
json.loads((r/'overlay/etc/firefox/policies/policies.json').read_text())
for profile in ('lite','web','claw'):
    packages=[s.strip() for s in (r/'packages'/f'{profile}.list').read_text().splitlines()
              if s.strip() and not s.lstrip().startswith('#')]
    assert len(packages)==len(set(packages)), 'duplicate packages'
assert 'firefox-esr' not in (r/'packages/lite.list').read_text()
assert 'netsurf-gtk' in (r/'packages/lite.list').read_text()
assert '2026.10.5' in (r/'build.sh').read_text()
assert '<script' not in (r/'overlay/usr/local/share/leveos/home.html').read_text()
print('Static syntax checks passed. ISO and hardware boot not tested.')
PY
"$ROOT/overlay/usr/local/bin/leveos" help >/dev/null
"$ROOT/overlay/usr/local/bin/leveos-claw" help >/dev/null
"$ROOT/build.sh" --help >/dev/null
echo 'Validation completed.'
