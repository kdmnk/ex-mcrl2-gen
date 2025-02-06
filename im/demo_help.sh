export PATH=$PATH:/Applications/mCRL2.app/Contents/bin
path="./generated/demo_configured/mcrl2/specs"

## Generate linear process specification
mcrl22lps "$path.mcrl2" "$path.lps" -l regular2

## Generate boolean equeation system with the property
lps2pbes -v -c -f "$path.mcf" "$path.lps" "$path.pbes"

## Solve the equation system
pbessolve -v --file="$path.lps" "$path.pbes"

## generate linear transition system for the evidence
lps2lts "$path.pbes.evidence.lps" "$path.pbes.evidence.lts"

## display linear transition system for the evidence
ltsgraph "$path.pbes.evidence.lts"


