#!/bin/bash

## Color palette
RESET='\033[0m'
RED='\033[38;5;1m'
GREEN='\033[38;5;2m'
YELLOW='\033[38;5;3m'

## Logging functions
log() {
    printf "%b\n" "${*}" >&2
}

info() {
    log "${GREEN}INFO ${RESET} ==> ${*}"
}

warn() {
    log "${YELLOW}WARN ${RESET} ==> ${*}"
}

error() {
    log "${RED}ERROR ${RESET} ==> ${*}"
}
