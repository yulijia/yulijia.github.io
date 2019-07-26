#!/bin/bash

/home/admin/software/FastQC/fastqc -t 1 \
-o /home/admin/project/out \
--noextract \
-d /home/admin/project/tmp \
-f fastq \
/home/admin/ILLUMINA_FASTQ/cancer_R1.fq.gz \
/home/admin/ILLUMINA_FASTQ/cancer_R2.fq.gz


java -Xmx4G \
-jar /home/admin/software/Trimmomatic-0.36/trimmomatic-0.36.jar PE \
-threads 1 \
-phred64 \
../in/cancer_R1.fq.gz \
../in/cancer_R2.fq.gz \
../out/cancer_R1.trimed.fq.gz \
../out/cancer_R1.unpaired.fq.gz \
../out/cancer_R2.trimed.fq.gz \
../out/cancer_R2.unpaired.fq.gz \
TOPHRED33


/home/admin/software/bwa-0.7.12/bwa mem -M \
-t 1 \
/home/admin/database/reference/hg19/ucsc.hg19.fasta \
../out/cancer_R1.trimed.fq.gz \
../out/cancer_R2.trimed.fq.gz  > ../out/cancer.sam



/home/admin/software/bwa-0.7.12/bwa mem -M \
-t 1 \
/home/admin/database/reference/hg19/ucsc.hg19.fasta \
../out/cancer_R1.trimed.fq.gz \
../out/cancer_R2.trimed.fq.gz |\
/home/admin/software/samtools-1.9/samtools sort \
-o ../out/cancer.sorted.bam -