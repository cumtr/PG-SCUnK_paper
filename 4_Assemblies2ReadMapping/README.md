# README : 4_Assemblies2ReadMapping

In this directory, you will find the script and commands used to go from a graph, extract the assemblies that compose it, simulate short reads, index the graph, align the short reads back to the graph anf finally extract summary statistics.

#

### File description 

`GFA2MappingStats.bash` - Bash script that makes all the step previously described.

`GetStats.py` - python script sumarising mapping statistcs.

### How to run

Run the main script with just one comand line.
before running, make sure to change the path to the PG-SCUnK compagnon script `GFA2HaploFasta.bash`

```
bash GFA2MappingStats.bash -g <Path/to/graph.gfa> -t <Number of threads>
```
