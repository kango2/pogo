#!/bin/bash
#PBS -lncpus=48,mem=190GB,walltime=48:00:00,storage=gdata/xl04+gdata/te53,jobfs=400GB
#PBS -N trinity
#PBS -P xl04

set -e
module unload samtools jellyfish bowtie2 salmon python3/3.9.2 trinity
module load samtools jellyfish bowtie2 salmon python3/3.9.2 trinity

if [[ -e ${outputdir}/${fileid}.trinity.done || -e ${outputdir}/${fileid}.trinity.running ]]
then
	echo "Nothing to do for ${fileid}"
else
	touch ${outputdir}/${fileid}.trinity.running
	starttime=`date`
	if [[ ${sstype} == "US" ]]
	then
		Trinity --min_kmer_cov 3 --no_version_check \
			--CPU ${PBS_NCPUS} \
			--trimmomatic \
			--output $PBS_JOBFS/${fileid}.trinity \
			--full_cleanup --seqType fq --max_memory 190G \
			--left ${leftfq} \
			--right ${rightfq}
	else
		Trinity --min_kmer_cov 3 --no_version_check \
			--SS_lib_type ${sstype} \
			--CPU ${PBS_NCPUS} \
			--trimmomatic \
			--output $PBS_JOBFS/${fileid}.trinity \
			--full_cleanup --seqType fq --max_memory 190G \
			--left ${leftfq} \
			--right ${rightfq}
	fi
	endtime=`date`
	rsync -a $PBS_JOBFS/${fileid}.trinity.Trinity.fasta ${outputdir}/
	rsync -a $PBS_JOBFS/${fileid}.trinity.Trinity.fasta.gene_trans_map ${outputdir}/
	echo ${fileid} start:${starttime} end:${endtime} > ${outputdir}/${fileid}.trinity.done
	rm ${outputdir}/${fileid}.trinity.running
fi