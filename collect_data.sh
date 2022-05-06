#!/bin/bash
path_dir=/usr/local/scripts/auto-bgp-correct
cd $path_dir
mthread() {
        tmpfifo="/tmp/$$.fifo"
        mkfifo $tmpfifo
        exec 4<>$tmpfifo
        rm $tmpfifo
        thread=15
        for ((i=0;i<$thread;i++));
        do
                echo ""
        done >&4

}


main() {
mthread
clock=$(date +%Y-%m-%d\ %H:%M:%S)
for i in $(cat $path_dir/target)
do
        read -u4
        {
#       echo "$clock $(ping $i -c 100 -i 0.01 -q 2>&1 | grep "packet loss" | cut -f 6 -d " " | tr "%" " ")" >> $path_dir/db/${i}.log
        echo "$clock $(ping $i -c 100 -i 0.01 -q 2>&1 | grep -E "(packet loss|rtt)" | xargs | cut -d " " -f 6,14 | sed "s/%//;s/\// /g" | cut -d " " -f 1,3)" >> $path_dir/db/${i}.log
        } &
done 

}
main