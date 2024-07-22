#!/bin/bash
#PBS -l ncpus=24,mem=60GB,walltime=48:00:00,storage=gdata/if89+gdata/xl04,jobfs=400GB
#PBS -N repeatmodeler
#PBS -j oe

set -ex
module use /g/data/if89/apps/modulefiles
module load RepeatModeler/2.0.4-conda

cd ${workingdir}
mkdir database
cd database
BuildDatabase -name ${species} -engine ncbi ${inputgenome}

mkdir -p $TMPDIR/${species}_RepeatModeler
cd $TMPDIR/${species}_RepeatModeler
RepeatModeler -database ${workingdir}/database/${species} -threads ${PBS_NCPUS} > ${workingdir}/out.log
export RM_folder=$(ls | grep RM_)
tar cf - ${RM_folder} | pigz -p ${PBS_NCPUS} > ${RM_folder}.tar.gz
rsync ${RM_folder}.tar.gz ${workingdir}

#output repeat library will be in ${workingdir}/database named:
#${speices}-families.fa
#${species}-families.stk
#the .fa file can be fed directory into repeatmasker for soft masking, or you can concatenate it with the taxon repeats library for better repeat coverage
