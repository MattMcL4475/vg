#!/usr/bin/env bash

BASH_TAP_ROOT=../bash-tap
. ../bash-tap/bash-tap-bootstrap

PATH=..:$PATH # for vg


plan tests 14

is $(vg construct -r small/x.fa -v small/x.vcf.gz | vg stats -z - | grep nodes | cut -f 2) 210 "construction produces the right number of nodes"

is $(vg construct -r small/x.fa -v small/x.vcf.gz | vg stats -z - | grep edges | cut -f 2) 291 "construction produces the right number of edges"

vg construct -r 1mb1kgp/z.fa -v 1mb1kgp/z.vcf.gz >z.vg
is $? 0 "construction of a 1 megabase graph from the 1000 Genomes succeeds"

nodes=$(vg stats -z z.vg | head -1 | cut -f 2)
is $nodes 84553 "the 1mb graph has the expected number of nodes"

edges=$(vg stats -z z.vg | tail -1 | cut -f 2)
is $edges 115357 "the 1mb graph has the expected number of edges"

rm -f z.vg

vg construct -r complex/c.fa -v complex/c.vcf.gz >c.vg
is $? 0 "construction of a very complex region succeeds"

nodes=$(vg stats -z c.vg | head -1 | cut -f 2)
is $nodes 71 "the complex graph has the expected number of nodes"

edges=$(vg stats -z c.vg | tail -1 | cut -f 2)
is $edges 116 "the complex graph has the expected number of edges"

rm -f c.vg

order_a=$(vg construct -r order/n.fa -v order/x.vcf.gz | md5sum | cut -f 1 -d\ )
order_b=$(vg construct -r order/n.fa -v order/y.vcf.gz | md5sum | cut -f 1 -d\ )

is $order_a $order_b "the ordering of variants at the same position has no effect on the resulting graph"

vg construct -r order/n.fa -v order/z.vcf.gz -R n:47-73 >/dev/null
is $? 0 "construction does not fail when the first position in the VCF is repeated and has an indel"

x1=$(for i in $(seq 100); do size=$(shuf -i 1-100 -n 1); threads=1; vg construct -r small/x.fa -v small/x.vcf.gz -z $size -t $threads | vg view -g - | sort -n -k 2 | md5sum; done | sort | uniq | wc -l)

is $x1 1 "the size of the regions used in construction has no effect on the graph"

x2=$(for i in $(seq 100); do size=10; threads=$(shuf -i 1-100 -n 1); vg construct -r small/x.fa -v small/x.vcf.gz -z $size -t $threads | vg view -g - | sort -n -k 2 | md5sum; done | sort | uniq | wc -l)

is $x2 1 "the number of threads used in construction has no effect on the graph"

x3=$(for i in $(seq 100); do size=$(shuf -i 1-100 -n 1); threads=$(shuf -i 1-100 -n 1); vg construct -r small/x.fa -v small/x.vcf.gz -z $size -t $threads | vg view -g - | sort -n -k 2 | md5sum; done | sort | uniq | wc -l)

is $x3 1 "the number of threads and regions used in construction has no effect on the graph"

vg construct -r 1mb1kgp/z.fa -v 1mb1kgp/z.vcf.gz -R z:10-20 >/dev/null
is $? 0 "construction of a graph with two head nodes succeeds"

# in case there were failures in topological sort
rm -f fail.vg

