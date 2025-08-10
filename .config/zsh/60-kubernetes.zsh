k_fzf_ns() {
  # Ensure kubectl is installed
  if ! command -v kubectl &>/dev/null; then
    echo "kubectl not found."
    return 1
  fi

  # Define icons for contexts and namespaces, with defaults
  local icon_ctx="${ICON_K8S_CTX:-☸}"
  local icon_ns="${ICON_K8S_NS:-⎈}"

  # Get the current context (fast, local operation)
  local current_context
  current_context=$(kubectl config current-context)
  if [[ -z "$current_context" ]]; then
    echo "No Kubernetes context is currently set." >&2
    return 1
  fi

  # Get all contexts and format them, marking the current one
  local contexts
  contexts=$(kubectl config get-contexts -o name | while read -r ctx; do
    if [[ "$ctx" == "$current_context" ]]; then
      printf "%s %s (current)\n" "$icon_ctx" "$ctx"
    else
      printf "%s %s\n" "$icon_ctx" "$ctx"
    fi
  done)

  # Spinner for fetching namespaces from the remote cluster
  local spin='-\|/'
  local i=0
  (while true; do
    i=$(((i + 1) % 4))
    printf "\r%s Fetching namespaces for '%s'..." "${spin:$i:1}" "$current_context"
    sleep 0.1
  done) &
  local loader_pid=$!
  trap "kill $loader_pid 2>/dev/null; printf '\r%s\n' '                                                                    '" EXIT

  # Get namespaces for the current context, add icon
  local namespaces
  namespaces=$(kubectl get ns --no-headers -o custom-columns=":metadata.name" 2>/dev/null | awk -v icon="$icon_ns" '{print icon " " $1}')

  # Stop the spinner
  kill $loader_pid 2>/dev/null
  wait $loader_pid 2>/dev/null
  printf "\r%s\n" "                                                                      "

  # Combine contexts and namespaces into a single list for fzf
  local combined_list
  if [[ -n "$namespaces" ]]; then
    # Add a separator for visual clarity in the fzf list
    local separator="---"
    combined_list=$(printf "%s\n%s\n%s" "$contexts" "$separator" "$namespaces")
  else
    echo "Warning: No namespaces found for '$current_context'. Only contexts will be listed."
    combined_list="$contexts"
  fi

  # Use fzf to select an item
  local selected_line
  selected_line=$(echo -e "${combined_list}" | fzf \
    --ansi \
    --prompt="Select Context or Namespace: " \
    --height=40% \
    --border=rounded \
    --header="Select a context to switch, or a namespace for the current context.")

  # Exit if nothing was selected or the separator was chosen
  if [[ -z "$selected_line" ]] || [[ "$selected_line" == "---" ]]; then
    echo "No selection made."
    return 1
  fi

  # Process the user's selection
  local type_icon
  type_icon=$(echo "$selected_line" | awk '{print $1}')
  local selection_name

  if [[ "$type_icon" == "$icon_ctx" ]]; then
    # User selected a context
    selection_name=$(echo "$selected_line" | cut -d' ' -f2- | sed 's/ (current)$//')

    if [[ "$selection_name" == "$current_context" ]]; then
      echo "✓ Context '$selection_name' is already active."
      return 0
    fi

    if kubectl config use-context "$selection_name" >/dev/null; then
      echo "✓ Switched context to: $selection_name"
    else
      echo "Failed to switch context to '$selection_name'." >&2
      return 1
    fi
  elif [[ "$type_icon" == "$icon_ns" ]]; then
    # User selected a namespace
    selection_name=$(echo "$selected_line" | awk '{print $2}')
    local current_ns
    current_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}')

    if [[ "$selection_name" == "$current_ns" ]]; then
      echo "✓ Namespace '$selection_name' is already the default for context '$current_context'."
      return 0
    fi

    if kubectl config set-context --current --namespace="$selection_name" >/dev/null; then
      echo "✓ Switched default namespace for context '$current_context' to: $selection_name"
    else
      echo "Failed to switch namespace." >&2
      return 1
    fi
  else
    echo "Invalid selection." >&2
    return 1
  fi
}

