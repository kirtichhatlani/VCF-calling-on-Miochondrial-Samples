ref='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/reference/hu-mito/filtered_hg38-chrM.fa'
vcfpath='/storage/coda1/p-fstorici3/0/kchhatlani6/hu-mito/T8/Mutect'

for sample in DLTB-8 TLTB-8 DLTB-P TLTB-P
cat $ref | bcftools consensus $vcfpath/${sample}_tumoronly.vcf.gz > ${sample}.fa
## test.bed has co-ordinates of ND6 region of mtDNA
bedtools getfasta -fi ${sample}.fa -bed test.bed -fo ${sample}_ND6.fa
