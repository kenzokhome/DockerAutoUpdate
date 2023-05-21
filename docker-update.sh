#!/bin/bash

DIR=put/your/dockercompose/path/here
FILE=~/Scripts/dockerContainersList.txt

if [ -f "$FILE" ]; 
	then
		rm -R ~/Scripts/dockerContainersList.txt
	else
		mkdir ~/Scripts
fi

DIUN=$(docker ps --format {{.Names}} | grep "diun" | sed "s/:.*//g");
docker exec $DIUN diun image list >> ~/Scripts/dockerContainersList.txt

CURRENTDIR=$(pwd)
cd $DIR

for d in */ ; do
	[ -L "${d%/}" ] && continue
	echo "$d"
	cd $d
	d2=${d::-1}
	update_required=true
	IMAGES=$(cat docker-compose.yml | grep "image:" | sed -e 's/image: //g' | sed -e 's/'"'"'//g' | sed -e 's/\"//g');
	IFS=' ' read -r -a array <<< "$IMAGES"
	for element in "${array[@]}"
		do
#			localElement=$(echo "${array[0]}" | sed "s/:.*//g")
			localElement=$(echo "$element" | sed "s/:.*//g")
			LATEST=$(cat $FILE | grep $localElement | sed "s/.*sha256://g" | sed -e 's/ //g' | sed -e 's/|//g');
			DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' $element | sed "s/.*://g");
			if [[ $LATEST == $DIGEST ]];
				then
					echo "$element doesn't require updating. Skipping!"
					update_required=false
					continue
				else
					echo "$element can be updated. Proceeding!"
					update_required=true
					break
			fi
			echo "$element"
		done

	if [ "$update_required" = true ] ; 
		then
			echo 'We should update!'
			docker compose pull
			DOCKER=$(docker ps --format {{.Image}} | grep ${array[0]} | sed "s/:.*//g");
			if [[ $DOCKER != ${array[0]} ]];
#			if [[ $? != 0 ]];
				then
					echo "$d2, is not running."
					docker system prune -f
				else
					echo "$d2, is running. Updating! Please wait!"
					docker compose down
					docker compose up -d
					docker system prune -f
			fi
	fi
	cd ..
done

cd $CURRENTDIR
