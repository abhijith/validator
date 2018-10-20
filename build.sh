#!/bin/sh -e

echo "Building app"
docker build -t app:v1 -f Dockerfile.app .
docker tag app:v1 abhijithg/app:v1

echo "Building queue"
docker build -f Dockerfile.queue .

echo "Done"
