#!/bin/bash
docker run --gpus all -it --rm \
  --user "$(id -u):$(id -g)" \
  $(id -G | sed 's/\([0-9]\+\)/--group-add \1/g') \
  -e HOME=/workspace \
  -v "$(pwd)":/workspace \
  -v /msa/data:/data \
  --entrypoint /bin/bash \
  boltz-predict
