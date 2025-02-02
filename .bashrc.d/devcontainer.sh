devc() {
  # Initialize variables
  local workspace_folder="."
  local config_file=""
  local remove_existing_container=""
  local command=""
  local command_args=()

  # Capture the command (up, exec, etc.)
  if [[ "$#" -gt 0 ]]; then
    command="$1"
    shift
  fi

  # Parse the remaining arguments
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      -c|--config)
        config_file="$2"
        shift 2
        ;;
      -r|--remove-existing-container)
        remove_existing_container="--remove-existing-container"
        shift
        ;;
      *)
        # Collect other arguments
        command_args+=("$1")
        shift
        ;;
    esac
  done

  # Build the devcontainer command
  local cmd="devcontainer ${command} --workspace-folder ${workspace_folder}"

  # Add the config file if provided
  if [[ -n "$config_file" ]]; then
    cmd+=" --config ${config_file}"
  fi

  # Add the remove existing container flag if provided
  if [[ -n "$remove_existing_container" ]]; then
    cmd+=" ${remove_existing_container}"
  fi

  # Add other command arguments
  for arg in "${command_args[@]}"; do
    cmd+=" ${arg}"
  done

  # Execute the command
  echo "Generated command: $cmd"
  eval "$cmd"
}

alias devcrun="devc up; devc exec bash"

