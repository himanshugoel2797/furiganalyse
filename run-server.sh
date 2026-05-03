#!/usr/bin/env bash
set -euo pipefail

# Activate conda base so `poetry` is on PATH; the poetry venv supplies
# everything else (pandoc, calibre symlinks, mecab/unidic, app deps).
source "$HOME/miniforge3/etc/profile.d/conda.sh"
conda activate base

cd "$(dirname "$(readlink -f "$0")")"

exec poetry run uvicorn furiganalyse.app:app \
    --host 0.0.0.0 --port 5000 "$@"
