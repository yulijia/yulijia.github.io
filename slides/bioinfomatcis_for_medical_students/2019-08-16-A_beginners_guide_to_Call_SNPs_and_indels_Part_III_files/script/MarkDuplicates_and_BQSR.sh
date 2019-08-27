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
-threads 10 \
-phred64 \
../in/cancer_R1.fq.gz \
../in/cancer_R2.fq.gz \
../in/normal_R1.fq.gz \
../in/normal_R2.fq.gz \
../out/cancer_R1.trimed.fq.gz \
../out/cancer_R1.unpaired.fq.gz \
../out/cancer_R2.trimed.fq.gz \
../out/cancer_R2.unpaired.fq.gz \
../out/normal_R1.trimed.fq.gz \
../out/normal_R1.unpaired.fq.gz \
../out/normal_R2.trimed.fq.gz \
../out/normal_R2.unpaired.fq.gz \
TOPHRED33


/home/admin/software/bwa-0.7.12/bwa mem -M \
-t 1 \
/home/admin/database/reference/hg19/ucsc.hg19.fasta \
../out/cancer_R1.trimed.fq.gz \
../out/cancer_R2.trimed.fq.gz |\
/home/admin/software/samtools-1.9/samtools sort \
-o ../out/cancer.sorted.bam -


/home/admin/software/bwa-0.7.12/bwa mem -M \
-t 4 \
/home/admin/database/reference/hg19/ucsc.hg19.fasta \
../out/normal_R1.trimed.fq.gz \
../out/normal_R2.trimed.fq.gz |\
/home/admin/software/samtools-1.9/samtools sort \
-o ../out/normal.sorted.bam -


/home/admin/software/gatk-4.1.0.0/gatk AddOrReplaceReadGroups \
--VALIDATION_STRINGENCY=SILENT \
--RGLB=hg19 \
--RGPL=illumina \
--RGPU=hg19PU \
--RGSM=cancer \
-I=../out/cancer.sorted.bam \
-O=../out/cancer.addheader.bam 


/home/admin/software/gatk-4.1.0.0/gatk MarkDuplicatesSpark \
-I=../out/cancer.addheader.bam  \
-O=../out/cancer_marked_duplicates.bam


/home/admin/software/gatk-4.1.0.0/gatk AddOrReplaceReadGroups \
--VALIDATION_STRINGENCY=SILENT \
--RGLB=hg19 \
--RGPL=illumina \
--RGPU=hg19PU \
--RGSM=normal \
-I=../out/normal.sorted.bam \
-O=../out/normal.addheader.bam 


/home/admin/software/gatk-4.1.0.0/gatk MarkDuplicatesSpark \
-I=../out/normal.addheader.bam  \
-O=../out/normal_marked_duplicates.bam


/home/admin/software/gatk-4.1.0.0/gatk BaseRecalibrator \
-I ../out/normal_marked_duplicates.bam \
-R /home/admin/database/reference/hg19/ucsc.hg19.fasta \
--known-sites /home/admin/database/reference/hg19/dbsnp_138.hg19.vcf \
--known-sites /home/admin/database/reference/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
--known-sites /home/admin/database/reference/hg19/1000G_phase1.indels.hg19.sites.vcf \
--known-sites /home/admin/database/reference/hg19/1000G_phase1.snps.high_confidence.hg19.sites.vcf \
 -L ../in/Illumina.bed \
-O ../out/normal_recal_data.table


/home/admin/software/gatk-4.1.0.0/gatk BaseRecalibrator \
-I ../out/cancer_marked_duplicates.bam \
-R /home/admin/database/reference/hg19/ucsc.hg19.fasta \
--known-sites /home/admin/database/reference/hg19/dbsnp_138.hg19.vcf \
--known-sites /home/admin/database/reference/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
--known-sites /home/admin/database/reference/hg19/1000G_phase1.indels.hg19.sites.vcf \
--known-sites /home/admin/database/reference/hg19/1000G_phase1.snps.high_confidence.hg19.sites.vcf \
 -L ../in/Illumina.bed \
-O ../out/cancer_recal_data.table


/home/admin/software/gatk-4.1.0.0/gatk ApplyBQSR \
-R /home/admin/database/reference/hg19/ucsc.hg19.fasta \
-I ../out/cancer_marked_duplicates.bam \
--bqsr-recal-file ../out/cancer_recal_data.table \
-L ../in/Illumina.bed \
-O ../out/cancer_recal.bam


/home/admin/software/gatk-4.1.0.0/gatk ApplyBQSR \
-R /home/admin/database/reference/hg19/ucsc.hg19.fasta \
-I ../out/normal_marked_duplicates.bam \
--bqsr-recal-file ../out/normal_recal_data.table \
-L ../in/Illumina.bed \
-O ../out/normal_recal.bam


#/home/admin/software/gatk-4.1.0.0/gatk --java-options "-Xmx8G" Mutect2 \
#-R /home/admin/database/reference/hg19/ucsc.hg19.fasta \
#-I ../out/normal_recal.bam \
#-I ../out/cancer_recal.bam \
#-tumor cancer \
#-normal normal \
#--germline-resource /home/admin/database/reference/hg19/af-only-gnomad.raw.sites.hg19.vcf.gz \
#-L ../in/Illumina.bed \
#-O ../out/somatic.vcf


#gatk --java-options "-Xmx8G" FilterMutectCalls \
#-V ../out/somatic.vcf \
#-O ../out/somatic_filtered.vcf.gz

