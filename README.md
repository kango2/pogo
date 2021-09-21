# Transcriptome assembly

Trinity assembly for multiple samples can be run as follows. `trinity.filelist` is a four column tab separated file containing
1. Unique name of the assembly output (sample identifier)
2. Full path to the left (R1) fastq file
3. Full path to the right (R2) fastq file
4. One of `RF/FR/US` denoting strandedness of the RNAseq data for that sample. `FR` is where `R1` reads are in sense orientation to the RNA and `R2` reads are antisense. `RF` is the opposite where `R1` is antisense and `R2` is sense relative to the RNA. `US` represents unstranded library.

```
cat trinity.filelist | xargs -l bash -c 'command qsub -j oe -o /PBS/outputdir/$0.OU -v outputdir=/path/2/save/assemblies/Trinity,fileid=$0,leftfq=$1,rightfq=$2,sstype=$3 runtrinity.sh'
```

NOTES:
1. Doesn't include ways to handle single end sequencing.
2. Trinity run time parameters can be modified in `runtrinity.sh` script. Currently, it is set to `--full_cleanup` mode and the `--min_kmer_cov 3` allows for removing noisy k-mers and improves run-time efficiency.
3. Each transcriptome assembly takes up ~700 service units (SU) with a range between 180 and 1400 SUs. 
4. If a library from one sample is sequenced across multiple lanes, then one would have to merge data from those lanes. (ToDo)
 
# Assembly repeat masking

Assemblies need to be for masked for repeats before they can be used for annotations and other downstream usecases. 

```
qsub -P ${PROJECT} -o /PBS/outputdir/ -v inputgenome=/path/to/genome/pogona_ont_purged_primary_assembly.fa,rmlib=/g/data/if89/datalib/Dfam_3.4/Sauropsida.fasta,outputdir=/path/to/outputdir/forrepeatmasker runrepeatmasker.sh
```

NOTES:
1. Took about 15 hours to mask Pogona genome. Genome can be split into chromosomes to reduce runtime. Merging of results need to be figured out.
2. Fragment size used was 1Mb with memory use of 79Gb. Perhaps this can be increased 2Mb. Tests with 5, 10 and 20Mb failed with memory issue.
3. Use PBS_NCPUS as the number of parallel processes to retain 95% plus efficiency. RepeatMasker recommends PBS_NCPUS/4 parallel processes for rmblastn but it was not running efficiently.
4. Tried with HMM search engine but it works only for curated libraries.
5. Dfam library is located at `/g/data/if89/datalib/Dfam_3.4/`. Species, lineage specific libraries can be constructed for use from this file ([command](https://github.com/kango2/pogo/blob/main/utilscmds.md#generate-fasta-library-for-repeats-from-the-dfamh5)).
