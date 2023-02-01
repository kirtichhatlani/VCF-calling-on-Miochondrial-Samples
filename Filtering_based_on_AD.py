#!/usr/bin/env python3
import pandas
import to_csv
import argparse

'''for sample in FS25-H8 FS25-T8 FS25-HP FS25-TP
do
python Filtering_based_on_AD.py -t ${sample}.tsv -o ${sample}_filtered.tsv
done'''

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--tsv", help = "tsv file containing variants")
parser.add_argument("-o", "--outputfile", help = "name of output file")
args = parser.parse_args()

inputfile = args.t
outputfile = args.o

vc=pandas.read_csv(inputfile, sep = '\t')
vc[['[AD REF]','[AD ALT1]','[AD ALT2]']] = vc['[AD]'].str.split(',', expand=True)
vc['[AD ALT2]'].replace({None:0}, inplace=True)
vc = vc.astype({'[AD ALT2]': int, '[AD REF]': int, '[AD ALT1]': int})
vc['[Sum of AD]']=vc['[AD REF]']+vc['[AD ALT1]'] + vc['[AD ALT2]']
vc['[Divide_of_ALT1]']=vc['[AD ALT1]'] / vc['[Sum of AD]']
vc['%_ALT1']=vc['[Divide_of_ALT1]']*100
vc['[Divide_of_ALT2]']=vc['[AD ALT2]'] / vc['[Sum of AD]']
vc['%_ALT2']=vc['[Divide_of_ALT2]']*100
del vc['[Divide_of_ALT2]']
del vc['[Divide_of_ALT1]']
vc_filtered = vc[vc['%_ALT1'] > 1]
vc_filtered.to_csv(outputfile, sep='\t', index=False)
