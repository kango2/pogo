# PacBio HiFi Assembly

1. Archive data
    - check md5sums on transfer
    - Files: `_subreads.bam`, `_ccs.bam`, `_metadata.xml`, `_HiFi_QC.pdf`, `_ccs_statistics.csv` 
2. Convert `_ccs.bam` files to `fast[qa]` files
    - Remove adapater sequences. See [here](https://doi.org/10.1186/s12864-022-08375-1) for details.
    - Convert to fastq and fasta files for different applications
    - Record md5sum of data and zipped file for tracking
    - Archive fastq files for posterity.
    - All steps can be done by using [pacbiobam2fastx.sh](https://github.com/kango2/pogo/blob/main/hifiasm/pacbiobam2fastx.sh) script (except archiving).
3. Run [hifiasm](https://github.com/chhylp123/hifiasm) assembly

```
module load hifiasm
qsub -q hugemem -V -j oe -N hifiasm -o /path/to/logs/ \
-l ncpus=48,mem=1470GB,walltime=48:00:00,storage=gdata/yourProject+gdata/if89 --\
hifiasm -o /path/to/output/directory/assembly_basename -t 48 input1.fq.gz input2.fq.gz [....]
```

4. Get error corrected reads for other applications
5. Compress and create tar archive of output text files. 
6. Convert `.gfa` to `.fasta` files.
