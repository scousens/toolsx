#! /bin/bash

# MYGIT_DIR is set in .zshrc
if [ ! -z "$1" ]; then
    if [ -d "$MYGIT_DIR/venv.$1" ]; then
        . $MYGIT_DIR/venv.$1/bin/activate
    fi
elif [ -d "./.venv" ]; then
        . ./.venv/bin/activate
elif [ -d "./venv" ]; then
        . ./venv/bin/activate
fi
