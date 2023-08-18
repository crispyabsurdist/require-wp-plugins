#!/bin/bash

if ! [ -x "$(command -v jq)" ]; then
    echo "jq is not installed. Attempting to install..."
    if [ -x "$(command -v brew)" ]; then
        brew install jq
    else
        echo 'Error: Homebrew is not installed. Install Homebrew and try again.' >&2
        exit 1
    fi
fi

if ! [ -x "$(command -v composer)" ]; then
    echo 'Error: composer is not installed.' >&2
    exit 1
fi

if ! composer validate --no-check-all --strict; then
    echo "Error: composer.json is not valid." >&2
    exit 1
fi

PHP_VERSION=$(jq -r '.require.php' composer.json)
if [[ "$PHP_VERSION" != ">=8.1" ]]; then
    jq '.require.php = ">=8.1"' composer.json > composer_temp.json && mv composer_temp.json composer.json
fi

jq -r '.require | keys[]' composer.json | while read plugin_name; do
    # Skip the php key
    if [[ "$plugin_name" != "php" ]]; then
        composer require $plugin_name
    fi
done
