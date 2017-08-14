#!/bin/bash

export LC_ALL=C # Disables Unicode Support for performance gain
trap "rm $WORD_BUFFER_FILE $WORD_LIST_FILE && exit 1" SIGINT SIGTERM

BUILD_DATE=$(date +%F_%T)
SCRIPT_NAME=$(basename $0)
WORD_BUFFER_FILE=$(mktemp /tmp/${SCRIPT_NAME%%.*}-words.$$.XXXXX.txt)
WORD_LIST_FILE=$(mktemp /tmp/${SCRIPT_NAME%%.*}-wordList.$$.XXXXX.txt)

usage () {
	echo "$SCRIPT_NAME: usage: $SCRIPT_NAME [OPTIONS] ALPHABETIC-KEYS [NON-ALPHABETIC-KEYS]"
	echo
	echo "Create custom Tuxtype levels out of the keys that you have learned"
	echo
	cat <<- _EOF_
		Available Options:
		-h, --help				->Display this help and exit
		-i, --interactive			->Interactive Mode. Specify at the end to use with other options.
		-u, --user-name USER_NAME_STRING	->Set the username to be USER_NAME_STRING
		                                          This will be displayed in Tuxtype as the name of the lesson.
		--no-filter				->Disables word-filter that is activated by default. Disabling this
		                                          does give a bit of reduction in execution time; however, inappropriate
		                                          words might slip in to the final word list. Use wisely.
		--max-words INTEGER			->Sets the maximum word generation limit for the script. Default is 175. Higher values
		                                          increase the execution time. Decrease the value for faster generation on slower machines.

		Make Sure the NON-ALPHABETIC-KEYS are enclosed with single quotes, like so: '$@#-+/'

		There's No Place Like Home: https://github.com/peanutbutterandcrackers/tuxtype-make-wordlist
	_EOF_
	return
}

get_random_number () {
	local arr=("$@")
	local maxdigits=$((RANDOM%3+1))
	local jumbled=($(for i in "${arr[@]}"; do
				echo $i
			done | sort -R))
	echo "${jumbled[@]:0:$maxdigits}" | tr -d [:space:]
	return
	}

get_random_index () {
	local arr=("$@")
	local arr_len=${#arr[@]}
	local index=$((RANDOM%$arr_len))
	echo $index
	return
	}

is_inappropriate_word () {
	# an attempt to prevent inappropriate words from slipping in to the final worlist
	# because some were slipping in, at times
	declare -a inapprop_rot1 # ROT1 encoded array of inappropriate words
	inapprop_rot1=( gvdl tiju dvou ) # Curse Words
	inapprop_rot1+=( btt cppc csfbtu qfojt wbhjob ) # Body Parts
	inapprop_rot1+=( epvdif ejdl ) # Insults
	inapprop_rot1+=( tfy ) # Verbs
	grep -E --silent --ignore-case "$(echo ${inapprop_rot1[*]} | tr ' ' '|')" <<< "$(echo $1 | tr a-z b-za)"
	return
}

interactive () {
	while [[ -z $alphas ]]; do
		read -p "Enter the alphabetic keys (letters) that you have learned [REQUIRED] > " alphas
		alphas=$(echo $alphas | tr -d -c [:alpha:])
	done
	words_learnt=$(echo $alphas | grep -o . | sort --ignore-case | uniq -i | tr -d '\n')
	echo $words_learnt

	echo -n "Enter the numeric keys that you have learned, if any > "
	read numerics
	numerics=$(echo $numerics | tr -d -c [:digit:])
	declare -g -a numeric_keys
	readarray -t numeric_keys < <(echo $numerics | tr -c -d [:digit:] | grep -o . | sort | uniq)
	echo "${numeric_keys[@]}"

	echo -n "Enter the special keys (punctuations) that you have learned, if any > "
	read -r specials
	specials=$(echo $specials | tr -d -c [:punct:])
	declare -g -a special_keys
	readarray -t special_keys < <(echo $specials | grep -o . | sort | uniq)
	echo "${special_keys[@]}"

	if [[ -z $user_name ]]; then
		echo -n "Enter your name [OPTIONAL] > "
		read user_name
		[[ -n $user_name ]] && echo "$user_name"
	fi

	echo "Generating word list. Please wait."
}

main () {
	echo "${user_name:-$USER} [Keys: ${words_learnt^^} ${numeric_keys[@]} ${special_keys[@]}]" > $WORD_LIST_FILE

	grep -i "^[${words_learnt}]\{1,\}$" /usr/share/dict/words | sort --ignore-case | uniq --ignore-case | sort -R | head -n ${max_words:-175} > $WORD_BUFFER_FILE

	for word in $(cat $WORD_BUFFER_FILE); do
		if [[ -z $filter ]]; then
			is_inappropriate_word $word && continue
		fi

		if [[ ( ${#numeric_keys[@]} -eq 0 ) && ( ${#special_keys[@]} -eq 0 ) ]]; then
			echo "${word^^}" >> $WORD_LIST_FILE
		else
			case $((($RANDOM % 5) + 1)) in
				1) # Sample: "123 !Potato@" "7 ^meat("
				   # Group command follows:
				   { echo -n $(get_random_number "${numeric_keys[@]}") "";
				     echo -n "${special_keys[$(get_random_index "${special_keys[@]}")]}";
					 echo -n "${word^^}";
				     echo "${special_keys[$(get_random_index "${special_keys[@]}")]}";
				   } >> $WORD_LIST_FILE
				   ;;
				2) # Sample: '12 animal' '123 word'
				   { echo -n $(get_random_number "${numeric_keys[@]}") "";
					 echo "${word^^}";
				   } >> $WORD_LIST_FILE
				   ;;
				3) # Sample: '12 seashore@' '983 potato!'
				   { echo -n $(get_random_number "${numeric_keys[@]}") "";
					 echo "${word^^}${special_keys[$(get_random_index "${special_keys[@]}")]}";
				   } >> $WORD_LIST_FILE
				   ;;
				4) if [[ "${special_keys[@]}" =~ ,. ]]; then
				   		# Sample: "animal, potato, cauliflower."
				   		{ echo -n "${word^^}, ";
						  echo "${word_buffer^^}."; } >> $WORD_LIST_FILE
				   else
				   		# Sample: '123 potato', '12 tomato'
				   		{ echo -n $(get_random_number "${numeric_keys[@]}") "";
						  echo "${word^^}"; } >> $WORD_LIST_FILE
				   fi
				   ;;
				5) # Sample: 'animal' 'bird' 'cat'
				   echo "${word^^}" >> $WORD_LIST_FILE
				   ;;
			esac
			word_buffer=$word # preserves 'another word' for case 4a
		fi
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
		-i | --interactive )				interact=1
											break
											;;
		-u | --user-name )					shift
											user_name=$1
											;;
		--no-filter )						filter='off'
											;;
		--max-words )						shift
											max_words=$1
											;;
		$(echo $1 | grep [[:alpha:]]) )		alpha_keys+=$(echo $1 | grep --only-matching [[:alpha:]] | tr -d '\n')
											words_learnt=$(echo $alpha_keys | grep -o . | sort --ignore-case | uniq -i | tr -d '\n')
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

[[ $interact == 1 ]] && interactive

main

[[ $interact == 1 ]] && echo "Generation complete."
