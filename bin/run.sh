#!/usr/bin/env bash

# Parameters
number_of_domains=$1

# Variables
RESTMQ_IP=127.0.0.1

# Execution
docker-compose up --force-recreate -d
docker-compose scale worker=10

domains=$(docker run hochzehn/alexa-ranking-parser "$number_of_domains")
echo "DOMAINS: $domains"

docker run --rm --link alexarankingmaster_restmq_1:restmq --net=alexarankingmaster_default hochzehn/js-queue-writer "http://restmq:8888"/q/domains 2 "$domains"
sleep 50
detectedjs=$(docker run --rm --link alexarankingmaster_restmq_1:restmq --net=alexarankingmaster_default hochzehn/js-queue-reader "http://restmq:8888/q/detectedjs")

echo "\$detectedjs:\n$detectedjs"

bin/mongoimport.sh "$detectedjs" "alexarankingmaster_default"

docker rm -f js-queue-writer
docker-compose stop
docker-compose rm -f --all
