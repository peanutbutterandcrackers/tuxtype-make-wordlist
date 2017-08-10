#!/bin/bash

export LC_ALL=C # Disables Unicode Support for performance gain
trap "rm $WORD_BUFFER_FILE $WORD_LIST_FILE && exit 1" SIGINT SIGTERM # trap, to handle premature termination

BUILD_DATE=$(date +%F_%T)
SCRIPT_NAME=$(basename $0)
WORD_BUFFER_FILE=$(mktemp /tmp/${SCRIPT_NAME%%.*}-words.$$.XXXXX.txt)
WORD_LIST_FILE=$(mktemp /tmp/${SCRIPT_NAME%%.*}-wordList.$$.XXXXX.txt)

usage () {
	echo "$SCRIPT_NAME: usage: $SCRIPT_NAME ALPHABETIC-KEYS [NON-ALPHABETIC-KEYS]"
	return
}

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

main () {
	echo "$USER [Keys: ${words_learnt^^} ${numeric_keys[@]} ${special_keys[@]}]" > $WORD_LIST_FILE
	
	grep -i "^[${words_learnt}]\{1,\}$" /usr/share/dict/words | sort -i | uniq -i | sort -R | head -n 777 > $WORD_BUFFER_FILE
	
	for word in $(cat $WORD_BUFFER_FILE); do
		if [[ ( ${#numeric_keys[@]} -eq 0 ) && ( ${#special_keys[@]} -eq 0 ) ]]; then
			echo "${word^^}" >> $WORD_LIST_FILE
		else
			case $((($RANDOM % 5) + 1)) in
				1) # The rarest one
				   # Sample: "123 !Potato@" "7 ^meat("
				   # Group command follows:
				   { echo -n $(get_random_number "${numeric_keys[@]}") "";
				     echo -n "${special_keys[$(get_random_index "${special_keys[@]}")]}"; 
					 echo -n "${word^^}";
				     echo "${special_keys[$(get_random_index "${special_keys[@]}")]}";
				   } >> $WORD_LIST_FILE
				   ;;
				2) # The 2nd-to-rarest one
				   # Sample: '12 animal' '123 word'
				   # Group command follows, again:
				   { echo -n $(get_random_number "${numeric_keys[@]}") "";
					 echo "${word^^}";
				   } >> $WORD_LIST_FILE
				   ;;
				3) # The 3rd-to-rarest one
				   # Sample: '12 seashore@' '983 potato!'
				   { echo -n $(get_random_number "${numeric_keys[@]}") "";
					 echo "${word^^}${special_keys[$(get_random_index "${special_keys[@]}")]}";
				   } >> $WORD_LIST_FILE	
				   ;;
				4) # Frequent one(s)
				   if [[ "${special_keys[@]}" =~ ,. ]]; then
				   		# Sample: "animal, potato, cauliflower."
				   		{ echo -n "${word^^}, ";
						  echo "${word_buffer^^}."; } >> $WORD_LIST_FILE
				   else
				   		# Sample: '123 potato', '12 tomato'
				   		{ echo -n $(get_random_number "${numeric_keys[@]}") "";
						  echo "${word^^}"; } >> $WORD_LIST_FILE
				   fi
				   ;;
				5) # Most common one 
				   # Sample: 'animal' 'bird' 'cat'
				   echo "${word^^}" >> $WORD_LIST_FILE
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

	rm $WORD_BUFFER_FILE
	[[ -d ~/.tuxtype/words ]] || mkdir -p ~/.tuxtype/words
	mv $WORD_LIST_FILE ~/.tuxtype/words/wordList_${BUILD_DATE}.txt
}

# Parse Command Line Arguments
if [[ -z "$1" ]]; then
	usage >&2
	exit 1
fi

while [[ -n $1 ]]; do
	case $1 in
		-h | --help )						usage
											exit
											;;
		$(echo $1 | grep [[:alpha:]]) )		alpha_keys+=$(echo $1 | grep --only-matching [[:alpha:]] | tr -d '\n')
											words_learnt=$(echo $alpha_keys | grep -o . | sort -i | uniq -i | tr -d '\n')
											;;&
		$(echo $1 | grep [[:digit:]]) )		numeric_matches+=$(echo $1 | grep --only-matching [[:digit:]] | tr -d '\n')
											declare -a numeric_keys
											readarray -t numeric_keys < <(echo $numeric_matches | tr -c -d [:digit:] | grep -o . | sort | uniq)
											;;&
		$(echo $1 | grep [[:punct:]]) )		special_matches+=$(echo $1 | grep --only-matching [[:punct:]] | tr -d '\n')
											[[ "$special_matches" =~ \" ]] && auto_add=\'
											declare -a special_keys
											readarray -t special_keys < <(echo $special_matches $auto_add | grep -o . | sort | uniq)
											;;
	esac
	shift
done

main
