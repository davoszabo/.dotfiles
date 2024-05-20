#!/bin/bash

shopt -s dotglob

# Define the directory containing your dotfiles repository
DOTFILES_DIR="$HOME/.dotfiles"

# Define the backup directory
DATE=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="$HOME/.dotfiles_snapshots/$DATE"
mkdir -p $BACKUP_DIR

# Define the destination directory for symlinks
SYMLINK_DIR="$HOME"

function recursive_symlink() {

    local path=".*"
    if [ ! -z "$1" ]; then
        path="$1/*"
    fi
    
    local fullpath="$DOTFILES_DIR/$path"
    echo "Full path to search: $fullpath"

    for rc in $fullpath; do
        
        local name="${rc##*/}"

        local exclude_array=( ".git" "." ".." )
        if [[ ${exclude_array[@]} =~ $name ]]; then continue; fi
        
        local fullname="$name"
        if [ ! -z "$1" ]; then
            fullname="$1/$name"
        fi

        echo -e "\nAnalyze: $fullname"
        
        if [ "$fullname" = ".config" ] && [ -d ~/.config ]; then
            SYMLINK_DIR="$HOME/$fullname"
            
            echo "Checking the content of $SYMLINK_DIR"

            local config_path="$BACKUP_DIR/$fullname"
            mkdir -p "$config_path"
            
            recursive_symlink "$fullname"
            
            if [ -z "$(ls -A "$config_path")" ]; then
                rm -rf "$config_path"
            fi
            SYMLINK_DIR="$HOME"

            continue
        elif [ -e ~/$fullname ] || [ -h ~/$fullname ]; then
            local backup_fullpath="$BACKUP_DIR/$fullname"
            
            echo "Backing up $fullname to $backup_fullpath"
            mv ~/$fullname "$backup_fullpath"
        fi

        echo "Creating symlink for $rc to $SYMLINK_DIR"
        ln -s $rc $SYMLINK_DIR
    done
    unset rc
}

recursive_symlink

# Check if the bashrc.d is referenced, and if not, write it into .bashrc
if ! grep -wq ".bashrc.d" ~/.bashrc; then
    cat >> ~/.bashrc <<EOF

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "\$rc" ]; then
            . "\$rc"
        fi
    done
fi
unset rc

EOF
fi

source ~/.bashrc

