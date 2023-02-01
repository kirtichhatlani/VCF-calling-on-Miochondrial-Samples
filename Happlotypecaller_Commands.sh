ref='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/reference/hu-mito/filtered_hg38-chrM.fa'
readpath='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/DNA-seq/trimmed/'
dbsnp='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/dbSNP'

# INEDXING REF GENOME
bwa index $ref
gatk CreateSequenceDictionary -R $ref

# ALIGNMENT
for sample in FS25-H8 FS25-T8 FS25-HP FS25-TP
do
### mapping 2 reads with ref genome
bwa mem -R '@RG\tID:foo\tSM:bar\tLB:library1' $ref $readpath/${sample}_R1_001_val_1.fq  $readpath/${sample}_S4_L001_R2_001_val_2.fq > ${sample}_lane.sam
### sam to bam
samtools fixmate -O bam ${sample}_lane.sam ${sample}_lane_fixmate.bam
### sorting bam file
samtools sort -O bam -o ${sample}_lane_sorted.bam ${sample}_lane_fixmate.bam
### indexing bam file
samtools index ${sample}_lane_sorted.bam
### variant calling
gatk --java-options "-Xmx8G" HaplotypeCaller -R $ref -I ${sample}_lane_sorted.bam -O ${sample}.g.vcf.gz
done

mkdir vcfs
mv *.g.vcf.gz vcfs/

### Index sample vcf file and dbsnp vcf file used below using bcftools index <filename>

# ANOTATION
for sample in FS25-H8 FS25-T8 FS25-HP FS25-TP
do
### Annotation for getting rsIDs
bcftools annotate -a $dbsnp/00-All.vcf.gz -c ID vcfs/${sample}.g.vcf.gz > $sample}_rsIDs.vcf.gz
### Extracting info from vcfs into tsv form
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%AC\t%AF\t%AN\t%BaseQRankSum\t%DP\t%ExcessHet\t%FS\t%MLEAC\t%MLEAF\t%MQ\t%MQRankSum\t%QD\t%ReadPosRankSum\t%SOR\t[%GT]:[%AD]:[%DP]:[%GQ]:[%PL]\n' ${sample}_rsIDs.vcf.gz > ${sample}.temp.tsv
### Adding column names
sed '1iChr\tPOS\tID\t\tREF\tALT\tQUAL\tAC\tAF\tAN\tBQRS\tDP\tEH\tFS\tMLEAC\tMLEAF\tMQ\tMQRS\tQD\tRPRS\tSOR\t[ GT]:[ AD]:[ DP]:[ GQ]:[PL]' ${sample}.temp.tsv > ${sample}.tsv
done

rm *.temp.tsv
mkdir tsvs
mv *.tsv tsvs/
