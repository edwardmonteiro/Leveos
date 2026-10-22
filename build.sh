#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "$0")" && pwd)"
PROFILE=lite
INSTALLER=none
OPENCLAW_VERSION=2026.10.5
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      [[ $# -ge 2 ]] || { echo 'Missing profile' >&2; exit 2; }
      PROFILE="$2"; shift 2 ;;
    --installer) INSTALLER=live; shift ;;
    -h|--help) echo 'Usage: sudo ./build.sh [--profile lite|web|claw] [--installer]'; exit 0 ;;
    *) echo 'Unknown argument' >&2; exit 2 ;;
  esac
done
case "$PROFILE" in lite|web|claw) ;; *) echo 'Invalid profile' >&2; exit 2 ;; esac
[[ $(id -u) -eq 0 ]] || { echo 'Requires sudo on Debian 13 amd64' >&2; exit 1; }
[[ $(uname -m) == x86_64 ]] || { echo 'Requires amd64 build host' >&2; exit 1; }
command -v lb >/dev/null || { echo 'Install live-build first' >&2; exit 1; }

BUILD="$ROOT/_build/$PROFILE-$INSTALLER"
mkdir -p "$BUILD" "$ROOT/output"
cd "$BUILD"
lb clean --purge >/dev/null 2>&1 || true
rm -rf config
lb config --mode debian --distribution trixie --architectures amd64 \
  --binary-images iso-hybrid --debian-installer "$INSTALLER" \
  --debian-installer-gui false --debootstrap-options '--variant=minbase' \
  --archive-areas 'main non-free-firmware' --apt-recommends false \
  --apt-indices false --firmware-chroot false --memtest none \
  --bootappend-live 'boot=live components locales=pt_BR.UTF-8 keyboard-layouts=br'

mkdir -p config/package-lists config/includes.chroot
cp "$ROOT/packages/lite.list" config/package-lists/leveos-core.list.chroot
if [[ "$PROFILE" != lite ]]; then
  cp "$ROOT/packages/web.list" config/package-lists/leveos-web.list.chroot
fi
if [[ "$PROFILE" == claw ]]; then
  cp "$ROOT/packages/claw.list" config/package-lists/leveos-claw.list.chroot
  mkdir -p config/hooks/live
  sed "s/@OPENCLAW_VERSION@/$OPENCLAW_VERSION/g" "$ROOT/hooks/090-openclaw.hook.chroot" > config/hooks/live/090-openclaw.hook.chroot
  chmod 755 config/hooks/live/090-openclaw.hook.chroot
fi
cp -a "$ROOT/overlay/." config/includes.chroot/
find config/includes.chroot/usr/local/bin -type f -exec chmod 755 '{}' +
chmod 755 config/includes.chroot/etc/skel/.xinitrc

NAME="LeveOS-0.3-$PROFILE"
if [[ "$INSTALLER" == live ]]; then NAME="$NAME-installer"; fi
NAME="$NAME-amd64.iso"
LOG="$ROOT/output/$NAME.build.log"
lb build 2>&1 | tee "$LOG"
ISO="$(find . -maxdepth 1 -type f -name 'live-image-*.iso' -print -quit)"
[[ -n "$ISO" ]] || { echo 'No ISO output; inspect build log' >&2; exit 1; }
cp "$ISO" "$ROOT/output/$NAME"
(cd "$ROOT/output" && sha256sum "$NAME" > "$NAME.sha256")
echo "Generated $ROOT/output/$NAME"