k_fzf_pod() {
  # Ensure fzf and kubectl are installed
  if ! command -v fzf &>/dev/null || ! command -v kubectl &>/dev/null; then
    echo "fzf and kubectl are required." >&2
    return 1
  fi

  # Get the current context and namespace
  local current_context
  current_context=$(kubectl config current-context)
  local current_ns
  current_ns=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  [[ -z "$current_ns" ]] && current_ns="default"

  # Spinner for fetching data from the remote cluster
  local spin='-\|/'
  local i=0
  (while true; do
    i=$(((i + 1) % 4))
    printf "\r%s Fetching resources in '%s/%s'..." "${spin:$i:1}" "$current_context" "$current_ns"
    sleep 0.1
  done) &
  local loader_pid=$!
  trap "kill $loader_pid 2>/dev/null; printf '\r%s\n' '                                                                    '" EXIT

  # Fetch deployments and pods
  local deployments
  deployments=$(kubectl get deployments -o wide 2>/dev/null | tail -n +2 | awk '{print "[DEPLOYMENT] " $0}')
  local pods
  pods=$(kubectl get pods -o wide 2>/dev/null | tail -n +2 | awk '{print "[POD] " $0}')

  # Stop the spinner
  kill $loader_pid 2>/dev/null
  wait $loader_pid 2>/dev/null
  printf "\r%s\n" "                                                                      "

  # Check if any resources were found
  if [[ -z "$deployments" && -z "$pods" ]]; then
    echo "No deployments or pods found in namespace '$current_ns'."
    return 1
  fi

  # Combine deployments and pods into a single list for fzf
  local combined_list
  combined_list=$(printf "%s\n%s" "$deployments" "$pods")

  # Use fzf to select a resource and a keybinding action
  local selected_item
  selected_item=$(echo -e "${combined_list}" | fzf --exit-0 --ansi \
    --header="[ENTER]:describe [!]:restart [%]:logs-f [^]:logs [$]:shell" \
    --prompt="Select Resource: " \
    --height=50% \
    --border=rounded \
    --expect='!,%,^,$')

  # Exit if nothing was selected
  if [[ -z "$selected_item" ]]; then
    echo "No selection made."
    return 0
  fi

  # Parse fzf output
  local key
  key=$(echo "$selected_item" | head -n1)
  local line
  line=$(echo "$selected_item" | tail -n1)

  local resource_type
  resource_type=$(echo "$line" | awk '{print $1}')
  local resource_name
  resource_name=$(echo "$line" | awk '{print $2}')

  # Execute action based on key pressed
  case "$key" in
    "!")
      if [[ "$resource_type" == "[DEPLOYMENT]" ]]; then
        kubectl rollout restart deployment "$resource_name" && watch kubectl get pods
      else
        echo "Rolling restart is only available for deployments."
      fi
      ;;
    "$")
      if [[ "$resource_type" == "[POD]" ]]; then
        local containers
        containers=$(kubectl get pod "$resource_name" -o jsonpath='{.spec.containers[*].name}')
        local container_count
        container_count=$(echo "$containers" | wc -w)

        local target_container
        if [[ "$container_count" -gt 1 ]]; then
          target_container=$(echo "$containers" | tr ' ' '\n' | fzf --prompt="Select a container: ")
        else
          target_container="$containers"
        fi

        if [[ -n "$target_container" ]]; then
          echo "Attempting to connect to $resource_name/$target_container..."
          kubectl exec -it "$resource_name" -c "$target_container" -- /bin/bash || kubectl exec -it "$resource_name" -c "$target_container" -- /bin/sh
        else
          echo "No container selected."
        fi
      else
        echo "Shell access is only available for pods."
      fi
      ;;
    "^")
      if [[ "$resource_type" == "[POD]" ]]; then
        kubectl logs "$resource_name"
      else
        echo "Logs are only available for pods."
      fi
      ;;
    "%")
      if [[ "$resource_type" == "[POD]" ]]; then
        kubectl logs -f "$resource_name"
      else
        echo "Logs are only available for pods."
      fi
      ;;
    *) # Default action on ENTER
      if [[ "$resource_type" == "[DEPLOYMENT]" ]]; then
        kubectl describe deployment "$resource_name"
      elif [[ "$resource_type" == "[POD]" ]]; then
        kubectl describe pod "$resource_name"
      fi
      ;;
  esac
}
