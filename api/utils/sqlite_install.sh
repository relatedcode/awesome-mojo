#!/bin/bash

if ! command -v sqlite3 >/dev/null; then
    echo "> Installing sqlite3..."
    sudo apt-get install sqlite3 -y
fi
