#!/bin/bash
#SBATCH --job-name=STAR_alignment                           # Job name 
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
OUTDIR="/scratch/kt96951/workdir/rna_seq/genome_index/star_results"


#if output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

#paths 

FASTQ_DIR="/home/kt96951/rna_seq/cornsnake_fastq"
INDEX_DIR="/scratch/kt96951/workdir/rna_seq/genome_index"

#load modules 

module load STAR/2.7.11b-GCC-13.3.0
module load SAMtools/1.21-GCC-13.3.0

#the loop 

for R1_FILE in *_F.fastq.gz; do
    R2_FILE=${R1_FILE/_F.fastq.gz/_R.fastq.gz}
    SAMPLE_NAME=${R1_FILE/_F.fastq.gz/}
    STAR --runThreadN 12 \
    --genomeDir $INDEX_DIR \
    --readFilesIn $R1_FILE $R2_FILE \
    --readFilesCommand zcat \
    --outSAMtype BAM SortedByCoordinate \
    --outSAMunmapped Within \
    --outSAMattributes Standard \
    --quantMode GeneCounts \
    --outFileNamePrefix ${OUT_DIR}/${SAMPLE_NAME}_
    BAM_FILE="${OUT_DIR}/${SAMPLE_NAME}_Aligned.sortedByCoord.out.bam"
    if [ -f "$BAM_FILE" ]; then
        samtools index -@ 12 "$BAM_FILE"
        samtools flagstat -@ 12 "$BAM_FILE" > "${BAM_FILE%.bam}_flagstat.txt"
    fi
done



