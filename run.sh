#!/bin/bash
set -euo pipefail    # see http://redsymbol.net/articles/unofficial-bash-strict-mode/ for details
IFS=$' \t\n'

for src_file in *.asm
do
    echo "compiling $src_file"
    nasm -f elf64 -o temporary.o "$src_file"
    ld -o "${src_file%.*}" temporary.o
    rm temporary.o
done

echo "decompressing input"
7z e -y bench_input.7z bench_input.txt

rm -f results.txt

for src_file in *.asm
do
    if [ "x${src_file:0:5}" != "xslow." ]
    then
        echo "running ${src_file%.*}"
        sudo chrt -f 99 perf stat -r 5 "./${src_file%.*}" bench_input.txt 2> perf_stat.log
        echo -n "${src_file%.*}" >> results.txt
        grep task-clock < perf_stat.log | cut -f1 -d, | sort -n >> results.txt
        rm perf_stat.log
    fi
done

#for src_file in *.asm
#do
#    if [ "x${src_file:0:5}" == "xslow." ]
#    then
#        echo "running ${src_file%.*}"
#        sudo chrt -f 99 perf stat "./${src_file%.*}" bench_input.txt 2> perf_stat.log
#        echo -n "${src_file%.*}" >> results.txt
#        grep task-clock < perf_stat.log | cut -f1 -d, | sort -n >> results.txt
#        rm perf_stat.log
#    fi
#done

echo "results:"
sort -k 2 -n < results.txt
