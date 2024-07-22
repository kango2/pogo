# Transcriptome assembly using Trinity

Trinity assembly for multiple samples can be run as follows. `trinity.filelist` is a five column tab separated file containing:
1. Unique name of the assembly output (sample identifier)
2. Sequencing type (SE or PE)
3. Strandedness of RNAseq (for PE, RF|RF|US, for SE, R|F|US)
4. Full path to the left (R1) fastq file, comma separated if there are multiple files/lanes  
5. Full path to the right (R2) fastq file, comma separated if there are multiple files/lanes  

For single end samples (SE) only 4 columns without any trailing whitespace characters are required.  
For column 3, specify One of `RF/FR/US` denoting strandedness of the paired end RNAseq data for that sample. `FR` is where `R1` reads are in sense orientation to the RNA and `R2` reads are antisense. `RF` is the opposite where `R1` is antisense and `R2` is sense relative to the RNA. `US` represents unstranded library. Similarly `F` `R` and `US` for single end data.  
Example of `trinity.filelist` below:
```
PEsample1_1lane	PE	RF	/path/to/sample1_R1.fq.gz	/path/to/sample1_R2.fq.gz
PEsample2_2lanes	PE	RF	/path/to/sample2_R1_L001.fq.gz,/path/to/sample2_R1_L002.fq.gz	/path/to/sample2_R2_L001.fq.gz,/path/to/sample2_R2_L002.fq.gz
SEsample3_1lane	SE	R	/path/to/sample3_R1.fq.gz
SEsample4_2lanes	SE	US	/path/to/sample4_R1_L001.fq.gz,/path/to/sample4_R1_L002.fq.gz
```
Command to submit trinity jobs:
```
cat trinity.filelist | \
xargs -l bash -c 'command qsub -j oe -o /PBS/outputdir/$0.OU \
-v outputdir=/path/2/save/assemblies/Trinity,fileid=\"$0\",seqtype=\"$1\",sstype=\"$2\",leftfq=\"$3\",rightfq=\"$4\" \
runtrinityModified.sh'
```

NOTES:
1. **Resource usage:** 2-15 hours walltime, 700 service units (SU) with a range between 180 and 1400 SUs, 30-180GB RAM, 48 ncpus
2. **Parameter settings:** 
   *  `--full_cleanup` mode to remove extra millions of files created during the run.
   *  `--min_kmer_cov 3` to remove noisy k-mers and improving run-time efficiency.
   *  Other Trinity parameters can be modified in [`runtrinity.sh`](https://github.com/kango2/pogo/blob/main/cmdscripts/runtrinity.sh) script.
3. **Output files:** `outputdir.Trinity.fasta` and `outputdir.Trinity.fasta.gene_trans_map`
4. **Todo:** 
  * Incorporate the rename fasta header script into runtrinity.sh  
The trinity assemblies have default fasta header with prefix `TRINITY_`, the below `for` loop command using seqkit changes the prefix to your sample identifier (extracted from output file name)
```
module load seqkit/2.5.1
for i in $(ls /path/to/trinity/assemblies/*.trinity.Trinity.fasta); do
    export base=$(basename ${i} .trinity.Trinity.fasta)
    cat ${i} | seqkit replace -p ^TRINITY_ -r ${base}_ > /path/to/trinity/assemblies/${base}_renamed.fasta
done
```
# Generate TE library using RepeatModeler

When soft masking your genome, using a taxon repeats library (eg. from Dfam) will often result in low masking percentage because the library lack the species-specific repeats for your particular species. The presence of unmasked repeats in your genome, especially in high density will impede downstream annotation. Therefore, it is crucial to generate a species-specific repeat library in such cases.

Script to generate custom species-specific repeats library can be found here [run_repeatmodeler.sh](https://github.com/kango2/pogo/blob/main/cmdscripts/run_repeatmodeler.sh). It can be launched as follows.
```
export workingdir="/path/to/working_directory"
export inputgenome="/path/to/genome.fa"
export species="Species_name"
qsub -P ${PROJECT} -o ${workingdir} -v workingdir=${workingdir},inputgenome=${inputgenome},species=${species} run_repeatmodeler.sh
```
OR a one liner
```
qsub -P ${PROJECT} -o /path/to/workingdir -v workingdir=/path/to/workingdir,inputgenome=/path/to/genome.fa,species=Species_name run_repeatmodeler.sh
```
The output repeat library (location below) can be used as a custom repeats library in RepeatMasker to mask your genome, or you could concatenate this species-specific library with your taxon repeats library and use that instead.
NOTES:
1. For whatever reason, local installation of RepeatModeler will run slower than conda installation (significantly slower, possibly a bug on the software's end), it is therefore why this script uses the conda installation of RepeatModeler 2.0.4 on NCI gadi.
2. The LTR pipeline within RepeatModeler does not seem to be working, therefore it is excluded in the parameters.
3. **Output files:** `${workingdir}/database/${species}-families.fa` and `${workingdir}/database/${species}-families.stk`
 
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
for i in ../bpadata/Bassiana_duperreyi/projects/Trinity/*/*.Trinity.fasta; do inputfasta=$(realpath $i); for c in 1 241 481; do qsub -P xl04 -o /path/to/exonerate/logs -v querychunktotal=720,querychunkstart=$c,querychunkend=$((c+239)),outputdir=/path/to/exonerate/output,inputfasta=${inputfasta},targetgenome=/path/to/genome.fasta runexonerate.sh; done; done
```

NOTES:
1. **Resource usage:** 1 hour 30 minutes (request 3 hours), 88 service units (SU) per chunk, 36GB RAM, 48 ncpus for a transcriptome
2. 
