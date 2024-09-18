#!/bin/bash

# Install mustache with `brew install mint` and `mint install hummingbird-project/swift-mustache-cli`

set -eu

function run_mustache {
    SRC=$1
    DEST=$2
    PROJECT=$3
    TEMPLATE_CONTEXT=$4

    TEMP_FILE=$(mktemp)
    if [[ -n "$TEMPLATE_CONTEXT" ]]; then
        echo "project: $PROJECT" | cat - "$TEMPLATE_CONTEXT" | mustache ../default.yml,- "$SRC" > "$TEMP_FILE"
    else
        echo "project: $PROJECT" | cat - ../default.yml | mustache - "$SRC" > "$TEMP_FILE"
    fi
    # delete file if it is empty or only contains spaces
    if ! grep -q '[^[:space:]]' "$TEMP_FILE" ; then
        rm "$TEMP_FILE"
    else
        mv "$TEMP_FILE" "$DEST"
        if [[ "$DEST" == *.sh ]]; then
            chmod a+x "$DEST"
        fi
    fi
}

function update_project {
    PROJECT_PATH=$1
    PROJECT_NAME=$(basename "$1")

    echo "Updating $PROJECT_NAME"

    if [[ -f "$PROJECT_NAME.yml" ]]; then
        TEMPLATE_CONTEXT="../$PROJECT_NAME.yml"
    else
        TEMPLATE_CONTEXT="../default.yml"
    fi
    
    pushd template > /dev/null
    for f in $(find . -print)
    do
        if [[ -f "$f" ]]; then
            EXTENSION="${f##*.}"
            if [[ "$EXTENSION" == "sh" ]]; then
                cp "$f" "$PROJECT_PATH"/"$f"
            elif [[ "$EXTENSION" == "mustache" ]]; then
                run_mustache "$f" "$PROJECT_PATH"/"${f%.*}" "$PROJECT_NAME" "$TEMPLATE_CONTEXT"
            else
                cp "$f" "$PROJECT_PATH"/"$f"
            fi
        elif [[ -d "$f" ]]; then
            if [[ ! -d "$PROJECT_PATH"/"$f" ]]; then
                mkdir "$PROJECT_PATH"/"$f"
            fi
        fi
    done
    popd > /dev/null
}

PROJECT_PATH=${1-}
if [[ -z "$PROJECT_PATH" ]]; then
    echo "Usage: update.sh <path to project>"
else
    FULL_PROJECT_PATH=$(cd "$(dirname "$PROJECT_PATH")"; pwd -P)/$(basename "$PROJECT_PATH")
    update_project "$FULL_PROJECT_PATH"
fi
