#!/usr/bin/env python3
import pandas
import to_csv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-t", "--tsv", help = "tsv file containing variants")
args = parser.parse_args()

sample = args.t

vc=pandas.read_csv(sample, sep = '\t')
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
vc_filtered.to_csv(sample, sep='\t', index=False)
