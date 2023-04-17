ref='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/reference/filtered_hg38-chrM.fa'
bam_output='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/bams'
DB='/storage/coda1/p-fstorici3/0/kchhatlani6/DBs'

for sample in DLTB-8 TLTB-8 DLTB-P TLTB-P;
do
# variant calling
gatk Mutect2 -R $ref -I ${bam_output}/${sample}_sorted.bam --germline-resource ${DB}/af-only-gnomad.hg38.vcf.gz --panel-of-normals ${DB}/1000g_pon.hg38.vcf.gz -O ${sample}_tumoronly.vcf.gz
### changing chrM to MT for annotation
gunzip ${sample}_tumoronly.vcf.gz
sed 's/chrM/MT/g' ${sample}_tumoronly.vcf > ${sample}_tumoronlyMT.vcf
bgzip ${sample}_tumoronlyMT.vcf
done

### Index sample vcf file and dbsnp vcf file used below using bcftools index <filename>

# ANOTATION
for sample in FS25-H8 FS25-T8 FS25-HP FS25-TP
do
### Annotation for getting rsIDs
bcftools annotate -a $dbsnp/00-All.vcf.gz -c ID vcfs/${sample}_tumoronlyMT.vcf.gz > $sample}_tumoronly_rsIDs.vcf.gz
### Extracting info from vcfs into tsv form
bcftools query -f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%QUAL\t%AC\t%AF\t%AN\t%BaseQRankSum\t%DP\t%ExcessHet\t%FS\t%MLEAC\t%MLEAF\t%MQ\t%MQRankSum\t%QD\t%ReadPosRankSum\t%SOR\t[%GT]:[%AD]:[%DP]:[%GQ]:[%PL]\n' ${sample}_tumoronly_rsIDs.vcf.gz > ${sample}.temp.tsv
### Adding column names
sed '1iChr\tPOS\tID\t\tREF\tALT\tQUAL\tAC\tAF\tAN\tBQRS\tDP\tEH\tFS\tMLEAC\tMLEAF\tMQ\tMQRS\tQD\tRPRS\tSOR\t[ GT]:[ AD]:[ DP]:[ GQ]:[PL]' ${sample}.temp.tsv > ${sample}.tsv
done

rm *.temp.tsv
mkdir tsvs
mv *.tsv tsvs/
