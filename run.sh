#!/bin/bash

REMOTE_DIR=/riak
REL_DIR=/scratch/Confluence/riak/riak/riak-1.4.2/rel/riak
HOSTS='./hosts'

usage()
{
    echo "usage: $1 -u username [-d|-s|-t|-c]"
    echo "actions: -d (deploy), -s (start), -t (shutdown), -c (change shell to bash)"
    exit -1
}

deploy()
{
    #TODO: currently have to join by hand. need to automate
    echo "Deploy"
    i=0
    while read line; do 
        prev_host=$host
        host=$(echo $line | awk '{print $1}')
        ip=$(echo $line | awk '{print $2}')
        echo "Deploy riak #$i to host $host..."
        ssh -t node-0$i "
            sudo rm -rf $REMOTE_DIR;
            sudo mkdir $REMOTE_DIR;
            sudo chown -R $username: $REMOTE_DIR;
            cp -rf $REL_DIR $REMOTE_DIR/;
            cd $REMOTE_DIR/riak;
            sed -i -e 's/127.0.0.1/$host/g' ./etc/vm.args;
            sed -i -e 's/127.0.0.1/$ip/g' ./etc/app.config;
            " < /dev/null
            #ulimit -n 4096;
            #./bin/riak start;
            #if ! [ -z $prev_host ]; then
            #    ./bin/riak-admin cluster join riak@$prev_host 
            #fi" < /dev/null
        i=$((i+1))    
    done < $HOSTS

    if [ -z $host ]; then
        exit 0
    fi
    
    #ssh $username@$host "
    #    cd $REMOTE_DIR/riak;
    #    ./bin/riak-admin cluster plan;
    #    ./bin/riak-admin cluster commit;" < /dev/null
}


changeshell()
{
    echo "Change shell"
    while read line; do
       host=$(echo $line | awk '{print $2}')
       printf 'Change shell to bash at %s...' $host
       printf "ssh $username@$host" 
       ssh -t $username@$host "chsh -s /bin/bash;" < /dev/null
    done < $HOSTS
}

start()
{
    echo "Start"
    while read line; do
       host=$(echo $line | awk '{print $2}')
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
       host=$(echo $line | awk '{print $2}')
       printf 'Shut down riak at %s...' $host 
       ssh $username@$host "
           cd $REMOTE_DIR/riak;
           ./bin/riak stop;" < /dev/null
    done < $HOSTS
}

while getopts "u:dstc" opt; do
    case "$opt" in
        u)  username=$OPTARG;;
        d)  action='deploy';;
        s)  action='start';;
        t)  action='shutdown';;
        c)  action='changeshell';;
    esac
done    

if [ -z "$username" ] || [ -z "$action" ]; then 
    usage $0
fi      

$action
