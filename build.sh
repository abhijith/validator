#!/bin/sh -e

echo "Building app"
docker build -t unity:v1 -f Dockerfile.app .
docker tag unity:v1 abhijithg/unity:v1

echo "Building queue"
docker build -f Dockerfile.queue .

echo "Done"
