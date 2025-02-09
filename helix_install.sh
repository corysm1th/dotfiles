#!/usr/bin/zsh

LATEST_VER=$(
  curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" \
  | jq -r '.tag_name' \
  | sed 's/^v//'
)

FILE=helix-${LATEST_VER}-x86_64-linux.tar.xz
HELIX_DIR=${HOME}/.local/bin

mkdir -p ${HOME}/Downloads || true
rm -Rf ${HELIX_DIR}/hx ${HOME}/.config/helix/
mkdir -p ${HELIX_DIR} || true

curl -L https://github.com/helix-editor/helix/releases/download/${LATEST_VER}/${FILE} \
	-o ${HOME}/Downloads/${FILE}

tar -C ${HELIX_DIR} --strip-components=1 -xf ${HOME}/Downloads/${FILE} helix-${LATEST_VER}-x86_64-linux/hx

mkdir ${HOME}/.config/helix
tar -C ${HOME}/.config/helix --strip-components=1 -xf ${HOME}/Downloads/${FILE} helix-${LATEST_VER}-x86_64-linux/runtime

