# Transcriptome assembly using Trinity

Trinity assembly for multiple samples can be run as follows. `trinity.filelist` is a four column tab separated file containing
1. Unique name of the assembly output (sample identifier)
2. Full path to the left (R1) fastq file
3. Full path to the right (R2) fastq file
4. One of `RF/FR/US` denoting strandedness of the RNAseq data for that sample. `FR` is where `R1` reads are in sense orientation to the RNA and `R2` reads are antisense. `RF` is the opposite where `R1` is antisense and `R2` is sense relative to the RNA. `US` represents unstranded library.

```
cat trinity.filelist | \
xargs -l bash -c 'command qsub -j oe -o /PBS/outputdir/$0.OU \
-v outputdir=/path/2/save/assemblies/Trinity,fileid=$0,leftfq=$1,rightfq=$2,sstype=$3 \
runtrinity.sh'
```

NOTES:
1. **Resource usage:** 2-15 hours walltime, 700 service units (SU) with a range between 180 and 1400 SUs, 30-180GB RAM, 48 ncpus
2. **Parameter settings:** 
   *  `--full_cleanup` mode to remove extra millions of files created during the run.
   *  `--min_kmer_cov 3` to remove noisy k-mers and improving run-time efficiency.
   *  Other Trinity parameters can be modified in [`runtrinity.sh`](https://github.com/kango2/pogo/blob/main/cmdscripts/runtrinity.sh) script.
3. **Output files:** `outputdir.Trinity.fasta` and `outputdir.Trinity.fasta.gene_trans_map`
4. **Todo:** 
  * If a library from one sample is sequenced across multiple lanes, then one would have to merge data from those lanes.
  * Doesn't include ways to handle single end sequencing as yet.
 
# Repeat masking using RepeatMasker

Assemblies need to be for masked for repeats before they can be used for annotations and other downstream usecases. [runrepeatmasker.sh](https://github.com/kango2/pogo/blob/main/cmdscripts/runrepeatmakser.sh) can be launched as follows for repeat annotations using RepeatMakser.

```
qsub -P ${PROJECT} -o /PBS/outputdir/ -v inputgenome=/path/to/genome/pogona_ont_purged_primary_assembly.fa,rmlib=/g/data/if89/datalib/Dfam_3.4/Sauropsida.fasta,outputdir=/path/to/outputdir/forrepeatmasker runrepeatmasker.sh
```

NOTES:
1. **Resource usage:** 15 hours walltime, 1500 service units (SU), 70GB RAM, 48 ncpus to mask the Pogona genome. 
2. **Parameter settings:** 
  * Fragment size was set to 1Mb which used 79Gb of RAM. Perhaps this can be increased 2Mb. Tests with 5, 10 and 20Mb failed with memory issue.
  * Use PBS_NCPUS as the number of parallel processes to retain 95% plus efficiency. RepeatMasker recommends PBS_NCPUS/4 parallel processes for rmblastn but it was not running efficiently.
  * Tried with HMM search engine but it does not work. HMM requires curated libraries.
3. **Resource dependency:** Dfam library is located at `/g/data/if89/datalib/Dfam_3.4/`. Species, lineage specific libraries can be constructed for use from this file ([command](https://github.com/kango2/pogo/blob/main/utilscmds.md#generate-fasta-library-for-repeats-from-the-dfamh5)).
4. **Output files:** `genome.fasta.[tbl|out.gff|out|ori.out|masked|cat.gz]`
5. **Todo:** 
  * Genome can be split into chromosomes to reduce runtime. Merging of results need to be figured out.

# Exonerate for aligning *de novo* transcript contigs to repeat masked genome

```
for i in ../bpadata/Bassiana_duperreyi/projects/Trinity/*/*.Trinity.fasta; do inputfasta=$(realpath $i); for c in 1 241 481; do qsub -P xl04 -o /g/data/xl04/hrp561/ -v querychunktotal=720,querychunkstart=$c,querychunkend=$((c+239)),outputdir=/g/data/xl04/bpadata/Bassiana_duperreyi/projects/exonerate,inputfasta=${inputfasta},targetgenome=/g/data/xl04/hrp561/bassiana_ont_gap_filled_assembly.RM.fasta /g/data/xl04/hrp561/runexonerate.sh; done; done
```

NOTES:
1. **Resource usage:** 1 hour 30 minutes (request 3 hours), 88 service units (SU) per chunk, 36GB RAM, 48 ncpus for a transcriptome
2. 
