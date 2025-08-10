# Unified AWS fzf selector
# To be sourced in your .zshrc or .bashrc
# Binds to a hotkey for quick access

# 256 Color Codes
C_RED='\033[38;5;196m'      # A bright red
C_PURPLE='\033[38;5;141m'   # A soft purple
C_BLUE='\033[38;5;39m'      # A bright blue
C_ORANGE='\033[38;5;214m'   # A vivid orange
C_RESET='\033[0m'

# Nerd Font Icons
ICON_PROFILE="${C_RED}${C_RESET}"     # nf-oct-person
ICON_REGION="${C_PURPLE}${C_RESET}"  # nf-fa-globe
ICON_EKS="${C_BLUE}ﴱ${C_RESET}"       # nf-md-kubernetes
ICON_EC2="${C_ORANGE}﬙${C_RESET}"    # nf-fa-server

aws_fzf_ec2() {
    # Spinner for user feedback
    local spin='-\|/'
    local i=0
    (while true; do
        i=$(( (i+1) %4 ))
        printf "\r%s Fetching EC2 instances..." "${spin:$i:1}"
        sleep 0.1
    done) &
    local loader_pid=$!
    trap "kill $loader_pid 2>/dev/null; printf '\r%s\n' '                                '" EXIT

    # Fetch running EC2 instances
    local ec2_instances=$(aws ec2 describe-instances --no-cli-pager --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].{ID:InstanceId,NAME:Tags[?Key==`Name`].Value|[0]}' --output text 2>/dev/null | awk -F'\t' -v icon="$ICON_EC2" '{print icon " " $1 " (" $2 ")"}')

    # Stop the spinner
    kill $loader_pid 2>/dev/null
    wait $loader_pid 2>/dev/null

    if [[ -z "$ec2_instances" ]]; then
        echo "No running EC2 instances found."
        return 1
    fi

    # fzf for instance selection
    local selected_instance=$(echo -e "${ec2_instances}" | fzf \
        --ansi \
        --prompt="Select EC2 Instance: " \
        --height=40% \
        --border=rounded \
        --header="Select an instance to start an SSM session")

    if [[ -z "$selected_instance" ]]; then
        echo "No instance selected."
        return 1
    fi

    local instance_id=$(echo "$selected_instance" | awk '{print $2}')
    aws ssm start-session --target "$instance_id"
}

aws_fzf() {
    # Ensure AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found."
        return 1
    fi

    # Show a loading spinner (optional, but nice for UX)
    local spin='-\|/'
    local i=0
    (while true; do
        i=$(( (i+1) %4 ))
        printf "\r%s Gathering AWS resources..." "${spin:$i:1}"
        sleep 0.1
    done) &
    local loader_pid=$!
    # Kill the loader when the function exits
    trap "kill $loader_pid 2>/dev/null; printf '\r%s\n' '                                '" EXIT

    # Gather resources with Nerd Font icons and text tags. Note the 2>/dev/null to suppress errors.
    local profiles=$(aws configure list-profiles | awk -v icon="$ICON_PROFILE" '{print icon " [PROFILE] " $1}')
    local regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text | tr '\t' '\n' | awk -v icon="$ICON_REGION" '{print icon " [REGION]  " $1}')
    local eks_clusters=$(aws eks list-clusters --query 'clusters' --output text 2>/dev/null | tr '\t' '\n' | awk -v icon="$ICON_EKS" '{print icon " [EKS]     " $1}')

    # Stop the loading spinner
    kill $loader_pid 2>/dev/null
    wait $loader_pid 2>/dev/null

    # Combine all resources into one list, filtering out any empty lines
    local all_resources=$(echo -e "$profiles\n$regions\n$eks_clusters" | grep . )

    # Exit if no resources found
    if [[ -z "$all_resources" ]]; then
        echo "No AWS resources found to display."
        return 1
    fi

    # Use fzf to select a resource
    local selected_item=$(echo -e "${all_resources}" | fzf \
        --ansi \
        --prompt="Select AWS Resource: " \
        --height=60% \
        --border=rounded \
        --header="Select an item to perform an action" \
        --color='fg+:bright-yellow,bg+:238,hl:196,hl+:196,info:141,prompt:214,pointer:196,marker:196,spinner:141')

    # Exit if nothing was selected
    if [[ -z "$selected_item" ]]; then
        echo "No item selected."
        return 1
    fi

    # Parse the selected item to get type and value
    local resource_type=$(echo "$selected_item" | awk '{print $2}')
    local resource_value=$(echo "$selected_item" | awk '{$1=$2=""; print $0}' | xargs)

    # Perform action based on the resource type
    case "$resource_type" in
        "[PROFILE]")
            export AWS_PROFILE="$resource_value"
            echo "✓ Switched to profile: $AWS_PROFILE"
            echo "Verifying identity..."
            # Attempt to verify identity. If it fails, attempt SSO login.
            aws sts get-caller-identity
            if [[ $? -ne 0 ]]; then
                echo "Identity verification failed. Attempting SSO login..."
                if aws sso login; then
                    echo "SSO login successful. Verifying new identity..."
                    aws sts get-caller-identity
                else
                    echo "SSO login failed." >&2
                fi
            fi
            ;;
        "[REGION]")
            export AWS_DEFAULT_REGION="$resource_value"
            echo "✓ Switched to region: $AWS_DEFAULT_REGION"
            ;;
        "[EKS]")
            local cluster_name=$(echo "$resource_value" | awk '{print $1}')
            local current_region=${AWS_DEFAULT_REGION:-$(aws configure get region --profile ${AWS_PROFILE:-default})}
            echo "Updating kubeconfig for EKS cluster: $cluster_name in region $current_region"
            aws eks update-kubeconfig --name "$cluster_name" --region "$current_region"
            ;;
        *)
            echo "Unknown resource type."
            return 1
            ;;
    esac
}