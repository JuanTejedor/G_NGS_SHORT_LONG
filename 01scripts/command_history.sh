#!/bin/bash



mkdir 00data
mkdir 01scripts
mv command_history.sh 01scripts/
mv *fastq 00data/
mkdir 02results
mkdir 03final_reports 



###### PREGUNTA 1. ######
# FASTQC (short reads) (PRE)
mkdir 02results/fastqc_shorts
fastqc 00data/bs_illumina_R?.fastq -o 02results/fastqc_shorts/

# Trimmomatic
mkdir 02results/trimmomatic
trimmomatic PE \
-trimlog 02results/trimmomatic/log.txt \
-threads 6 \
00data/bs_illumina_R1.fastq \
00data/bs_illumina_R2.fastq \
02results/trimmomatic/trimmed_1P.fastq \
02results/trimmomatic/trimmed_1U.fastq \
02results/trimmomatic/trimmed_2P.fastq \
02results/trimmomatic/trimmed_2U.fastq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
LEADING:3 \
TRAILING:3 \
SLIDINGWINDOW:4:15 \
HEADCROP:12 \
MINLEN:50

# FASTQC (short reads) (POST)
fastqc 02results/trimmomatic/trimmed_1P.fastq 02results/trimmomatic/trimmed_2P.fastq -o 02results/fastqc_shorts/



###### PREGUNTA 2. ######
# FASTQC (long reads)
mkdir 02results/fastqc_longs
fastqc 00data/bs_reads_nanopore.fastq -o 02results/fastqc_longs/

###### PREGUNTA 3. ######
# ENSAMBLAJE FLYE (long reads)
mkdir 02results/flye
flye \
--nano-raw 00data/bs_reads_nanopore.fastq \
-g 4m \
-i 1 \
-t 6 \
-o 02results/flye
# ruta ensamblaje: 02results/flye/assembly.fasta