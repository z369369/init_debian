#!/bin/bash
#bash-linux scan folder and create .desktop files 
# v01 -201216a

#ORIGINAL path is the actual path I store my appimage files. For more easy handling I have created a link to /appimages
chmod u+x /home/lwh/Downloads/zip/*.AppImage

ORIGINALPATH="/home/lwh/Downloads/zip"
#ln -s "$ORIGINALPATH" /appimages

yourfilenames=`ls $ORIGINALPATH/*.?pp?mage`

#for FILE in /appimages/*.?pp?mage; 
for FILE in $yourfilenames;
do 
LAST_FOLDER=$(basename $(dirname $FILE))
DESKTOP_FILENAME=$(basename "${FILE%}")".desktop"
if [ ! -e "/home/lwh/.local/share/applications/App_$DESKTOP_FILENAME" ]
then
cat > "/home/lwh/.local/share/applications/App_"$DESKTOP_FILENAME << EOF3
[Desktop Entry]
Version=1.0
Name=$DESKTOP_FILENAME
Exec=$FILE
Terminal=false
#X-MultipleArgs=false
Type=Application
#Icon=/usr/share/pixmaps/chromium.xpm
Categories=X-AppImages;
StartupNotify=false
EOF3
fi
chmod u+x "/home/lwh/.local/share/applications/App_"$DESKTOP_FILENAME
# Comment the next line if you don't want to make Desktop Entries
done
