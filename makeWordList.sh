#!/bin/bash -f

export LC_ALL=C # Disables Unicode Support for performance gain
BUILD_DATE=$(date +%F_%T)
SCRIPT_NAME=$(basename $0)
WORD_BUFFER_FILE=$(mktemp /tmp/${SCRIPT_NAME%%.*}-words.$$.XXXXX.txt)
WORD_LIST_FILE=$(mktemp /tmp/${SCRIPT_NAME%%.*}-wordList.$$.XXXXX.txt)
trap "rm $WORD_BUFFER_FILE $WORD_LIST_FILE; echo; exit 1" SIGINT SIGTERM

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

get_random_elements () {
	# from the given array, return random elements
	# get_random_elements [OPTIONS] ARRAY
	# Available Options:
	# -n, --number=NUMBER
	#     return NUMBER elements from the array
	#     Default is 3
	# -d, --delimiter=DELIM
	#     set delimiter to DELIM
	# -f, --fickle
	#     turn on fickle mode
	#     instead of returning NUMBER elements from the array, return any
	#     no. of elements from 1 to NUMBER, at max.
	declare -i number=3
	declare delimiter=''
	declare -a array

	while [[ -n $1 ]]; do
		case $1 in
			-n | --number )		shift
			              		number=$1
						;;
			-d | --delimiter )	shift
			                 	delimiter=$1
						;;
			-f | --fickle )		local fickle=true
			              		;;
			* )			array+=($1)
						;;
		esac
		shift
	done

	local jumbled=($(for i in "${array[@]}"; do echo $i; done | sort -R))
	if [[ -n $fickle ]]; then
		local max_digits=$number
		number=$(($RANDOM%$max_digits))
	fi
	echo "${jumbled[@]:0:$number}" | sed "s/ /$delimiter/g"

	return
}

is_inappropriate_word () {
	# An attempt to prevent inappropriate words from slipping in to the final worlist
	# because some were slipping in, at times
	# takes a word as an argument
	declare -a inapprop_rot1 # ROT1 encoded array of inappropriate words
	inapprop_rot1=( gvdl tiju dvou ) # Curse Words
	inapprop_rot1+=( btt cppc csfbtu qfojt wbhjob ) # Body Parts
	inapprop_rot1+=( epvdif ejdl gbh tmvu cjudi ) # Insults
	inapprop_rot1+=( tfy ) # Verbs
	grep -E --silent --ignore-case "$(echo ${inapprop_rot1[*]} | tr ' ' '|')" <<< "$(echo $1 | tr a-z b-za)"
	return
}

parse_args () {
	if [[ -z "$1" ]]; then
		usage >&2
		exit 1
	fi

	while [[ -n $1 ]]; do
		case $1 in
			-h | --help )				usage
								exit
								;;
			-i | --interactive )			interactive_mode=1
								break
								;;
			-u | --user-name )			shift
								user_name=$1
								;;
			--no-filter )				filter='off'
								;;
			--max-words )				shift
								max_words=$1
								;;
			$(echo $1 | grep [[:alpha:]]) )		alpha_keys+=$(echo $1 | grep --only-matching [[:alpha:]] | tr -d '\n')
								letters_learnt=$(echo $alpha_keys | grep -o . | sort --ignore-case | uniq -i | tr -d '\n')
								;;&
			$(echo $1 | grep [[:digit:]]) )		numeric_matches+=$(echo $1 | grep --only-matching [[:digit:]] | tr -d '\n')
								declare -ga numeric_keys
								readarray -t numeric_keys < <(echo $numeric_matches | tr -c -d [:digit:] | grep -o . | sort | uniq)
								;;&
			$(echo $1 | grep [[:punct:]]) )		special_matches+=$(echo $1 | grep --only-matching [[:punct:]] | tr -d '\n')
								[[ "$special_matches" =~ \" ]] && auto_add=\'
								declare -ga special_keys
								readarray -t special_keys < <(echo $special_matches $auto_add | grep -o . | sort | uniq)
								;;
		esac
		shift
	done
	return
}

interactive () {
	while [[ -z $alphas ]]; do
		read -p "Enter the alphabetic keys (letters) that you have learned [REQUIRED] > " alphas
		alphas=$(echo $alphas | tr -d -c [:alpha:])
	done
	letters_learnt=$(echo $alphas | grep -o . | sort --ignore-case | uniq -i | tr -d '\n')
	echo $letters_learnt

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
	main
	echo "Generation Complete."
}

main () {
	echo "${user_name:-$USER} [Keys: ${letters_learnt^^} ${numeric_keys[@]} ${special_keys[@]}]" > $WORD_LIST_FILE

	grep -Ei "^[${letters_learnt}]{1,}$" /usr/share/dict/words | sort --ignore-case | uniq --ignore-case | sort -R \
		| head -n ${max_words:-175} > $WORD_BUFFER_FILE
	grep -Ei "^[${letters_learnt}]{1,}$" <<< "BARSHA" >> $WORD_BUFFER_FILE # The pal I originally wrote this script for

	[[ "${#special_keys[@]}" -eq 0 ]] && special_keys+=('')

	for word in $(cat $WORD_BUFFER_FILE | sort -R); do
		[[ $filter != 'off' ]] && is_inappropriate_word $word && continue

		str_arr=()
		str_arr+=$(get_random_elements -n 3 -f "${numeric_keys[@]}")
		str_arr+=$(get_random_elements -n 2 -d ' ' -f "${special_keys[@]}")
		str_arr+=(${word^^})
		[[ $(($RANDOM%7)) == 0 ]] && str_arr+=(${word_buffer^^})

		jumbled_str_arr=($(for i in "${str_arr[@]}"; do echo $i; done | sort -R ))
		echo "${jumbled_str_arr[@]}" | sed -r 's_([[:punct:]]) ([^[:punct:]])_\1\2_' | sed -r 's_([^[:punct:]]) ([[:punct:]])_\1\2_' >> $WORD_LIST_FILE

		[[ $(($RANDOM%2)) == 0 ]] && word_buffer=$word
	done

	rm $WORD_BUFFER_FILE
	[[ -d ~/.tuxtype/words ]] || mkdir -p ~/.tuxtype/words
	mv $WORD_LIST_FILE ~/.tuxtype/words/wordList_${BUILD_DATE}.txt
}

parse_args "$@"
[[ $interactive_mode == 1 ]] && interactive && exit
main
