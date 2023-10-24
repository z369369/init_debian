#!/bin/bash
# Extract the folder names from the full paths
if [[ $1 =~ ^.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*$ ]]; then
	sleep 3
  	v1=$1
  	t1=${v1:0:10}
  	#echo "/home/lwh/Downloads/Download_Home/firefox/${t1}*" >> ~/log3.txt
  	
  	rm -rf /home/lwh/Downloads/Download_Home/firefox/${t1}*
  	sleep 3
  	
  	mv "/home/lwh/Downloads/$1" "/home/lwh/Downloads/Download_Home/firefox/"
fi
done
