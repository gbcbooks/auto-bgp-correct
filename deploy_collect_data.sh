#!/bin/bash
remotehost="http://file2.gbcbooks.eu.org:8092"
scriptpath="scripts"
workdir="/usr/local/scripts/auto-bgp-correct"
databasedir="${workdir}/db"
workscriptdir="${workdir}/$scripts"


create_dir(){
    sudo mkdir ${workdir} -p
    sudo mkdir ${databasedir} -p
    sudo mkdir ${databasedir} -p
}

download_file(){
    curl -4 -s ${remotehost}/${scriptpath}/collect_data.sh -o ${workdir}/collect_data.sh
    curl -4 -s ${remotehost}/${scriptpath}/target -o ${workdir}/target
    curl -4 -s ${remotehost}/${scriptpath}/get_avg_5m_loss.sh -o ${workdir}/get_avg_5m_loss.sh
    curl -4 -s ${remotehost}/${scriptpath}/get_avg_5m_delay.sh -o ${workdir}/get_avg_5m_delay.sh
}

add_crontjob(){
    crontab -l | sed "/collect ping date/d;/collect_data.sh/d"  > /tmp/cront.tmp
    echo "## collect ping date" >> /tmp/cront.tmp
    echo "*/1 * * * * /bin/bash /usr/local/scripts/auto-bgp-correct/collect_data.sh > /dev/null 2>&1" >> /tmp/cront.tmp
    crontab /tmp/cront.tmp

}

check_user(){
    # 需要root用户执行本脚本
    user=$(env | grep "^USER=" | sed "s/=/ /" | awk '{print $2}')
    if [ $user != "root" ];then
        return 1
    else
        return 0
    fi 
}

main(){
    check_user
    if [ $? -eq 1 ];then
        echo "please run script as root !!!"
        exit 1
    fi
    create_dir
    download_file
    add_crontjob

}

main $*