#!/bin/bash

words_learnt=$(echo $1 | egrep -o . | sort | tr -d '\n')
non_alpha_keys_learnt=$(echo $2)

declare -a numeric_keys
numeric_keys=($(echo $2 | tr -c -d [:digit:] | egrep -o . | sort | tr '\n' ' '))
declare -a punctuation keys
special_keys=($(echo $2 | tr -d [:digit:] | egrep -o . | sort | tr '\n' ' '))

build_date=$(date +%F_%T)
wordListFile="wordList_${build_date}.txt"

echo "$USER [Keys: ${words_learnt^^}]" > $wordListFile

egrep -i "^[${words_learnt}]{1,}$" /usr/share/dict/words | sort -R | uniq > words.txt
for word in $(cat words.txt); do
	if [ ${#non_alpha_keys_learnt} -eq 0 ]; then
		echo "${word^^}" >> $wordListFile
	else
		case $RANDOM in
			1) #code
			   ;;
			2) #code
			   ;;
			3) #code
			   ;;
			4) #code
			   ;;
			*) #code # for the most-common one
			   ;;
		esac
		# prefix: number - single digit <---> postfix: punctuation/special mark - one at a time
		# Have 4 switches here: 1. just word 2. num-word 3. word-special_mark 4. num-word-special_mark
		# To select the number: get random index from the numeric_keys array: $RANDOM%${#numeric_keys[@]}  
		# To select the special_key: $RANDOM%${#special_keys[@]}
		# Have another 5th switch to make up sentence-like thingies. num-word-char-space-word-period
		# The 5th switch should be the rarest
		# 4th switch, 3rd and 2nd should go hand in hand and should be the most common
		# 1 should be rare too
	fi
done

rm words.txt
[[ -d ~/.tuxtype/words ]] || mkdir -p ~/.tuxtype/words
mv $wordListFile ~/.tuxtype/words/
