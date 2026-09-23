#!/bin/bash
# The original eCHT-lecture demo, reproduced verbatim from the `commands.sh`
# shipped in programs.zip of Zenodo record 14475507 (Lin-Wang-Xu, "Machine
# Proofs for Adams Differentials and Extension Problems among CW Spectra").
#
# Only deviation: charts are plotted TWICE -- once straight after `reset`
# (E2 + the machine-computed d2's only) into webpages/E2only, and once after
# the three deduction passes into webpages/mix -- so you can flip between
# them in the viewer and see what `ss` actually proved.
#
# Usage:  ./demo_echt.sh
set -e
BIN="$(cd "$(dirname "$0")" && pwd)/build/bin"
cd "$BIN"

echo "=============== 1. Adams E2 pages + machine d2 differentials ==========="
./Adams res    S0 80 >/dev/null; ./Adams prod   S0 80 >/dev/null
./Adams export S0 80 >/dev/null; ./Adams d2     S0 50 >/dev/null
./Adams export_d2 S0 >/dev/null; echo "  S0"
for M in C2 Ceta Cnu Csigma; do
  ./Adams res       $M    80 >/dev/null; ./Adams prod_mod   $M S0 80 >/dev/null
  ./Adams export_mod $M S0 80 >/dev/null; ./Adams d2        $M    50 >/dev/null
  ./Adams export_d2  $M      >/dev/null
  ./Adams map_res    $M S0 80 >/dev/null; ./Adams export_map $M S0 80 >/dev/null
  echo "  $M  (+ map $M -> S0)"
done

echo "=============== 2. assemble the category ==============================="
cp *AdamsSS*.db demo/
echo Y | ./ss reset demo >/dev/null
mkdir -p webpages/mix
./ss plot_ss demo >/dev/null; ./ss plot_cofseq demo >/dev/null
rm -rf webpages/E2only; cp -R webpages/mix webpages/E2only
echo "  baseline charts -> webpages/E2only"

echo "=============== 3. the three deduction passes =========================="
for pass in "deduce auto demo" "deduce synthetic demo" "deduce auto demo flags=zero"; do
  printf "  ss %-28s " "$pass"
  ./ss $pass 2>&1 | sed 's/\x1b\[[0-9;]*m//g' \
    | awk '/^ *ss:/{s=$2} /^ *cofseq:/{c=$2} END{printf "ss:%-6s cofseq:%s\n", s, c}'
done

echo "=============== 4. final charts ========================================"
./ss plot_ss demo >/dev/null; ./ss plot_cofseq demo >/dev/null
echo "  deduced charts -> webpages/mix"
echo
echo "Serve them with:   cd $BIN/webpages && python3 -m http.server 8765"
echo "  before:  http://localhost:8765/plot.html?diagram=E2only&data=S0"
echo "  after:   http://localhost:8765/plot.html?diagram=mix&data=S0"
