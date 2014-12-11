#!/bin/bash

N=$1

for (( i = 0; i < $N; i++ ))
do
    ssh node-0$i "/riak/riak/bin/riak stop"
done