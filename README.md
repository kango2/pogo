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
 
