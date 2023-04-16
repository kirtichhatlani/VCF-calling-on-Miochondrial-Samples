ref='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/reference/filtered_hg38-chrM.fa'
readpath='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/DNA-seq/'
dbsnp='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/for_annotation/dbSNP'
bam_output='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/bams'
DB='/storage/coda1/p-fstorici3/0/kchhatlani6/DBs'

# INEDXING REF GENOME
bwa index $ref
gatk CreateSequenceDictionary -R $ref

# ALIGNMENT
for sample in H8 T8 HP TP;
do
# mapping 2 reads with ref genome
bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref $readpath/FS25-${sample}_S4_L001_R1_001_val_1.fq  $readpath/FS25-${sample}_S4_L001_R2_001_val_2.fq > ${bam_output}/${sample}.sam
# sam to bam
samtools fixmate -O bam ${bam_output}/${sample}.sam ${bam_output}/${sample}_fixmate.bam
# sorting bam file
samtools sort -O bam -o ${bam_output}/${sample}_sorted.bam ${bam_output}/${sample}_fixmate.bam
# indexing bam file
samtools index ${sample}_sorted.bam
done
