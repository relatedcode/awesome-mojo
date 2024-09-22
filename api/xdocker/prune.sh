#!/bin/bash

docker system prune -a --volumes -f
docker builder prune -a -f
