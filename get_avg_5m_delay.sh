#!/bin/bash
path_dir=/usr/local/scripts/auto-bgp-correct
script_dir=$path_dir/script
n=5

main (){
    sum=0
    for k in $(tail -n $n $path_dir/db/${1}.log | cut -f 4 -d " ")
    do
            sum=$(echo "$sum $k" | awk '{printf "%.2f\n",$1+$2}')
    done
    #echo "#!/bin/bash" > $path_dir/env
    echo "$(echo "$sum $n" | awk '{printf "%.2f\n",$1/$2}')"
}

main $*