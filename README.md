# PG-SCUnK_paper

This directory contains the scripts used to produce and analyse the results presented in : *PG-SCUnK: measuring pangenome graph representativeness using single-copy and universal K-mers*.

The repostory with the workflow `PG-SCUnK` is here : https://github.com/cumtr/PG-SCUnK

# 

### Directory structure and content

`0_Manuscript/` - Directory with a version of the manuscript and associated supplementary material.

`1_TaurinePangenome/` - Snakemake pipeline to generate the Taurine pangenome graph analysed in the paper.

`2_RangeParamPGGB/` - Snakemake pipeline used to produce various graph with different pggb parameters for the chromosome 13 of the taurine pangenome. 

`3_RunPG-SCUnK/`- Scripts used to run *PG-SCUnK* on all the graph studided, as well as summarise the results.  

`4_Assemblies2ReadMapping/`- Scripts used to simulate short reads from the assemblies composing the graph, align them on the graph and extract summary statistics.
