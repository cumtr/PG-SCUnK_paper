#!/bin/bash

# Run this script using : bash GFA2MappingStats.bash -g <Path/to/graph.gfa> -t <Number of threads>
# before running, make sure to change the path to the PG-SCUnK compagnon script : GFA2HaploFasta.bash

# Default values
GFA=""
THREADS=1

# Parse command-line options
while getopts "g:t:" opt; do
  case $opt in
    g) GFA="$OPTARG" ;;
    t) THREADS="$OPTARG" ;;
    *) echo "Usage: $0 -g <file.gfa> -t <threads>"; exit 1 ;;
  esac
done

# Check if required parameters are set
if [[ -z "$GFA" ]]; then
  echo "Error: -g <file.gfa> is required."
  exit 1
fi

echo "Processing : $GFA"
echo "Threads: $THREADS"


BASE=`basename -s .gfa $GFA`

### Index graph ###

if [ -f "${BASE}.min" ]
then
    echo "${BASE}.min exists. SKipping Indexing"
else
    echo "Indexing ..."
    vg autoindex --workflow giraffe -t ${THREADS} -g ${GFA} -t ${BASE} -M 100G
fi

### Extract assemblies from the graph ###

~/WORK/TOOLS/PG-SCUnK/scripts/GFA2HaploFasta.bash  -p $GFA -t ${SCRATCH} -o $BASE/$BASE.haplo -@ ${THREADS}

### Simulate Reads ####

parallel --jobs ${THREADS} BASE=$BASE '  
    FILE={};
    echo $FILE
    BASE_FILE=$(basename -s .fasta $FILE);  
    echo $BASE_FILE;  
    NbReads=$(awk "! />/ {print}" ${FILE} | tr -d "\n" | wc | awk "{printf \"%.0f\n\", (\$3*15)/150}");  
    echo $NbReads;  
    wgsim -N ${NbReads} -1 150 -2 150 -e 0 -r 0 -R 0 -X 0 ${FILE} $BASE/$BASE.haplo/$BASE_FILE.R1.fq $BASE/$BASE.haplo/$BASE_FILE.R2.fq;  
    gzip $BASE/$BASE.haplo/$BASE_FILE.R1.fq;  
    rm $BASE/$BASE.haplo/$BASE_FILE.R2.fq; 
' ::: $BASE/$BASE.haplo/*.fasta


### Map Reads ###

RandName=$(echo $RANDOM | md5sum | head -c 6)
mkdir $TMPDIR/temp_${RandName}
cp ${BASE}.giraffe.gbz $TMPDIR/temp_${RandName}/ ;
cp ${BASE}.min $TMPDIR/temp_${RandName}/ ; 
cp ${BASE}.dist $TMPDIR/temp_${RandName}/ ;
for FILE in $BASE/$BASE.haplo/*.fasta
do
    BASE_FILE=`basename -s .fasta $FILE`
    echo $BASE_FILE
    vg giraffe -t ${THREADS} -p -Z $TMPDIR/temp_${RandName}/${BASE}.giraffe.gbz \
                                                                    -m $TMPDIR/temp_${RandName}/${BASE}.min \
                                                                    -d $TMPDIR/temp_${RandName}/${BASE}.dist \
                                                                    -f $BASE/$BASE.haplo/$BASE_FILE.R1.fq.gz > $BASE/$BASE.haplo/$BASE_FILE.aligned.gam;
    vg stats -a $BASE/$BASE.haplo/$BASE_FILE.aligned.gam > $BASE/$BASE.haplo/$BASE_FILE.aligned.stats;
    vg view -a $BASE/$BASE.haplo/${BASE_FILE}.aligned.gam > $BASE/$BASE.haplo/${BASE_FILE}.txt;
    python3 GetStats_v2.py -f $BASE/$BASE.haplo/${BASE_FILE}.txt > $BASE/$BASE.haplo/${BASE_FILE}.aligned.count
    rm $BASE/$BASE.haplo/${BASE_FILE}.txt
done

rm -rf $TMPDIR/temp_${RandName}



