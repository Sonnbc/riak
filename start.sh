#!/bin/bash

N=$1

for (( i = 0; i < $N; i++ ))
do
    echo "starting $i"
    ssh node-0$i "ulimit -n 4096; /riak/riak/bin/riak start"
done

for (( i = 1; i < $N; i++ ))
do
    echo "connecting $i"
    ssh node-0$i "/riak/riak/bin/riak-admin cluster join riak@10.1.1.2"
done

ssh node-00 "/riak/riak/bin/riak-admin cluster plan"
ssh node-00 "/riak/riak/bin/riak-admin cluster commit"