#!/bin/bash
#SBATCH --job-name=fastQC                                   # Job name 
#SBATCH --partition=batch                                   # Partition name (batch, highmem, or gpu)
#SBATCH --ntasks=1                                          # 1 task (process) for below commands
#SBATCH --cpus-per-task=1                                   # CPU core count per task, by default 1
#SBATCH --mem=50G                                           # Memory per node (8GB); by default using M as unit
#SBATCH --time=24:00:00                                     # Time limit hrs:mins:secs or days-hrs:mins:secs
#SBATCH --export=NONE                                   
#SBATCH --error=/scratch/kt96951/workdir/rna_seq/%x_%j.err    # standard error log 
#SBATCH --output=/scratch/kt96951/workdir/rna_seq/%x_%j.out   # Standard output log, e.g., testBowtie2_12345.out
#SBATCH --mail-user=kt96951@uga.edu                         # Where to send mail
#SBATCH --mail-type=All                                     # Mail events (BEGIN, END, FAIL, ALL)

#set output directory variable
OUTDIR="/scratch/kt96951/workdir/rna_seq/qc_reports"


#1. if output directory doesn't exist, create it
if [ ! -d $OUTDIR ]
then
    mkdir -p $OUTDIR
fi

#2. Load the module 
module load FastQC/0.12.1-Java-11

#3. Run FastQC
time {
			for File in *fastq.gz; do 
		
			fastqc | -t 4 | -o qc_reports | "$FILE"
			
			
			done 
			}
			
echo -e "\n** Script ended on 'date' **"
echo "Done!" 
