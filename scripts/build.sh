#!/usr/bin/env bash
docker build --no-cache -t acidtmn/nodebb3 .
yes | docker image prune
