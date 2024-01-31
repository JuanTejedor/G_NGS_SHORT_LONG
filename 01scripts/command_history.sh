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


###### PREGUNTA 4. ######
# CORRECCIÓN ENSAMBLAJE MEDAKA (long reads)
mkdir 02results/medaka
medaka_consensus \
-i 00data/bs_reads_nanopore.fastq \
-d 02results/flye/assembly.fasta \
-t 6 \
-o 02results/medaka
# ruta ensamblaje pulido: 02results/medaka/consensus.fasta

###### PREGUNTA 5. ######
# ENSAMBLAJE UNICYCLER (long + short reads)
mkdir 02results/unicycler
unicycler \
-1 02results/trimmomatic/trimmed_1P.fastq \
-2 02results/trimmomatic/trimmed_2P.fastq \
-l 00data/bs_reads_nanopore.fastq \
-o 02results/unicycler \
-t 6
# ruta ensamblaje: 02results/unicycler/assembly.fasta


###### PREGUNTA 6. ######
# ESTADÍSTICAS SEQSTATS Y QUAST (ensamblaje FLYE + MEDAKA + UNICYCLER)
# FLYE
mkdir 02results/flye/quast
mkdir 02results/flye/seqstats
quast \
02results/flye/assembly.fasta \
-m 10000 \
-t 10 \
-o 02results/flye/quast
seqstats 02results/flye/assembly.fasta > 02results/flye/seqstats/stats.txt

# MEDAKA
mkdir 02results/medaka/quast
mkdir 02results/medaka/seqstats
quast \
02results/medaka/consensus.fasta \
-m 10000 \
-t 10 \
-o 02results/medaka/quast
seqstats 02results/medaka/consensus.fasta > 02results/medaka/seqstats/stats.txt

# UNICYCLER
mkdir 02results/unicycler/quast
mkdir 02results/unicycler/seqstats
quast \
02results/unicycler/assembly.fasta \
-m 10000 \
-t 10 \
-o 02results/unicycler/quast
seqstats 02results/unicycler/assembly.fasta > 02results/unicycler/seqstats/stats.txt






###### PREGUNTA 8. ######
# ANOTACIÓN CON PROKKA
mkdir 03final_reports/prokka 

prokka \
--addgenes \
--mincontiglen 10000 \
--cpus 10 \
--outdir 02results/prokka/ \
02results/unicycler/assembly.fasta