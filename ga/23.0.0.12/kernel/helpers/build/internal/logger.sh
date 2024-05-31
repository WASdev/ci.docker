#!/bin/bash

function main() {
    if [ "$VERBOSE" != "true" ]; then
        exec >/dev/null
    fi
}

function hideLogs() {
    exec 3>&2 &>/dev/null
}

function showLogs() {
    exec 2>&3
    exec 3>&-
}

main