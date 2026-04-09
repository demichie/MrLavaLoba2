#!/usr/bin/env bash
set -euo pipefail

if [ -z "${CONDA_PREFIX:-}" ]; then
  echo "Error: no active conda environment."
  echo "Run first:"
  echo "  conda activate mr-lava-loba"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVATE_DIR="$CONDA_PREFIX/etc/conda/activate.d"
DEACTIVATE_DIR="$CONDA_PREFIX/etc/conda/deactivate.d"

mkdir -p "$ACTIVATE_DIR"
mkdir -p "$DEACTIVATE_DIR"

cat > "$ACTIVATE_DIR/mr_lava_loba.sh" <<EOT
export MR_LAVA_LOBA_REPO="$REPO_DIR"
export _MR_LAVA_LOBA_OLD_PATH="\$PATH"
export PATH="\$MR_LAVA_LOBA_REPO/bin:\$PATH"
EOT

cat > "$DEACTIVATE_DIR/mr_lava_loba.sh" <<'EOT'
if [ -n "${_MR_LAVA_LOBA_OLD_PATH:-}" ]; then
  export PATH="$_MR_LAVA_LOBA_OLD_PATH"
  unset _MR_LAVA_LOBA_OLD_PATH
fi
unset MR_LAVA_LOBA_REPO
EOT

echo "Conda hooks installed for environment: $CONDA_PREFIX"
echo "Repository root registered as: $REPO_DIR"
echo
echo "Now run:"
echo "  conda deactivate"
echo "  conda activate $(basename "$CONDA_PREFIX")"
echo
echo "Then check:"
echo "  which mr_lava_loba_f90"
echo "  which mr_lava_loba_py"
