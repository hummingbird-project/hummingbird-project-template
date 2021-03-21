#!/bin/bash

set -eu

function run_mustache {
    SRC=$1
    DEST=$2
    PROJECT=$3

    if [[ -f "../$PROJECT.yml" ]]; then
        CONTEXT="../$PROJECT.yml"
    else
        CONTEXT="../default.yml"
    fi
    echo "project: $PROJECT" | cat - $CONTEXT | mustache - "$SRC" > "$DEST"
}

function update_project {
    export HBPROJECT=$1

    echo "Updating $HBPROJECT"

    pushd template > /dev/null
    for f in $(find . -print)
    do
        if [[ -f "$f" ]]; then
            EXTENSION="${f##*.}"
            if [[ "$EXTENSION" == "sh" ]]; then
                cp "$f" ../../$HBPROJECT/"$f"
            elif [[ "$EXTENSION" == "mustache" ]]; then
                run_mustache "$f" ../../$HBPROJECT/"${f%.*}" "$HBPROJECT"
            else
                cat "$f" | envsubst > ../../$HBPROJECT/"$f"
            fi
        elif [[ -d "$f" ]]; then
            if [[ ! -d ../../$HBPROJECT/"$f" ]]; then
                mkdir ../../$HBPROJECT/"$f"
            fi
        fi
    done
    popd > /dev/null
}

PROJECT=${1-}

if [[ -z "$PROJECT" ]]; then

    update_project hummingbird
    update_project hummingbird-auth
    update_project hummingbird-compression
    update_project hummingbird-core
    update_project hummingbird-fluent
    update_project hummingbird-lambda
    update_project hummingbird-mustache
    update_project hummingbird-redis
    update_project hummingbird-websocket

else
    update_project "$PROJECT"
fi
