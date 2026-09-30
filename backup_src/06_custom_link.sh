#!/bin/bash
while IFS='=' read -r col1 col2
do 
    rm -rf "$col2"
    ln -s "$col1" "$col2"
    echo "ln -s $col1 $col2"
    echo "-----"
done <custom_link.properties
