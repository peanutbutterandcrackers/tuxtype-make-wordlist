#!/bin/bash

words_learnt=$(echo $1 | egrep -o . | sort | uniq | tr -d '\n')
non_alpha_keys_learnt=$(echo $2)

declare -a numeric_keys
readarray -t numeric_keys < <(echo $2 | tr -c -d [:digit:] | egrep -o . | sort | uniq)
[[ "$2" =~ \" ]] && auto_add=\'
declare -a special_keys
readarray -t special_keys < <(echo $2 $auto_add | tr -d [:digit:][:space:] | egrep -o . | sort | uniq)

build_date=$(date +%F_%T)
words_buffer_file='/tmp/words.txt'
wordListFile="/tmp/wordList_${build_date}.txt"

get_random_number () {
	arr=("$@")
	maxdigits=$((RANDOM%3+1))
	jumbled=($(for i in "${arr[@]}"; do
				echo $i
			done | sort -R | sort -R))
	echo "${jumbled[@]:0:$maxdigits}" | tr -d ' '
	return
	}

get_random_index () {
	arr=("$@")
	arr_len=${#arr[@]}
	index=$((RANDOM%$arr_len))
	echo $index
	return
	}

echo "$USER [Keys: ${words_learnt^^} ${numeric_keys[@]} ${special_keys[@]}]" > $wordListFile

egrep -i "^[${words_learnt}]{1,}$" /usr/share/dict/words | sort -R | uniq > $words_buffer_file
for word in $(cat $words_buffer_file); do
	if [ ${#non_alpha_keys_learnt} -eq 0 ]; then
		echo "${word^^}" >> $wordListFile
	else
		case $((($RANDOM % 5) + 1)) in
			1) # The rarest one
			   # Sample: "123 !Potato@" "7 ^meat("
			   # Group command follows:
			   { echo -n $(get_random_number "${numeric_keys[@]}") "";
			     echo -n "${special_keys[$(get_random_index "${special_keys[@]}")]}"; 
				 echo -n "${word^^}";
			     echo "${special_keys[$(get_random_index "${special_keys[@]}")]}";
			   } >> $wordListFile
			   ;;
			2) # The 2nd-to-rarest one
			   # Sample: '12 animal' '123 word'
			   # Group command follows, again:
			   { echo -n $(get_random_number "${numeric_keys[@]}") "";
				 echo "${word^^}";
			   } >> $wordListFile
			   ;;
			3) # The 3rd-to-rarest one
			   # Sample: '12 seashore@' '983 potato!'
			   { echo -n $(get_random_number "${numeric_keys[@]}") "";
				 echo "${word^^}${special_keys[$(get_random_index "${special_keys[@]}")]}";
			   } >> $wordListFile	
			   ;;
			4) # Frequent one(s)
			   if [[ "${special_keys[@]}" =~ ,. ]]; then
			   		# Sample: "animal, potato, cauliflower."
			   		{ echo -n "${word^^}, ";
					  echo "${word_buffer^^}."; } >> $wordListFile
			   else
			   		# Sample: '123 potato', '12 tomato'
			   		{ echo -n $(get_random_number "${numeric_keys[@]}") "";
					  echo "${word^^}"; } >> $wordListFile
			   fi
			   ;;
			5) # Most common one 
			   # Sample: 'animal' 'bird' 'cat'
			   echo "${word^^}" >> $wordListFile
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
	word_buffer=$word # preserves 'another word' for case 4a
done

rm $words_buffer_file
[[ -d ~/.tuxtype/words ]] || mkdir -p ~/.tuxtype/words
mv $wordListFile ~/.tuxtype/words/
