## Steps

1. Archive data
    - check md5sums on transfer
    - Files: `_subreads.bam`, `_ccs.bam`, `_metadata.xml`, `_HiFi_QC.pdf`, `_ccs_statistics.csv` 
2. Convert `_ccs.bam` files to fast[qa] files
    - Remove adapater sequences. See [here](https://doi.org/10.1186/s12864-022-08375-1) for details.
    - Convert to fastq and fasta files for different applications
    - Record md5sum of data and zipped file for tracking
    - Archive fastq files for posterity.
    - All steps can be done by using [pacbiobam2fastx.sh](https://github.com/kango2/pogo/blob/main/hifiasm/pacbiobam2fastx.sh) script (except archiving).
