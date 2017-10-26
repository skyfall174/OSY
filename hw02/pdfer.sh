#!/bin/bash
# Author: Klochkov Mikhail
# Date of creation: 1508245239 (Unix timestamp) 

print_help()
{
	 	echo '
 /$$$$$$$$                    /$$                     /$$                           /$$                                                                                                                    
|__  $$__/                   | $$                    | $$                          | $$                                                                                                                    
   | $$  /$$$$$$  /$$$$$$$  /$$$$$$    /$$$$$$       | $$$$$$$   /$$$$$$   /$$$$$$$| $$$$$$$              /$$  /$$$$$$         /$$$$$$  /$$  /$$  /$$  /$$$$$$   /$$$$$$$  /$$$$$$  /$$$$$$/$$$$   /$$$$$$ 
   | $$ /$$__  $$| $$__  $$|_  $$_/   /$$__  $$      | $$__  $$ |____  $$ /$$_____/| $$__  $$            |__/ /$$__  $$       |____  $$| $$ | $$ | $$ /$$__  $$ /$$_____/ /$$__  $$| $$_  $$_  $$ /$$__  $$
   | $$| $$$$$$$$| $$  \ $$  | $$    | $$  \ $$      | $$  \ $$  /$$$$$$$|  $$$$$$ | $$  \ $$             /$$| $$$$$$$$        /$$$$$$$| $$ | $$ | $$| $$$$$$$$|  $$$$$$ | $$  \ $$| $$ \ $$ \ $$| $$$$$$$$
   | $$| $$_____/| $$  | $$  | $$ /$$| $$  | $$      | $$  | $$ /$$__  $$ \____  $$| $$  | $$            | $$| $$_____/       /$$__  $$| $$ | $$ | $$| $$_____/ \____  $$| $$  | $$| $$ | $$ | $$| $$_____/
   | $$|  $$$$$$$| $$  | $$  |  $$$$/|  $$$$$$/      | $$$$$$$/|  $$$$$$$ /$$$$$$$/| $$  | $$            | $$|  $$$$$$$      |  $$$$$$$|  $$$$$/$$$$/|  $$$$$$$ /$$$$$$$/|  $$$$$$/| $$ | $$ | $$|  $$$$$$$
   |__/ \_______/|__/  |__/   \___/   \______/       |_______/  \_______/|_______/ |__/  |__/            | $$ \_______/       \_______/ \_____/\___/  \_______/|_______/  \______/ |__/ |__/ |__/ \_______/
                                                                                                    /$$  | $$                                                                                              
                                                                                                   |  $$$$$$/                                                                                              
                                                                                                    \______/                                                                                               
'
}


check_i(){
	if  [ ${ARG_I} -eq 0 ] || [ ${ARG_U} -eq 0 ] ; then
		exit 2
	fi
		
	ARG_I=0
	
}

check_u(){
	if [ ${ARG_I} -eq 0 ] || [ ${ARG_U} -eq 0 ] ; then
		exit 2
	fi
		ARG_U=0
}


# _________ START OF PROGRAM _________

# Variables
ARG_I=1
ARG_U=1
URL=''
RESULT=''

# Check if have any flags
if [[ $# == 0 ]]; then
	# print_help
	exit 1
fi


while getopts ":hiu:" opt; do
  case $opt in
  h) print_help
	exit 0
    ;;
  i) check_i
     
    ;;
  u) check_u
     URL="${OPTARG}"
     
    ;;

  ?)
	# echo "args is not accessible" >&2
   exit 1
    ;;
  esac
done
shift $(($OPTIND - 1))


if [ ${ARG_I} -eq 0 ]; then
	RESULT="`cat`" 
fi

if [ ${ARG_U} -eq 0 ]; then
	# compgen -c | grep 'wget'>&2
	# protoze prikaz predtim hazel prazdny string .....
	exit 1
	RESULT="`wget -qO- "${URL}"`"
fi

# echo "${RESULT}"| tr '\n' ' '
# echo "${HTML}" | grep -nio "<a[[:space:]]*[a-z_\"=]*[[:space:]]*href[[:space:]]*=[[:space:]]*\"[^\"]\+\.pdf\">" | grep -nio "href[[:space:]]*=[[:space:]]*\"[^\"]\+\.pdf\">" | awk 'BEGIN{FS="\""}{print $2}'
# echo "${RESULT}"|  tr '\n' ' ' | grep -io "<a[[:space:]]*href=\"[^\"]\+\.pdf\">" | awk 'BEGIN{FS="\""}{print $2}'

echo 	"${RESULT}"| 
		tr '\n' ' ' | 
		tr -d '\r\n'|
		tr -d '\t'| 
		grep -io "<[[:space:]]*a[^>]*[[:space:]]\+href[[:space:]]*=[[:space:]]*\"[^\"]\+\.pdf\"" |
		grep -io "href[[:space:]]*=[[:space:]]*\"[^\"]\+\.pdf\""  |
		awk 'BEGIN{FS="\""}{print $2}'

if [ ${ARG_U} -eq 0 ]; then
	# compgen -c | grep 'wget'>&2
	exit 1
fi
>&2 echo "${RESULT}"|  tr -d '\n' | tr -d '\r\n' | tr -d '\t'| grep -io "<a[^>]*href[[:space:]]*=[[:space:]]*\"[^\"]\+\.pdf\"" | grep -io "href[[:space:]]*=[[:space:]]*\"[^\"]\+\.pdf\""  | awk 'BEGIN{FS="\""}{print $2}'
# '<a +href *= *".*" *'
# _________ END OF CYCLE _____________

# URL="cw.fel.cvut.cz/wiki/_media/courses/b4b35osy/cviceni/cviceni03_test_html.txt"
# DATA=""

# # echo URL
# load_from_url
# echo "${DATA}"

