export PATH=$PATH:~/Projects/mCRL2/stage/mCRL2.app/Contents/bin
mcrl22lps generated/twoPhasedCommitMultiple/specs.mcrl2 generated/twoPhasedCommitMultiple/specs.lps -l regular2
echo "lps generated"
lps2lts generated/twoPhasedCommitMultiple/specs.lps generated/twoPhasedCommitMultiple/specs.lts
echo "lts generated"
lps2pbes -v -c -f generated/twoPhasedCommitMultiple/formulas.mcf generated/twoPhasedCommitMultiple/specs.lps generated/twoPhasedCommitMultiple/formulas.pbes
echo "pbes generated"
pbes2bool generated/twoPhasedCommitMultiple/formulas.pbes
# LpsXSim generated/twoPhasedCommitMultiple/specs.lps
pbessolve -v --file=generated/twoPhasedCommitMultiple/specs.lts generated/twoPhasedCommitMultiple/formulas.pbes
#ltsgraph generated/twoPhasedCommitMultiple/formulas.pbes.evidence.lts
# ltsgraph generated/twoPhasedCommitMultiple/specs.lts

# ltsgraph generated/twoPhasedCommitMultiple/specs.lts