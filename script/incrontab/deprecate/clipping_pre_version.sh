#!/bin/bash
cd ~/phone/000_Personal

for f in *
do  
	echo $f
	find ~/phone/000_Personal/Clipping -maxdepth 1 -type f -exec grep -q "tags: ${f}" {} \; -exec mv -i {} ./${f} \; 
done
