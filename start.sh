#!/bin/tcsh

set n = (`expr $argv[1] - 1`)

foreach i (`seq 0 $n`)
  ssh node-0$i "/riak/riak/bin/riak start"
end

foreach i (`seq 1 $n`)
  ssh node-0$i "/riak/riak/bin/riak-admin cluster join riak@10.1.1.2"
end

ssh node-00 "/riak/riak/bin/riak-admin cluster plan"
ssh node-00 "/riak/riak/bin/riak-admin cluster commit"
