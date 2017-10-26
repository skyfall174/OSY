#!/usr/bin/env bash


is_FILE_read(){
    if [[ "${LINE}" == FILE* ]]; then
        return 0
    else
        return 1
    fi
}

examine_data(){
    if [ -d "${FILE}" ]; then
        directory
    elif [ -L "${FILE}" ]; then
        link
    elif [ -f "${FILE}" ]; then
        file
    else
        error_stdout
    fi
}

file(){
    valid_files+=("${FILE}")
    let "file_count++"


    line_count=$(wc -l < "${FILE}")
    first_line=$(head -n 1 "${FILE}")

    if [ ${COUNTING} ]; then
        echo "FILE ${file_count} '$(realpath "${FILE}")' ${line_count} '${first_line}'"
    else
        echo "FILE '$(realpath "${FILE}")' ${line_count} '${first_line}'"
    fi
}

link(){
    let "link_count++"
    dest=$(readlink "${FILE}")

    if [ ${COUNTING} ]; then
        echo "LINK ${link_count} '"${FILE}"' '"${dest}"'"
    else
        echo "LINK '"${FILE}"' '"${dest}"'"
    fi
}

directory(){
    let "dir_count++"

    if [ ${COUNTING} ]; then
        echo "DIR ${dir_count} '$(realpath "${FILE}")'"
    else
        echo "DIR '$(realpath "${FILE}")'"
    fi
}

error_stdout(){
    echo "ERROR '"${FILE}"'"
    ERROR=0

}

write_manual(){
    echo "Usage of the script:"
    echo "`basename $0` [-h] [-v] [-z] [-n]"
    echo "-h prints simple manual."
    echo "-v at the end of the file prints result of the search."
    echo "-z archives all files at the end of the file (except symlinks)."
    echo "-n prints order number of a proceeding file."
}

write_summary(){
    echo ${file_count}
    echo ${dir_count}
    echo ${link_count}
}

archive_files(){
    tar -czf output.tgz ${valid_files[@]}
    if [ $? -gt 0 ]; then
        echo "Error while creating archive. Exiting."
        exit 2
    fi
}

finish_script(){
    if [ ${ARCHIVE} ]; then
        archive_files
    fi
    if [ ${VERBOSE} ]; then
        write_summary
    fi
}

# ------------------- Processing arguments --------------------------------------
while getopts ":hvzn" opt; do
  case $opt in
  h) write_manual
    ;;
  v) VERBOSE=0
    ;;
  z) ARCHIVE=0
    ;;
  n) COUNTING=0
    ;;
  ?) exit 2
    ;;
  esac
done
shift $(($OPTIND - 1))
# -------------------------------------------------------------------------------

dir_count=0
file_count=0
link_count=0
valid_files=() # Array with paths for archiving with argument -z

while read -r LINE
do
    if is_FILE_read; then

        FILE=${LINE:5:${#LINE}}
        examine_data

    fi

done

finish_script
if [ ${ERROR} ]; then
    exit 1
fi

#DOTAZY - při chybě se skript dojede a vrátí 2 nebo rovnou vrátí 2?
#format vypisu z prepinace -v
#Musí za FILE při vstupu být mezera?