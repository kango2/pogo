#!/bin/bash
#PBS -N diamond
#PBS -l ncpus=32,walltime=3:00:00,storage=gdata/if89+gdata/xl04,mem=80GB,jobfs=80GB
#PBS -j oe
#PBS -M z5205618@ad.unsw.edu.au
#PBS -m ae


module load diamond/2.1.9

export uniprot_sprot="/g/data/xl04/hrp561/basdurnaseq/uniprot_sprot.diamond.db.dmnd"

diamond blastx --db ${uniprot_sprot} \
--out /g/data/xl04/jc4878/Bassiana_publication_trinity/diamondout/${base}_renamed.vs.sprot.out \
--query ${trinity_out} \
--outfmt 6 \
--max-target-seqs 1 --max-hsps 1 --threads ${PBS_NCPUS}
