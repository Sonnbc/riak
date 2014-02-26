#!/bin/tcsh

foreach i (`seq 0 6`)
  ssh node-0$i "/riak/riak/bin/riak stop"
end
