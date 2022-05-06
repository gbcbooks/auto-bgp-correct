#!/bin/bash
path_dir=/usr/local/scripts/auto-bgp-correct
script_dir=$path_dir/script
n=5
factor=30
loss_rate=6

#仅终端打印日志
save_log(){
    ctime=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${ctime} ${taskid} [$1]:$2"
}

if_run_bebore(){
    # save_log "info" "$2 is file"
    restult=$(cat $path_dir/$2 | grep "$1" | wc -l)
    # echo "restult=$(cat $path_dir/$2 | grep "$1" | wc -l)"
    if [ $restult -ge 1 ];then
        save_log "info" "$1已执行过"
        return 0
    else
        save_log "info" "$1未执行过"
        return 1
    fi
}

compare_rate(){
if [ $1 -gt $2 ];then
    save_log "info" "邻居$3丢包大于$loss_rate,需要调整"
    if_run_bebore "$3.sh" "last_run_$3"
    if [ $? -eq 1 ];then
        sh $script_dir/$3.sh
        echo "$3.sh" > $path_dir/last_run_$3
        save_log "info" "邻居$3己下调优先级为LP:75"
    fi
else
    save_log "info" "邻居$3丢包在可控范围内"
    if_run_bebore "$3-restore.sh" "last_run_$3"
    if [ $? -eq 1 ];then
        sh $script_dir/$3-restore.sh
        echo "$3-restore.sh" > $path_dir/last_run_$3
        save_log "info" "邻居$3己恢复优先级LP:300"
    fi

fi
}

main (){
for i in $(cat $path_dir/target)
do
        sum=0
        for k in $(tail -n $n $path_dir/db/${i}.log | cut -f 3 -d " ")
        do
                sum=$[$sum+$k]
        done
        #echo "#!/bin/bash" > $path_dir/env
        echo "s$(echo "${i}"|tr "." "_")_avg=$[$sum/$n]" > $path_dir/env
        source $path_dir/env
done
us_avg=${s45_32_197_156_avg}
mia_avg=${s45_77_74_181_avg}
echo "[info]:last 5 min, us_avg loss rate is: $us_avg %"
echo "[info]:last 5 min, mia_avg loss rate is: $mia_avg %"
compare_rate "$us_avg" "$loss_rate" "45.32.197.156"
compare_rate "$mia_avg" "$loss_rate" "45.77.74.181"
}
main $*