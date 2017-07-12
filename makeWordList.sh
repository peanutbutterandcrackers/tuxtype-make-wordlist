#!/bin/bash

words_learnt=$1

build_date=$(date +%F)
wordListFile="wordList_${build_date}.txt"

echo "$USER" > $wordListFile

egrep -i "^[${words_learnt}asdefjkil]{1,}$" /usr/share/dict/words > words.txt

for word in $(cat words.txt); do
	echo "${word^^}" >> $wordListFile
done

rm words.txt
rm ~/.tuxtype/words/wordList_*.txt
[[ -d ~/.tuxtype/words ]] || mkdir -p ~/.tuxtype/words
cp $wordListFile ~/.tuxtype/words/
