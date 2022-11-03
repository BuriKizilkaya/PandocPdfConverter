#!/bin/bash

docker run --rm \
    -v $(pwd):/data \
    -w /data \
    test \
    index.md -o index.pdf \
    -f markdown \
    --template https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/v2.0.0/eisvogel.tex \
    -t latex \
    --metadata-file=meta.yaml \
    