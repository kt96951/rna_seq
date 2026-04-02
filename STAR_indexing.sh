#!/bin/bash
#SBATCH --job-name=STAR_index                               # Job name 
#SBATCH --partition=batch                                   # Partition name (batch, highmem, or gpu)
#SBATCH --ntasks=1                                          # 1 task (process) for below commands
#SBATCH --cpus-per-task=12                                  # CPU core count per task, by default 1
#SBATCH --mem=64G                                           # Memory per node (8GB); by default using M as unit
#SBATCH --time=24:00:00                                     # Time limit hrs:mins:secs or days-hrs:mins:secs
#SBATCH --export=NONE                                   
#SBATCH --error=/scratch/kt96951/workdir/rna_seq/%x_%j.err  # standard error log 
#SBATCH --output=/scratch/kt96951/workdir/rna_seq/%x_%j.out # Standard output log, e.g., testBowtie2_12345.out
#SBATCH --mail-user=kt96951@uga.edu                         # Where to send mail
#SBATCH --mail-type=All                                     # Mail events (BEGIN, END, FAIL, ALL)

#set output directory variable
OUTDIR="/scratch/kt96951/workdir/rna_seq/genome_index"


#if output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

#load module 

module load STAR/2.7.11b-GCC-13.3.0

#index the genome 

GENOME_FASTA="/home/kt96951/rna_seq/GCF_029531705.1_CU_Pguttatus_1_genomic.fna"
GENOME_GTF="/home/kt96951/rna_seq/GCF_029531705.1_CU_Pguttatus_1_genomic.gtf"
INDEX_DIR="/scratch/kt96951/workdir/rna_seq/genome_index"

STAR --runThreadN 12 \
     --runMode genomeGenerate \
     --genomeDir $INDEX_DIR \
     --genomeFastaFiles $GENOME_FASTA \
     --sjdbGTFfile $GENOME_GTF \
     --sjdbOverhang 50 \
     --quantMode GeneCounts \
     

