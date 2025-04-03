# README : 3_RunPG-SCUnK

In this directory, you will find all the script and commands to run `PG-SCUnk` on different graph and how to summarise the results, assuming a slurm environement.
the command line presented here allows to run `PG-SCUnK` on the Taurine graph produced in `../1_TaurinePangenome/` and can easily be adapted to any graph in `.gfa` format.

#

### File description 

`Seff2table.py` - python script sumarising the output of the seff command into a table

### How to run

1. Extract the assemblies from the graph

```
for ((i=1; i<=29; i++)); do
    echo $i
    sbatch --mem-per-cpu=5G --time=24:00:00 --ntasks=1 --cpus-per-task=20 --wrap="/Path/To/PG-SCUnK/scripts/GFA2HaploFasta.bash -p /Path/To/1_CattlePG_AllChr/results/1_TaurinePangenome/results/${i}.pggb.gfa -t $SCRATCH -o 1_Assemblies/${i}.pggb -@ 20"
done 
```

2. Run PG-SCUnK

```
for ((i=1; i<=29; i++)); do
    echo $i
    sbatch --mem-per-cpu=50G --time=24:00:00 --ntasks=1 --cpus-per-task=1 -e STD/slurm-%j.stderr -o STD/slurm-%j.stdout --wrap='echo $SLURM_JOB_ID > out_PG-SCUnK_Cattle/'"${i}"'.pggb.jobID; Path/To/PG-SCUnK/PG-SCUnK -p /Path/To/1_CattlePG_AllChr/results/1_TaurinePangenome/results/${i}.pggb.gfa -a 1_Assemblies/'"${i}"'.pggb -o out_PG-SCUnK_Cattle/'"${i}"'.pggb -t $SCRATCH -k 100 -v'
done 
```

3. Sumarise the results

```
touch out_PG-SCUnK_Cattle.stats.txt
for ((i=1; i<=29; i++)); do
    file="out_PG-SCUnK_Cattle/${i}.pggb.stats.txt"
    stats=`cat out_PG-SCUnK_Cattle/${i}.pggb.stats.txt | awk '! /#/ {print $2, $3, $4, $2/$1*100, $3/$1*100, $4/$1*100}'`
    echo $file $i $stats >> out_PG-SCUnK_Cattle.stats.txt
done

touch PG-SCUnK_Cattle_StatsRun.txt
for ((i=1; i<=29; i++)); do
do 
    echo $i
    JOBID=`cat out_PG-SCUnK_Cattle/${i}.pggb.jobID`
    myjobs -j $JOBID > $SCRATCH/$$
    python Seff2Table.py $SCRATCH/$$  > $SCRATCH/$$.stats
    Stats=`awk 'NR==2 {print}' $SCRATCH/$$.stats`
    echo $i $Stats >> PG-SCUnK_Cattle_StatsRun.txt
done 
```
