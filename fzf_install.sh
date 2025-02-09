#!/bin/bash

LATEST_VERSION=$(curl --silent https://api.github.com/repos/junegunn/fzf/releases/latest | jq -r .tag_name)
VNUM=${LATEST_VERSION:1}
echo "${VNUM}"
FILE=fzf-${VNUM}-linux_amd64.tar.gz
FZF_DIR=${HOME}/fzf

mkdir -p ${HOME}/Downloads || true
rm -Rf ${FZF_DIR}
mkdir -p ${FZF_DIR} || true

curl -L https://github.com/junegunn/fzf/releases/download/${LATEST_VERSION}/${FILE} \
	-o ${HOME}/Downloads/${FILE}

tar -xzf ${HOME}/Downloads/${FILE} -C ${FZF_DIR}

