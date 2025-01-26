#!/usr/bin/zsh

LATEST_VER=$(
  curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" \
  | jq -r '.tag_name' \
  | sed 's/^v//'
)

FILE=helix-${LATEST_VER}-x86_64-linux.tar.xz
HELIX_DIR=${HOME}/.local/bin

mkdir -p ${HOME}/Downloads || true
rm -Rf ${HELIX_DIR}
mkdir -p ${HELIX_DIR} || true

curl -L https://github.com/helix-editor/helix/releases/download/${LATEST_VER}/${FILE} \
	-o ${HOME}/Downloads/${FILE}

mkdir ${HOME}/tmp

cd ${HOME}/tmp && tar -xf ${HOME}/Downloads/${FILE} 

mkdir -p ${HOME}/.local/bin || true
sudo mv ${HOME}/tmp/helix-${LATEST_VER}-x86_64-linux/hx ${HOME}/.local/bin/hx
sudo mv ${HOME}/tmp/helix-${LATEST_VER}-x86_64-linux/runtime ${HOME}/.config/helix/

rm -Rf ${HOME}/tmp

