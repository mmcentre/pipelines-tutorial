import sys

import pandas

df = pandas.read_csv(sys.argv[1], sep='\t')
s1 = sys.argv[2]
s2 = sys.argv[3]
print(f"{s1.replace('_','-')} \t{s2.replace('_','-')}\t {df[s1].corr(df[s2])}")
