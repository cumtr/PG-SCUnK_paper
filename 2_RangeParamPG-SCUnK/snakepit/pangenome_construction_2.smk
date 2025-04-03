rule pggb_construct:
    input:
        fasta = 'graphs_Cattle/13.fa.gz'
    output:
        gfa = 'graphs_Cattle/s{s}_k{k}_p{p}/{chromosome}.pggb.gfa',
        og = 'graphs_Cattle/s{s}_k{k}_p{p}/{chromosome}.pggb.og'
    threads: 30
    resources:
        mem_mb = 20000,
        walltime = '120h',
        scratch = '100G', 
        nodelist = "/cluster/work/pausch/sotiria/SV_saturation_pangenome/nodelist_smk"
    benchmark:
        "graphs_Cattle/s{s}_k{k}_p{p}/{chromosome}.pggb.benchmark.txt"
    params:
        _dir = lambda wildcards, output: Path(output[0]).parent
    shell:
        '''
	
	source envs/dependencies.txt
        
	/cluster/work/pausch/sotiria/software/pggb_0.6_v2/pggb -i {input.fasta} -o {params._dir} -t {threads} \
        --skip-viz --temp-dir $TMPDIR \
        -s {wildcards.s} -k {wildcards.k} -p {wildcards.p}  \
        -T {threads}

        mv {params._dir}/{wildcards.chromosome}.*.smooth.final.gfa {output.gfa}
        mv {params._dir}/{wildcards.chromosome}.*.smooth.final.og {output.og}
        '''


rule PG-SCUnK_run:
    input:
        gfa = 'graphs_Cattle/s{s}_k{k}_p{p}/{chromosome}.pggb.gfa',
        fasta = 'graphs_Cattle/13.fa.gz'
    output:
        'graphs_Cattle/s{s}_k{k}_p{p}/{chromosome}.pggb.PG-SCUnK.done'
    threads: 10
    resources:
        mem_mb = 20000,
        walltime = '24h',
        scratch = '200G'
    params:
        k = 100
    shell:
        '''
        export PATH=$PATH:/cluster/work/pausch/tcumer/TOOLS/mambaforge/envs/samtools/bin:/cluster/work/pausch/tcumer/TOOLS/mambaforge/envs/odgi/bin/
        ~/WORK/TOOLS/PG-SCUnK/scripts/GFA2HaploFasta.bash -p {input.gfa} -t $TMPDIR -o $TMPDIR/{wildcards.chromosome}_s{wildcards.s}_k{wildcards.k}_p{wildcards.p} -@ {threads}
        export PATH=$PATH:/cluster/work/pausch/tcumer/TOOLS/mambaforge/envs/kmc/bin/
        ~/WORK/TOOLS/PG-SCUnK/PG-SCUnK -p {input.gfa} -a $TMPDIR/{wildcards.chromosome}_s{wildcards.s}_k{wildcards.k}_p{wildcards.p} -o graphs_Cattle/s{wildcards.s}_k{wildcards.k}_p{wildcards.p}/{wildcards.chromosome}.pggb.PG-SCUnK -t $TMPDIR -k {params.k}
        touch {output}
        '''

