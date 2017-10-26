#!/bin/bash

# NEVIM JAK PROJIT TEST 4 (jednou jsem uploadnul 2x ten samy file a to proslo ale pak se to zaseklo na jinym testu, po oprave se to zasekne znovu..)
print_help()
{
	 	echo "Usage of the script:"
		echo "`basename $0` [-h] [-v] [-z] [-n]"
		echo "-h prints simple manual."
		echo "-v at the end of the file prints result of the search."
		echo "-z archives all files at the end of the file (except symlinks)."
		echo "-n prints order number of a proceeding file."

}

validate_string()
{
	case $LINE in
	"FILE "*)
		return 0
	;;
	esac
	 return 1
}

file_func()
{

  let "file_count++"

  if [[ $ARG_Z == 0 ]]; then
    files+=("${FILE}")
  fi

	RESULT=(`wc -l "$FILE"`);
  if [[ $ARG_N == 0 ]]; then
    # echo "FILE  '"$FILE"' "${RESULT[0]}" '"`head -n 1 ${FILE}`"'"
     echo "FILE ${file_count} '$(realpath "${FILE}")' ${RESULT[0]} '`head -n 1 "${FILE}"`'"
  else
    echo "FILE '$(realpath "${FILE}")' "${RESULT[0]}" '"`head -n 1 "${FILE}"`"'"
  
  fi
	
}

directory()
{
  
  let "dir_count++"
  
  if [[ $ARG_N == 0 ]]; then
    echo "DIR ${dir_count} '$(realpath "${FILE}")'"
  else
      echo "DIR '$(realpath "${FILE}")'"
  fi
  
  # echo "DIR '"$FILE"'"
}

error_stdout()
{
  >&2 echo "ERROR '"$FILE"'";
  let "ERROR=1"
}

link_func(){
  let "link_count++"
  dest=$(readlink "${FILE}")
  if [[ $ARG_N == 0 ]]; then
    echo "LINK ${link_count} '"${FILE}"' '"${dest}"'"
  else
    echo "LINK '"${FILE}"' '"${dest}"'"
  fi
  
}

what_it_is()
{
	if [ -d "${FILE}" ]; then
  	directory
  elif test -L "${FILE}" ; then
    link_func
  elif [ -f "${FILE}" ]; then
    file_func
  else
     error_stdout
  fi
}

archive_files(){
  # if [[ $ERROR == 0 ]]; then
    #statements
  
    tar czf output.tgz "${files[@]}"
    # tar -czf output.tgz "${files[@]}"
    if [ $? -gt 0 ]; then
        exit 2
    fi
  # fi
}



# Start of the program
# Read arguments

ARG_V=1
ARG_N=1
ARG_Z=1
ARG_H=1
ERROR=0
file_count=0
dir_count=0
link_count=0
files=()

while getopts ":hvzn" opt; do
  case $opt in
  v)
    ARG_V=0
    ;;
  n) 
    ARG_N=0
    ;;
  z)
    ARG_Z=0
    ;;
  h)
    print_help
    exit 0
    ;;  
  ?) exit 2
    ;;
  esac
done
shift $(($OPTIND - 1))
	
if [ $ARG_H == 0 ]; then return 2; fi

# Main cycle of program

while read -r LINE
do
    if validate_string; then

        FILE=${LINE:5:${#LINE}}
        what_it_is

    fi

done

if [[ $ARG_V == 0 ]]; then
    echo $file_count
    echo $dir_count
    echo $link_count
fi

if [[ $ARG_Z == 0 ]]; then
   archive_files
fi

if [[ $ERROR == 1 ]]; then
  exit 1
fi
