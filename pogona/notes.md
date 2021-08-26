## Strand specificity of RNAseq data from Pogona vitticeps

Strand specificity of RNAseq data was not recorded. Therefore, 1 sample from each RNAseq project (gonads_2018, gonads_2019, brains_2019, Pvi1.1PW and Pvi1.1TE) were mapped against Pvi1.1 reference genome using subread software as follows:

```
qsub -lstorage=gdata/xl04+gdata/te53,ncpus=16,mem=64GB,walltime=01:30:00 -V -- subread-align -n 50 --multiMapping -B 1 -T 16 --sortReadsByCoordinates -R /g/data/xl04/ag3760/RNASeq/brains_2019/AGRF_CAGRF20994_H2GKWDSXY/Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003_R2.fastq.gz -i /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.fna -r /g/data/xl04/ag3760/RNASeq/brains_2019/AGRF_CAGRF20994_H2GKWDSXY/Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003_R1.fastq.gz -t 0 -o /g/data/xl04/hrp561/pogonatranscriptome/tmp/Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003.bam
qsub -lstorage=gdata/xl04+gdata/te53,ncpus=16,mem=64GB,walltime=01:30:00 -V -- subread-align -n 50 --multiMapping -B 1 -T 16 --sortReadsByCoordinates -R /g/data/xl04/ag3760/RNASeq/gonads_2018/lane03/CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003_R2.fastq.gz -i /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.fna -r /g/data/xl04/ag3760/RNASeq/gonads_2018/lane03/CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003_R1.fastq.gz -t 0 -o /g/data/xl04/hrp561/pogonatranscriptome/tmp/CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003.bam
qsub -lstorage=gdata/xl04+gdata/te53,ncpus=16,mem=64GB,walltime=01:30:00 -V -- subread-align -n 50 --multiMapping -B 1 -T 16 --sortReadsByCoordinates -R /g/data/xl04/ag3760/RNASeq/gonads_2019/AGRF_CAGRF19863_HMHTHDSXX/Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002_R2.fastq.gz -i /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.fna -r /g/data/xl04/ag3760/RNASeq/gonads_2019/AGRF_CAGRF19863_HMHTHDSXX/Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002_R1.fastq.gz -t 0 -o /g/data/xl04/hrp561/pogonatranscriptome/tmp/Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002.bam
qsub -lstorage=gdata/xl04+gdata/te53,ncpus=16,mem=64GB,walltime=01:30:00 -V -- subread-align -n 50 --multiMapping -B 1 -T 16 --sortReadsByCoordinates -R /g/data/xl04/ag3760/RNASeq/Pvi1.1_transcriptomes/ramaciotti_transcriptomes_2013/PW1_ACAGTG_L002_R2_001.fastq.gz -i /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.fna -r /g/data/xl04/ag3760/RNASeq/Pvi1.1_transcriptomes/ramaciotti_transcriptomes_2013/PW1_ACAGTG_L002_R1_001.fastq.gz -t 0 -o /g/data/xl04/hrp561/pogonatranscriptome/tmp/PW1_ACAGTG_L002.bam 
qsub -lstorage=gdata/xl04+gdata/te53,ncpus=16,mem=64GB,walltime=01:30:00 -V -- subread-align -n 50 --multiMapping -B 1 -T 16 --sortReadsByCoordinates -R /g/data/xl04/ag3760/RNASeq/Pvi1.1_transcriptomes/bgi_transcriptomes/344319heartA/POGwqlTABRAAPEI-88_L3_2.fq.gz -i /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.fna -r /g/data/xl04/ag3760/RNASeq/Pvi1.1_transcriptomes/bgi_transcriptomes/344319heartA/POGwqlTABRAAPEI-88_L3_1.fq.gz -t 0 -o /g/data/xl04/hrp561/pogonatranscriptome/tmp/POGwqlTABRAAPEI-88_L3.bam
```

NOTE: RefSeq Genome ID: GCF_900067755.1_pvi1.1

Fragment counts were obtained as follows against refSeq annotations as follows:

```
for bam in /g/data/xl04/hrp561/pogonatranscriptome/tmp/*.bam
	do
	for strand in {0..2}
	do 
		/g/data/te53/software/subread/2.0.3/bin/featureCounts \
			-s $strand \
			-M -p -T 16 \
			-G /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.fna.gz \
			-a /g/data/xl04/hrp561/pogonatranscriptome/tmp/GCF_900067755.1_pvi1.1_genomic.gtf.gz \
			-o `dirname $bam`/`basename $bam .bam`.s$strand.counts $bam
	done
done
```

Number of reads assigned to features were observed based on strand specificity to decipher (a) if the library was strand specific and (b) if the orientation was FR or RF relative to the feature.

```
cd /g/data/xl04/hrp561/pogonatranscriptome/tmp/
grep Assigned *.summary
```

Following results were obtained for each project group

```
CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003.s0.counts.summary:Assigned	28305248
CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003.s1.counts.summary:Assigned	549762
CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003.s2.counts.summary:Assigned	27851018
Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002.s0.counts.summary:Assigned	26439460
Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002.s1.counts.summary:Assigned	672524
Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002.s2.counts.summary:Assigned	25861421
POGwqlTABRAAPEI-88_L3.s0.counts.summary:Assigned	14439933
POGwqlTABRAAPEI-88_L3.s1.counts.summary:Assigned	7432919
POGwqlTABRAAPEI-88_L3.s2.counts.summary:Assigned	7049626
Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003.s0.counts.summary:Assigned	70260115
Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003.s1.counts.summary:Assigned	930758
Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003.s2.counts.summary:Assigned	69506011
PW1_ACAGTG_L002.s0.counts.summary:Assigned	17892452
PW1_ACAGTG_L002.s1.counts.summary:Assigned	9038608
PW1_ACAGTG_L002.s2.counts.summary:Assigned	8910059
```

```
s = 0 unstranded
s = 1 stranded in FR orientation
s = 2 stranded in RF orientation
```

Table 1: Details of strand-specificity test

|project|testfile|s0|s1|s2|conclusion|
|---|---|---|---|---|---|
|gonads_2018|CD1NVANXX_3_181123_CQE--010_Other_GTTTCG_R_181108_JIMBLA_LIB2500_M003|28305248|549762|27851018|RF|
|gonads_2019|Pit_3344zz_18_1_1_HMHTHDSXX_TTCGCTGA-CGCATATT_L002|26439460|672524|25861421|RF|
|Pvi1.1TE|POGwqlTABRAAPEI-88_L3|14439933|7432919|7049626|Unstranded|
|brains_2019|Pvit01_H2GKWDSXY_GGCTTAAG-TCGTGACC_L003|70260115|930758|69506011|RF|
|Pvi1.1PW|PW1_ACAGTG_L002|17892452|9038608|8910059|Unstranded|

