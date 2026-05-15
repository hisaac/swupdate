#!/usr/bin/env bash

if [[ -t 1 ]]; then
	BLUE='\033[0;34m'
	GREEN='\033[0;32m'
	RESET='\033[0m'
else
	BLUE=''
	GREEN=''
	RESET=''
fi

if [[ -t 2 ]]; then
	RED='\033[0;31m'
	RESET_ERR='\033[0m'
else
	RED=''
	RESET_ERR=''
fi

stdbuf -oL -eL "$@" \
	1> >(while IFS= read -r line; do echo -e "${GREEN}[stdout]${RESET} $line"; done) \
	2> >(while IFS= read -r line; do echo -e "${RED}[stderr]${RESET_ERR} $line"; done >&2)

EXIT_CODE=$?
echo -e "${BLUE}[exit]${RESET} $EXIT_CODE"
