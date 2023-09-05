cd ~/Pictures 
find . -type f -name '* *' -exec rename 's/ /_/g' {}  \;

cd ~/Pictures/Screenshots
find . -type f -name '* *' -exec rename 's/ /_/g' {}  \;
