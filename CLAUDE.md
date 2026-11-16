@AGENTS.md

# NeoX fork (local notes)

This checkout is upstream `different-ai/openwork` with a **minimal NeoX rebrand** and a
self-hosted model. Keep changes small; don't refactor upstream code. `git diff` shows
every NeoX change.

## Run

```
scripts/neox-dev.sh
```

It needs Node 24.22.1 (nvm), pnpm 11 (corepack) and `bun` (Homebrew). Electron CDP
listens on `127.0.0.1:9823`, which you can use for screenshots and DOM checks. Vite
runs on `:5173`.

## Branding (what was changed)

- Brand source: `~/neox/neox-inference-stack/neox-console/frontend` (`public/favicon.svg`,
  `src/index.css`). Dark graphite `#0a0c0f`, mint accent `#3ddc97`, "N" mark.
- `apps/app/public/openwork-mark.svg` and `openwork-sidebar-mark.svg` hold a black mono
  N. The UI adds `dark:invert` to these, so they must stay black.
  `openwork-logo-square.svg` and `neox-favicon.svg` hold the colour tile.
- Name "NeoX" is set in `apps/app/index.html`, `shell-config.tsx`, `brand-theme.tsx`,
  `desktop-config-provider.tsx`, `session-surface.tsx`,
  `apps/desktop/electron/desktop-distribution.mjs` and `electron-builder.yml`.
- Accent: `--primary` / `--sidebar-primary` in `apps/app/src/app/index.css`.
- App icons: `apps/desktop/resources/icons/{icon.png,icon.icns,dev/*}`, rendered from
  the NeoX SVG.
- Dock label in dev comes from the Electron bundle's folder name. `neox-dev.sh` renames
  `node_modules/.../electron/dist/Electron.app` to `NeoX.app` and updates `path.txt`.
- Still says OpenWork, on purpose: cloud sign-in ("Sync with OpenWork Cloud"), the
  OpenWork Models provider, and agent prompts.

## Model / providers

- Provider `neox` (openai-compatible) points at
  the internal LiteLLM gateway (`/v1`), model `glm-5.2`, default
  `neox/glm-5.2`.
- Dev mode **does not read `~/.config/opencode`**. It uses an isolated profile:
  `~/Library/Application Support/com.differentai.openwork.dev/openwork-dev-data/`.
  The config (with the API key) is copied to `xdg/config/opencode/opencode.json` and
  `config/opencode/opencode.json` there, plus `~/.config/opencode/opencode.json`.
  Edit all three together.
- Two engines run: `opencode` (v1) and `opencode2` (v2, which the UI uses). The v2
  config is regenerated on boot at
  `.../xdg/config/openwork/opencode-v2/state/config/opencode.json`. Read it to check
  what the UI sees; don't edit it.
- Hidden providers: `disabled_providers` in
  `.../xdg/config/openwork/runtime.sqlite`, table `runtime_opencode_configs`, row
  `__openwork_engine_global__`. It currently holds
  `opencode, openwork-free, openrouter, huggingface, ollama`. Stop the app before
  editing it. Ollama is auto-detected from `localhost:11434`, so this list is the only
  way to hide it.
- "Managed by env" in Settings means a key came from the shell environment
  (`OPENROUTER_API_KEY` / `HF_TOKEN` in `~/.zshrc`). `neox-dev.sh` unsets them.

## Gotchas

- Restart: `pkill -f electron-dev.mjs; pkill -f 'node_modules/.pnpm/electron@'; pkill -f sidecars/opencode`,
  then run `scripts/neox-dev.sh`.
- Harmless dev log errors: missing `desktop-bootstrap.json`, "Healthy app version must
  use the stable x.y.z format".
- A permanent `NeoX.app` (not built yet): `pnpm --filter @openwork/desktop package:electron:dir`.
