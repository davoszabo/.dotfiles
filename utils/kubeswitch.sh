#!/bin/bash

KUBE_DIR="$HOME/.kube"
CONFIGS_DIR="$KUBE_DIR/configs"

# Ensure directories exist
mkdir -p "$CONFIGS_DIR"

function select_folder() {
    local folders=()
    
    # Properly handle case where directory is empty
    shopt -s nullglob
    folders=("$CONFIGS_DIR"/*/)
    shopt -u nullglob
    
    if [ ${#folders[@]} -eq 0 ]; then
        echo "Error: No folders found in $CONFIGS_DIR" >&2
        echo "Please create a folder with your Kubernetes config files first." >&2
        return 1
    fi

    # Extract just folder names
    folders=("${folders[@]%/*}")
    folders=("${folders[@]##*/}")

    echo "Please select a folder:" >&2
    PS3="Enter your choice (1-${#folders[@]}): "
    select selected_folder in "${folders[@]}"; do
        if [[ -n "$selected_folder" ]]; then
            echo "$selected_folder"
            return 0
        else
            echo "Invalid selection. Please try again." >&2
        fi
    done
}

function validate_folder() {
    local folder="$1"
    if [ ! -d "$CONFIGS_DIR/$folder" ]; then
        echo "Error: Folder '$folder' does not exist in $CONFIGS_DIR" >&2
        echo "Available folders:" >&2
        ls -1 "$CONFIGS_DIR" 2>/dev/null | sed 's/^/  /' || echo "  (none)" >&2
        return 1
    fi
}

function merge_configs() {
    local folder="$1"
    local folder_path="$CONFIGS_DIR/$folder"
    local merged_file="$folder_path/.merged_config"  # Changed to hidden file
    
    # Collect all files without extensions and exclude merged config
    local config_files=()
    while IFS= read -r -d $'\0' file; do
        config_files+=("$file")
    done < <(find "$folder_path" -type f -regex ".*\.\(yaml\|yml\)" -not -name ".merged_config" -print0 2>/dev/null)
    
    if [ ${#config_files[@]} -eq 0 ]; then
        echo "Error: No valid config files found in $folder_path" >&2
        echo "Files must have the extensions: yaml|yml" >&2
        return 1
    fi
    
    # Prepare KUBECONFIG variable with colon-separated paths
    local kubeconfig_paths=$(printf "%s:" "${config_files[@]}")
    kubeconfig_paths="${kubeconfig_paths%:}"
    
    echo "Merging the following config files:" >&2
    printf "  %s\n" "${config_files[@]}" >&2
    
    # Merge configs
    if ! KUBECONFIG="$kubeconfig_paths" kubectl config view --flatten > "$merged_file"; then
        echo "Error: Failed to merge configs" >&2
        return 1
    fi
    
    echo "Successfully merged configs to $merged_file" >&2
}

function use_folder() {
    local folder="$1"
    local folder_path="$CONFIGS_DIR/$folder"
    local merged_file="$folder_path/.merged_config"  # Changed to hidden file
    local kube_config="$KUBE_DIR/config"
    
    # Check if merged config exists
    if [ ! -f "$merged_file" ]; then
        echo "No merged config found, attempting to merge first..." >&2
        if ! merge_configs "$folder"; then
            echo "Error: Cannot switch to folder '$folder' - no valid configs found" >&2
            return 1
        fi
    fi
    
    # Create symlink
    ln -sf "$merged_file" "$kube_config"
    echo "Switched to config from '$folder' (symlinked $merged_file to $kube_config)" >&2
}

function main() {
    local command="$1"
    local folder="$2"
    
    # Validate command
    if [[ "$command" != "use" && "$command" != "merge" ]]; then
        echo "Usage: $0 {use|merge} [folder]" >&2
        echo "  If folder is not specified, you'll be prompted to select one" >&2
        exit 1
    fi

    # Get folder
    if [ -z "$folder" ]; then
        if ! folder=$(select_folder); then
            exit 1
        fi
    fi

    # Validate folder exists
    if ! validate_folder "$folder"; then
        exit 1
    fi

    case "$command" in
        "use") use_folder "$folder" ;;
        "merge") merge_configs "$folder" ;;
    esac
}

main "$@"
