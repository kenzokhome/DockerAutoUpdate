#!/bin/bash

DIR=path/to/dockercompose/folder/here
CURRENTDIR=$(pwd)
cd $DIR
for d in */ ; do
    [ -L "${d%/}" ] && continue
    echo "$d"
    cd $d
    d2=${d::-1}
    docker compose pull
    docker compose down
    docker compose up -d
    docker system prune -f
    cd ..
done

cd $CURRENTDIR
