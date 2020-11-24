#!/bin/bash

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DEST="$HOME/.config/karabiner"
FILE="karabiner.json"
LINE=$(printf -- "-%.0s" {1..100})

# interactive copy: diff, copy, view
icopy() {
    local result
    local status
    local answer
    local dir_to

    echo $LINE
    echo "[From < ] $1"
    echo "[To   > ] $2"
    echo $LINE

    result=$(diff "$1" "$2" 2>&1)
    status=$?

    if [ $status -eq 0 ]; then
        echo "Files are the same."
    elif [ $status -eq 1 ]; then
        echo "Files are different."
        echo $LINE
        echo "$result"
        echo $LINE
        if [ "$3" != "diff" ]; then
            read -p "Do you want to overwrite? [y/N] " answer
            case ${answer:0:1} in
                y|Y)
                    echo "Moving $2 to $2.old ..." && mv "$2" "$2.old"
                    echo "Copying $1 to $2 ..." && cp "$1" "$2"
                    ;;
                *)
                    ;;
            esac
        fi
    else
        if [ ! -e "$1" ]; then
            echo "$1 does not exist!"
            exit
        fi
        if [ ! -e "$2" ]; then
            echo "$2 does not exist ..."
            if [ "$3" != "diff" ]; then
                dir_to=$(dirname "$2")
                if [ ! -d $dir_to ]; then
                    echo "Making directory $dir_to ..." && mkdir -p $dir_to
                fi
                echo "Copying $1 to $2 ..." && cp "$1" "$2"
            fi
        fi
    fi

    if [ -e "$2" ]; then
        read -p "Do you want to view $2? [y/N] " answer
        case ${answer:0:1} in
            y|Y)
                cat "$2"
                ;;
            *)
                ;;
        esac
    fi
}

show_help() {
    echo "$LINE
[Source     ] $SRC
[Destination] $DEST
[Target File] $FILE
$LINE
--help      show this message and exit
--diff      compare target file(s) between source and destination
--push      copy target file(s) from source to destination
--pull      copy target file(s) from destination to source
$LINE"
}

main() {
    if [ $# -eq 0 ]; then
        show_help
    else
        case "$1" in
            "--diff")
                icopy "$SRC/$FILE" "$DEST/$FILE" "diff"
                ;;
            "--push")
                icopy "$SRC/$FILE" "$DEST/$FILE" "push"
                ;;
            "--pull")
                icopy "$DEST/$FILE" "$SRC/$FILE" "pull"
                ;;
            *)
                show_help
                ;;
        esac
    fi
}

main "$@"
