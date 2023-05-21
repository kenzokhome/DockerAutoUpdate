#!/bin/bash
echo "Bash version ${BASH_VERSION}..."
echo ""
echo "Readme: Script needs to be called with 'sudo ./dockerList-update.sh <container Folder>'"
DIR=path/to/dockercompose/folder/here
CURRENTDIR=$(pwd)
cd $DIR
CONTAINERNAMES="$@"
echo $CONTAINERNAMES
for cn in $CONTAINERNAMES ; do
    for d in */ ; do
       [ -L "${d%/}" ] && continue
          d2=${d::-1}
          if [[ $d2 == $cn ]];
             then
               echo ""
               echo "updating $d"
               echo ""
               cd $d
               docker compose pull
               docker compose down
               docker compose up -d
               docker system prune -f
               echo ""
               echo "Update completed"
               echo ""
               cd ..
          fi
    done
done
cd $CURRENTDIR
