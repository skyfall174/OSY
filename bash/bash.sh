#!/bin/bash

while getopts ":hvzn" opt; do
  case $opt in
      h) HELP=true
        ;;
      v) COUNT=true
        ;;
      z) ZIP=true
        ;;
      n) FORMAT=true
        ;;
      ?) echo "Spatny argument"
         exit 2
        ;;
  esac
done
shift $(($OPTIND - 1))

FILECOUNT=0
DIRCOUNT=0
LINKCOUNT=0

while IFS='' read -r line || [[ -n "$line" ]]; do

    if [[ $line == "FILE "* ]]; then

        IFS=' ' read -r -a array <<< "$line"
        path="${array[1]}"

        if [ -e $path ];
        then
            if [ -L $path ];
            then

                ((LINKCOUNT++))
                if [[ "$FORMAT" = true ]];
                then
                    echo "LINK $LINKCOUNT '$path'" "'$(pwd)/$(readlink "$path")'"
                else
                    echo "LINK '$path'" "'$(pwd)/$(readlink "$path")'"
                fi

            elif [ -d $path ];
            then

                ((DIRCOUNT++))
                if [[ "$FORMAT" = true ]];
                then
                    echo "DIR $DIRCOUNT '$path'"
                else
                    echo "DIR '$path'"
                fi

            elif [ -f $path ];
            then

                ((FILECOUNT++))
                LINECOUNT=$(wc -l < $path)

                if [[ "$FORMAT" = true ]];
                then
                    echo "FILE $FILECOUNT '$path'" $(($LINECOUNT + 1)) "'$(head -n 1 $path)'"
                else
                    echo "FILE '$path'" $(($LINECOUNT + 1)) "'$(head -n 1 $path)'"
                fi

                if [[ "$ZIP" = true ]];
                then
                    CURRENTPATH=$(pwd)
                    DIR=$(dirname $path)
                    NAME=$(basename $path)
                    cd $DIR && tar rf $CURRENTPATH/my_app.tar $NAME

                    if [[ $? -eq 1 ]] || [[ $? -eq 2 ]];
                    then
                        echo "Chyba pri vytvareni archivu"
                        exit 2
                    fi
                fi

            fi
        else
            echo "Chybna cesta '$path'"
            exit 1
        fi

    fi

done < "$1"

if [[ "$HELP" = true ]];
then
    echo "Pouziti skriptu:"
    echo "`basename $0` [-h] [-v] [-z] [-n] <vstup>"
fi

if [[ "$COUNT" = true ]];
then
    echo "$FILECOUNT"
    echo "$DIRCOUNT"
    echo "$LINKCOUNT"
fi

exit 0