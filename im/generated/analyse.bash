export PATH=$PATH:/Applications/mCRL2.app/Contents/bin
#mcrl22lps "$1.mcrl2" "$1.lps" -l regular2
echo "lps generated"
#lps2lts -v -t -D "$1.lps" "$1.lts"
echo "lts generated"
lps2pbes -v -c -f "$1.mcf" "$1.lps" "$1.pbes"
echo "pbes generated"
#tracepp /Users/kdmnk/Projects/erlang-with-mcrl2-gen/im/generated/twoPhasedCommitMultiple/mcrl2/specs.lps_dlk_0.trc
pbes2bool -v "$1.pbes"
#LpsXSim "$1.lps"
#pbessolve -v --file="$1.lts" "$1.pbes"
#ltsgraph "$1.pbes.evidence.lts"
#ltsgraph "$1.lts"


#lps2lts -D -t "$1.lps"
#echo "trace"
#tracepp "$1.lps_act_0_exposeMsgs.trc"