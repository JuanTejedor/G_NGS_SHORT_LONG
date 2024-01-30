#!/bin/bash



mkdir 00data
mkdir 01scripts
mv command_history.sh 01scripts/
mv *fastq 00data/
mkdir 02results
mkdir 02results/fastqc_shorts
mkdir 02results/fastqc_longs

###### PREGUNTA 1. ######
# FASTQC (short reads)
 fastqc 00data/bs_illumina_R?.fastq -o 02results/fastqc_shorts/
# Trimmomatic



# FASTQC (long reads)
fastqc 00data/bs_reads_nanopore.fastq -o 02results/fastqc_longs/