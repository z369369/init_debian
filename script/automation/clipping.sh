#!/bin/bash
cd ~/phone/000_Personal/Clipping/

find . -maxdepth 1 -type f -exec grep -q 'tags: Compare' {} \; -exec mv -i {} ../Compare \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Contact' {} \; -exec mv -i {} ../Contact \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Daily' {} \; -exec mv -i {} ../Daily \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Food' {} \; -exec mv -i {} ../Food \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Game' {} \; -exec mv -i {} ../Game \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Hardware' {} \; -exec mv -i {} ../Hardware \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Health' {} \; -exec mv -i {} ../Health \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Idea' {} \; -exec mv -i {} ../Idea \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Investment' {} \; -exec mv -i {} ../Investment \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Language' {} \; -exec mv -i {} ../Language \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Living' {} \; -exec mv -i {} ../Living \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Media' {} \; -exec mv -i {} ../Media \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Medical' {} \; -exec mv -i {} ../Medical \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Military' {} \; -exec mv -i {} ../Military \;
find . -maxdepth 1 -type f -exec grep -q 'tags: PastTime' {} \; -exec mv -i {} ../PastTime \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Privacy' {} \; -exec mv -i {} ../Privacy \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Produce' {} \; -exec mv -i {} ../Produce \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Psycology' {} \; -exec mv -i {} ../Psycology \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Shopping' {} \; -exec mv -i {} ../Shopping \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Software' {} \; -exec mv -i {} ../Software \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Template' {} \; -exec mv -i {} ../Template \;
find . -maxdepth 1 -type f -exec grep -q 'tags: Trip' {} \; -exec mv -i {} ../Trip \;

