#!/usr/bin/env bash

IP=35.205.57.52 # CHANGEME

while true; do
    curl -q -XPUT "http://${IP}:5000/api/actors/1/votes/increment"
done
