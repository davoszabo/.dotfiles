#!/bin/bash

shopt -s dotglob
TAB=""
recursive_link() {
    path=".*"
    if [ ! -z "$1" ]; then
        path="$1/*"
    fi

    for rc in ~/.dotfiles/$path; do
        filename="${rc##*/}"

        if [[ "$filename" == ".git" ]]; then continue; fi
        
        dir="$1/$filename"
        if [ -d ~/test/$dir ]; then
            echo "$TAB$filename/"
            TAB="   $TAB"
            recursive_link "$dir"
            TAB=""
            continue
        elif [ -f ~/test/$dir ]; then
            # Backup existing configuration
            echo -n -e "$TAB$filename \033[0;31m(back-up created)\033[0m"
            #mv ~/test/${filename} ~/test/${filename}.bak
        else
            echo -n "$TAB$filename"
        fi

        echo -e " \033[1;34m(symlink created at: ~$dir)\033[0m"
        # Symlink configuration into home directory
        #ln -s $rc ~/test
    done
    unset rc
}

recursive_link

# Check if the bashrc.d is referenced, and if not, write it into .bashrc
if ! grep -wq ".bashrc.d" ~/test/.bashrc; then
    cat >> ~/test/.bashrc <<EOF

# User specific aliases and functions
if [ -d ~/test/.bashrc.d ]; then
    for rc in ~/test/.bashrc.d/*; do
         print("$rc")
    done
fi
unset rc

EOF
fi

# source ~/.bashrc
