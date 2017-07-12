#!/bin/bash

words_learnt=$(echo $1 | egrep -o . | sort | tr -d '\n')

build_date=$(date +%F)
wordListFile="wordList_${build_date}.txt"

echo "$USER [Keys: ${words_learnt^^}]" > $wordListFile

egrep -i "^[${words_learnt}]{1,}$" /usr/share/dict/words | sort > words.txt

for word in $(cat words.txt); do
	echo "${word^^}" >> $wordListFile
done

rm words.txt
[[ -d ~/.tuxtype/words ]] || mkdir -p ~/.tuxtype/words
mv $wordListFile ~/.tuxtype/words/
