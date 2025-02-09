#!/usr/bin/env bash

# Usage:
#   ./get_latest_version.sh <github_user> <github_repo>

# Ensure we have two arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 <github_user> <github_repo>"
  exit 1
fi

GITHUB_USER="$1"
GITHUB_REPO="$2"

# Fetch the latest release data from GitHub's API and parse out the tag_name
# Then remove a leading 'v' if it exists
LATEST_VERSION=$(
  curl -s "https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases/latest" \
  | jq -r '.tag_name' \
  | sed 's/^v//'
)

echo "$LATEST_VERSION"

