#!/bin/bash
SRC_DIR=~/phone/000_Personal
cd $SRC_DIR

for f1 in * 
do 

	# if [ -d "$f1" ]
	# then
	# 	cd $SRC_DIR/$f1
		
	# 	for f2 in * 
	# 	do 			
	# 		if [ -d "$f2" ]
	# 		then
	# 			find $SRC_DIR/Clipping -maxdepth 1 -type f -exec grep -q "subs: ${f2}" {} \; -exec mv {} $SRC_DIR/${f1}/${f2} \; 
				
	# 		fi
	# 	done
	# 	cd ..
	# fi

	if [ -d "$f1" ]
	then
		find $SRC_DIR/Clipping -maxdepth 1 -type f -exec grep -q "tags: ${f1}" {} \; -exec mv -i {} $SRC_DIR/${f1} \; 
	fi
done
