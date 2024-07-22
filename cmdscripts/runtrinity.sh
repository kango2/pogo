#!/bin/bash
#PBS -lncpus=48,mem=190GB,walltime=48:00:00,storage=gdata/xl04+gdata/if89,jobfs=400GB
#PBS -N trinity
#PBS -P xl04

set -e
module use /g/data/if89/apps/modulefiles
module unload samtools jellyfish bowtie2 salmon python3/3.9.2 trinity/2.12.0
module load samtools jellyfish bowtie2 salmon python3/3.9.2 trinity/2.12.0

if [[ -e ${outputdir}/${fileid}.trinity.done || -e ${outputdir}/${fileid}.trinity.running ]]
then
	echo "Nothing to do for ${fileid}"
else
	touch ${outputdir}/${fileid}.trinity.running
	starttime=`date`
    if [ "$seqtype" = "SE" ]; then
        if [ "$sstype" = "US" ]; then
            Trinity --min_kmer_cov 3 --no_version_check \
			--CPU ${PBS_NCPUS} \
			--trimmomatic \
			--output $PBS_JOBFS/${fileid}.trinity \
			--full_cleanup --seqType fq --max_memory 190G \
			--single ${leftfq}
        else
            Trinity --min_kmer_cov 3 --no_version_check \
			--SS_lib_type ${sstype} \
			--CPU ${PBS_NCPUS} \
			--trimmomatic \
			--output $PBS_JOBFS/${fileid}.trinity \
			--full_cleanup --seqType fq --max_memory 190G \
			--single ${leftfq}
        fi
    elif [ "$seqtype" = "PE" ]; then
        if [ "$sstype" = "US" ]; then
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
    else
        echo -e "ERROR: Unexpected value for \$seqtype, please select either SE or PE in trinity.filelist. Stopping script."
        exit 1
    fi
    endtime=`date`
	rsync -a $PBS_JOBFS/${fileid}.trinity.Trinity.fasta ${outputdir}/
	rsync -a $PBS_JOBFS/${fileid}.trinity.Trinity.fasta.gene_trans_map ${outputdir}/
	echo ${fileid} start:${starttime} end:${endtime} > ${outputdir}/${fileid}.trinity.done
	rm ${outputdir}/${fileid}.trinity.running
fi
