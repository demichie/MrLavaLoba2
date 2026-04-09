#!/usr/bin/env bash
set -euo pipefail

if [ -z "${CONDA_PREFIX:-}" ]; then
  echo "Error: no active conda environment."
  echo "Run first:"
  echo "  conda activate mr-lava-loba"
  exit 1
fi

ACTIVATE_SCRIPT="$CONDA_PREFIX/etc/conda/activate.d/mr_lava_loba.sh"
DEACTIVATE_SCRIPT="$CONDA_PREFIX/etc/conda/deactivate.d/mr_lava_loba.sh"

if [ -f "$ACTIVATE_SCRIPT" ]; then
  rm -f "$ACTIVATE_SCRIPT"
  echo "Removed: $ACTIVATE_SCRIPT"
else
  echo "Not found: $ACTIVATE_SCRIPT"
fi

if [ -f "$DEACTIVATE_SCRIPT" ]; then
  rm -f "$DEACTIVATE_SCRIPT"
  echo "Removed: $DEACTIVATE_SCRIPT"
else
  echo "Not found: $DEACTIVATE_SCRIPT"
fi

echo
echo "Now run:"
echo "  conda deactivate"
echo "  conda activate $(basename "$CONDA_PREFIX")"
echo
echo "Then verify the launchers are no longer on PATH:"
echo "  which mr_lava_loba_f90"
echo "  which mr_lava_loba_py"
