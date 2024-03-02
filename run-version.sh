#!/usr/bin/env bash

set -Eeuo pipefail

VERSION=$1
IMAGE="node:$VERSION-bullseye-slim"

if ! test -d asciidoc-link-check; then
    git clone https://github.com/marcindulak/asciidoc-link-check
    cd asciidoc-link-check
    git checkout fix-program-is-not-a-function
    cp -r Dockerfile Dockerfile.orig
    cd ..
fi

if docker pull "$IMAGE"; then
    cd asciidoc-link-check
    cp -f Dockerfile.orig Dockerfile
    sed -i- "s|node:alpine|$IMAGE|" Dockerfile
    docker build --tag "asciidoc-link-check:$VERSION" .
    docker rm -f asciidoc-link-check || true
    cd ..
    time docker run --name asciidoc-link-check -v "${PWD}":/tmp:ro --rm -i "asciidoc-link-check:$VERSION" /tmp/test.adoc
else
    echo "$IMAGE" does not exist
fi
