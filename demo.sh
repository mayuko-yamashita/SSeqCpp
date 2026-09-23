#!/bin/bash
# Self-contained SSeqCpp demo: build the E2 data for S0, C2, Ceta, assemble an
# `ss` category with the two cofiber sequences, feed in d2(h4)=h0h3^2, and let
# the program propagate. Reconstructs the kind of worked example shown in the
# 2024 eCHT lecture (the original demo folder is not in this repository).
#
# Usage:  ./demo.sh [t_max]      (default t_max=100, ~30s total)
set -e
T=${1:-100}
BIN="$(cd "$(dirname "$0")" && pwd)/build/bin"
cd "$BIN"

# ---- 1. Cohomology definitions the Adams program needs -------------------
cat > Adams.json <<'EOF'
{
  "CW_complexes": {
    "S0":   { "cells": [0],    "cells_gen": [0], "operations": [] },
    "C2":   { "cells": [0, 1], "cells_gen": [0], "operations": [[0, 1]] },
    "Ceta": { "cells": [0, 2], "cells_gen": [0], "operations": [[0, 2]] }
  },
  "maps": {
    "C2__S0":   { "from": "C2",   "to": "S0", "images": [1], "sus": 1 },
    "Ceta__S0": { "from": "Ceta", "to": "S0", "images": [2], "sus": 2 }
  }
}
EOF

# ---- 2. E2 pages ---------------------------------------------------------
echo "### Adams E2 of S0"
./Adams res S0 $T; ./Adams prod S0 $T; ./Adams export S0 $T
for M in C2 Ceta; do
  echo "### Adams E2 of $M as a module over S0"
  ./Adams res $M $T; ./Adams prod_mod $M S0 $T; ./Adams export_mod $M S0 $T
  echo "### chain map $M -> S0"
  ./Adams map_res $M S0 $T; ./Adams export_map $M S0 $T
done

# ---- 3. The ss category --------------------------------------------------
mkdir -p demo
cp S0_AdamsSS.db C2_AdamsSS.db Ceta_AdamsSS.db \
   map_AdamsSS_C2__S0.db map_AdamsSS_Ceta__S0.db demo/
cat > demo/ss.json <<EOF
{
  "rings": [
    { "name": "S0", "path": "S0_AdamsSS.db", "deduce": "on",
      "plot_factors": [[[0, 1, 0], [1, 1, 0], [3, 1, 0]], []] }
  ],
  "modules": [
    { "name": "C2",   "path": "C2_AdamsSS.db",   "over": "S0", "deduce": "on" },
    { "name": "Ceta", "path": "Ceta_AdamsSS.db", "over": "S0", "deduce": "on" }
  ],
  "maps": [
    { "name": "C2__S0",   "path": "map_AdamsSS_C2__S0.db",   "from": "C2",   "to": "S0", "sus": 1, "t_max": $T },
    { "name": "Ceta__S0", "path": "map_AdamsSS_Ceta__S0.db", "from": "Ceta", "to": "S0", "sus": 2, "t_max": $T }
  ],
  "maps_v2": [
    { "name": "S0__S0_by_2",   "factor": [0, 1, 0], "from": "S0", "to": "S0", "t_max": $T },
    { "name": "S0__S0_by_eta", "factor": [1, 1, 0], "from": "S0", "to": "S0", "t_max": $T },
    { "name": "S0__C2",        "factor": [0, 0, 0], "from": "S0", "to": "C2",   "t_max": $T },
    { "name": "S0__Ceta",      "factor": [0, 0, 0], "from": "S0", "to": "Ceta", "t_max": $T }
  ],
  "cofseqs": [
    { "name": "S0__C2__S0",   "path": "cofseq_S0__C2__S0.db",   "i": "S0__C2",   "q": "C2__S0",   "d": "S0__S0_by_2"   },
    { "name": "S0__Ceta__S0", "path": "cofseq_S0__Ceta__S0.db", "i": "S0__Ceta", "q": "Ceta__S0", "d": "S0__S0_by_eta" }
  ],
  "dir_plot": "demo"
}
EOF
cat > ss.json <<'EOF'
{ "diagrams": { "default": "demo" }, "dir_website_ss": "webpages" }
EOF

echo "### initialising the category"
echo Y | ./ss reset demo > /dev/null

# ---- 4. The one input differential, then propagate -----------------------
echo "### add_diff  d2(h4) = h0 h3^2   at (stem,s)=(15,1)"
./ss add_diff S0 15 1 2 0 0 demo | tail -4
echo "### deduce auto"
./ss deduce auto demo num=3 2>&1 | tail -4

# ---- 5. Plot data (viewer html/js must come from Zenodo 14475507) --------
mkdir -p webpages/demo
./ss plot_ss demo > /dev/null && ./ss plot_cofseq demo > /dev/null
echo "### plot data written to $BIN/webpages/demo"
