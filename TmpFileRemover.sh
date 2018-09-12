#!/bin/bash/

FILE_LIST=()
FILE_ID=()

ECHO_RED='\e[0;31m'
ECHO_GREEN='\e[0;32m'
ECHO_BLUE='\e[0;34m'
ECHO_BLACK='\e[30mBlack'
ECHO_DEFAULT_COLOR='\e[39m'

ECHO_BOLD='\e[1m'
ECHO_RESET_BOLD='\e[21m'

ECHO_UNDERLINED='\e[4m'
ECHO_RESET_UNDERLINED='\e[24m'

ECHO_RESET_ALL='\e[0m'


REMOVE_LIST_FILE="TmpFileRemoveList.txt"        #The file that contains the list of files to remove

TRASH_PATH="$HOME/Desktop/TrashTest"	#A temporary place to save the removed files



is_int ()
{
	string="$1"
	if [[ "$string"  =~ ^[[:digit:]]+$  ]]
	then
		return 0
	else
		return 1
	fi
}

print_line ()
{
	echo -e "\n$1\n"
}

print_error ()
{
	print_line "${ECHO_RED}${1}${ECHO_DEFAULT_COLOR}"
}

clear_FILE_LIST ()
{
	unset FILE_LIST
	FILE_LIST=()

	echo -n "" > "$REMOVE_LIST_FILE"
}

load_FILE_LIST ()
{
	if [[ ! -a "$REMOVE_LIST_FILE" ]]
	then
		print_error "Error while reading $PWD/$REMOVE_LIST_FILE. Maybe the file doesn't exist"
		return 1
	fi

	clear_FILE_LIST

	IFS=$'\n'
	read -p "$ " -d '' -r -a FILE_LIST < "$REMOVE_LIST_FILE"

	return 0
}

save_FILE_LIST ()
{
	echo -n "" > "$REMOVE_LIST_FILE"
	for elem in ${FILE_LIST[@]}
	do
		echo "$elem" >> "$REMOVE_LIST_FILE"
	done

	print_line "List saved"
}

add_element_FILE_LIST ()
{
	print_line "Write the path of the file to add"

	read -p "$ " -r fileName

	if [[ ! -a "$fileName" ]]
	then
		print_error "The specified file does not exist"
		return 1
	fi

	FILE_LIST+=($fileName)
	print_line "File added"

	return 0
}

remove_element_FILE_LIST ()
{
	declare -i index=0
	print_line "Insert the ID of the file"

	read -p "$ " userInput

	if ! is_int "$userInput"
	then
		print_error "Error while reading the number"
		return 1
	fi

	index="$userInput"

	if [[ -z "${FILE_LIST[$index]}"  ]]
	then
		print_error "There is no file with that ID"
		return 1
	fi

	unset FILE_LIST[$index]

	print_line "The file has been removed succesfully"
	
	return 0
}

display_LIST ()
{
	declare -i index=0

	FILE_ID=(${!FILE_LIST[@]})
	
	if [[ "${#FILE_LIST[@]}" -eq 0  ]]
	then
		print_line "The list is empty"
		return 1
	fi

	for elem in ${FILE_LIST[@]}
	do
		echo "${FILE_ID[$index]}] $elem"
		((index++))
	done

	return 0
}

empty_LIST ()
{
	print_line "${ECHO_RED}${ECHO_BOLD}ARE YOU SURE YOU WANT TO DELETE THE ENTIRE LIST?${ECHO_RESET_ALL} [Y/n]"

	read -p "$ " userChoice

	if [[ "$userChoice" != "Y"  ]]
	then
		return 1	
	fi

	clear_FILE_LIST

	print_line "The list has been cleared"
	
	return 0
}

remove_listed_files ()
{
	SUCC_FILES=0

	print_line "${ECHO_RED}${ECHO_BOLD}ARE YOU SURE YOU WANT TO REMOVE ALL THE FILES LISTED IN ${REMOVE_LIST_FILE}?${ECHO_RESET_ALL} [Y/n]"

	read -p "$ " userChoice

	if [[ "$userChoice" != "Y"  ]]
	then
		return 1
	fi

	for file in ${FILE_LIST[@]}
	do
		if mv "$file" "$TRASH_PATH" &> /dev/null
		then
			((SUCC_FILES++))
		fi
	done

	print_line "$SUCC_FILES files have been removed succesfully on ${#FILE_LIST[@]} files"

	clear_FILE_LIST

	print_line "The list has been cleared"
}

<<comment
clear_all_dirs ()
{
	print_line "${ECHO_RED}${ECHO_BOLD}ARE YOU SURE YOU WANT TO CLEAR ALL THE DIRECTORIES? (the search for target files will begin from the current directory and go on for a specified amount of sub-levels in the directory tree; you can change this setting passing as the first argument an integer value to this script)${ECHO_RESET_ALL} [Y/n]"

	read -p "$ " userChoice

	if [[ "$userChoice" != "Y" ]]
	then
		return 1
	fi

	return 0
}

change_current_dir ()
{
	print_line "Write the path"

	read -p "$ " -r newDir

	if ! cd "$newDir"
	then
		return 1
	fi

	if ! load_FILE_LIST
	then
		return 1
	fi

	return 0
}
comment




if [[ -a "$1" ]]
then
	REMOVE_LIST_FILE="$1"
fi

if [[ -d "$2" ]]
then
        TRASH_PATH="$1"
fi


quit=0

load_FILE_LIST

while [[ "$quit" -eq 0 ]]
do
	echo -e "\nChoose an option\n\n${ECHO_GREEN}1)${ECHO_DEFAULT_COLOR}Add a file in the list\n${ECHO_GREEN}2)${ECHO_DEFAULT_COLOR}Remove a file from the list\n${ECHO_GREEN}3)${ECHO_DEFAULT_COLOR}Display the list\n${ECHO_GREEN}4)${ECHO_DEFAULT_COLOR}Empty the list\n${ECHO_GREEN}5)${ECHO_DEFAULT_COLOR}Remove all the listed files\n${ECHO_GREEN}6)${ECHO_DEFAULT_COLOR}Save the list\n${ECHO_GREEN}7)${ECHO_DEFAULT_COLOR}Quit"
	read -p "$ " opt
	case $opt in
		*)
			echo "----------------------------------------------------------------------"
			;;&
		"1")
			add_element_FILE_LIST
			;;

		"2")
			remove_element_FILE_LIST
			;;
		"3")
			display_LIST
			;;
		"4")
			empty_LIST
			;;
		"5")
			remove_listed_files
			;;
		"6")
			save_FILE_LIST
			;;
		"7")
			break
			;;
		*)
			print_line "Invalid option"
			;;
	esac

	echo "----------------------------------------------------------------------"

done

exit

