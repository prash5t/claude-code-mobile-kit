#!/usr/bin/env bash
# generate-asset.sh — STARTER. Adapt for your chosen image generation backend.
#
# Usage:
#   generate-asset.sh --type icon --prompt "..." --output assets/icon/icon.png
#   generate-asset.sh --type feature-graphic --prompt "..." --output assets/store/feature-graphic.png
#   generate-asset.sh --type screenshot --source build/integration_test/screenshot-01.png \
#                     --headline "..." --output assets/store/screenshot-01.png
#
# This script is a placeholder. Replace with a real backend:
#
#  Option A — OpenAI DALL-E API:
#    Use `curl` against https://api.openai.com/v1/images/generations
#    Requires OPENAI_API_KEY env var
#
#  Option B — Stable Diffusion (local):
#    Use `python3 -m diffusers ...` against a local pipeline
#    Free but needs GPU and model weights
#
#  Option C — Real screenshots from running app:
#    Drive via `flutter drive` + `integration_test`
#    Composite with PIL or imagemagick for marketing text
#
#  Option D — Static assets (designed in Figma):
#    Just copy from a `designs/` folder you maintain manually
#    Simplest; no AI cost
#
# The asset-generator subagent calls this script. Whatever you wire here is
# what your project gets.

set -euo pipefail

echo "[generate-asset] PLACEHOLDER. Configure a real image-generation backend in this script."
echo "[generate-asset] See docstring for options."
exit 1
