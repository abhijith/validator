#!/bin/sh -e

echo "Building app"
docker build -t unity:v1 -f Dockerfile.app .

echo "Building queue"
docker build -f Dockerfile.queue .

echo "Done"
