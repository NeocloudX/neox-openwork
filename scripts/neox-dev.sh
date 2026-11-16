#!/usr/bin/env bash
# Launch the NeoX-branded OpenWork desktop app in dev mode.
# - Re-applies the dev Electron bundle rename (pnpm install restores Electron.app).
# - Hides env-provided providers (OpenRouter / Hugging Face keys from ~/.zshrc).
set -euo pipefail
cd "$(dirname "$0")/.."

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && nvm use 24.22.1 >/dev/null

E=$(cd apps/desktop && node -e "console.log(require('path').dirname(require.resolve('electron/package.json')))")
if [ -d "$E/dist/Electron.app" ]; then
  mv "$E/dist/Electron.app" "$E/dist/NeoX.app"
  P="$E/dist/NeoX.app/Contents"
  plutil -replace CFBundleName -string NeoX "$P/Info.plist"
  plutil -replace CFBundleDisplayName -string NeoX "$P/Info.plist"
  cp apps/desktop/resources/icons/icon.icns "$P/Resources/electron.icns"
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$E/dist/NeoX.app"
fi
printf 'NeoX.app/Contents/MacOS/Electron' > "$E/path.txt"

exec env -u OPENROUTER_API_KEY -u HF_TOKEN OPENWORK_ELECTRON_APP_NAME=NeoX pnpm dev
