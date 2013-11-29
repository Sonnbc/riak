#!/bin/bash

REMOTE_DIR=/tmp
HOSTS='./hosts'

usage()
{
    echo "usage: $1 -u username [-d riak_directory|-s|-t]"
    echo "actions: -d (deploy), -s (start), -t (shutdown)"
    exit -1
}

deploy()
{
    echo "Deploy"
    i=0
    while read line; do 
        prev_host=$host
        host=$(echo $line | awk '{print $1}')
        ip=$(echo $line | awk '{print $2}')
        i=$((i+1))
        echo "Copy riak #$i to host $host..."
        rsync -az --delete $riak_dir $username@$host:$REMOTE_DIR
        ssh $username@$host "
            cd $REMOTE_DIR/riak;
            sed -i -e 's/127.0.0.1/$host/g' ./etc/vm.args;
            sed -i -e 's/127.0.0.1/$ip/g' ./etc/app.config;
            ./bin/riak start; < /dev/null
            if ! [ -z $prev_host ]; then
                ./bin/riak-admin cluster join riak@$prev_host 
            fi" < /dev/null

    done < $HOSTS

    if [ -z $host ]; then
        exit 0
    fi
    
    ssh $username@$host "
        cd $REMOTE_DIR/riak;
        ./bin/riak-admin cluster plan;
        ./bin/riak-admin cluster commit;" < /dev/null
}


start()
{
    echo "Start"
    while read line; do
       host=$(echo $line | awk '{print $1}')
       printf 'Start riak at %s...' $host 
       ssh $username@$host "
           cd $REMOTE_DIR/riak;
           ./bin/riak start;" < /dev/null
    done < $HOSTS
   
}

shutdown()
{
    echo "Shutdown"
    while read line; do
       host=$(echo $line | awk '{print $1}')
       printf 'Shutting down riak at %s...' $host 
       ssh $username@$host "
           cd $REMOTE_DIR/riak;
           ./bin/riak stop;" < /dev/null
    done < $HOSTS
}

while getopts "u:d:st" opt; do
    case "$opt" in
        u)  username=$OPTARG;;
        d)  riak_dir=$OPTARG;
            action='deploy';;
        s)  action='start';;
        t)  action='shutdown';;
    esac
done    

if [ -z "$username" ] || [ -z "$action" ]; then 
    usage $0
fi      

$action
