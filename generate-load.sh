#!/usr/bin/env bash

IP="" # TODO: CHANGE ME!

# spam vote ahnold
while true; do
    curl -q -XPUT "http://${IP}:5000/api/actors/1/votes/increment"
done
