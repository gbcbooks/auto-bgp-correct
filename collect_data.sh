#!/bin/bash

 #default path
path_dir=/usr/local/scripts/auto-bgp-correct
cd $path_dir

main() {
    init
    clock=$(date +%Y-%m-%d\ %H:%M:%S)
    alltargats=$(cat target | sort | uniq | xargs )
    alldata=$(fping ${alltargats} -c 100 -i 1 -p 10 -t 1000 -q 2>&1)
    for item in $(cat $path_dir/target)
    do
        itemdata=$(echo "${alldata}" | grep ${item} | sed "s/,/\//;s/\// /g;s/%//g;s/ \+/ /g" | cut -d " " -f 9,15)
        echo "$clock ${itemdata}" >> $path_dir/db/${item}.log
    done
}
main $*