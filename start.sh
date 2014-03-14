#!/bin/bash

N=$1

for (( i = 0; i < $N; i++ ))
do
    ssh node-0$i "/riak/riak/bin/riak start"
done

for (( i = 1; i < $N; i++ ))
do
    ssh node-0$i "/riak/riak/bin/riak-admin cluster join riak@10.1.1.2"
done

ssh node-00 "/riak/riak/bin/riak-admin cluster plan"
ssh node-00 "/riak/riak/bin/riak-admin cluster commit"