#!/bin/bash
cd "$(dirname "$0")"
if [ ! -d node_modules ]; then
    echo "Installing FocusFlow for the first time..."
    npm install
fi
npx electron . &
exit 0