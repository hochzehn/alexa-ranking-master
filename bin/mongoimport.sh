#!/usr/bin/env bash

detectedjs=$1
container_network=$2

LOCAL_IMPORT_FILE=${PWD}/result.json.tmp
CONTAINER_IMPORT_FILE="/app/tmp/result.json.tmp"

CONTAINER_NAME="alexarankingmaster_mongodb_1"

# Unescape
echo -e "$detectedjs" | sed -E 's/\\(.)/\1/g' > "$LOCAL_IMPORT_FILE"

MONGO_DB_NAME="local"
MONGO_COLLECTION_NAME="run_"$(date +"%Y-%m-%d--%H-%M-%S")

echo "Local Import File: "
cat "$LOCAL_IMPORT_FILE"

docker run -ti --rm \
  --link ${CONTAINER_NAME}:mongodb \
  --volume "$LOCAL_IMPORT_FILE":"$CONTAINER_IMPORT_FILE" \
  --net="$container_network" \
  mongo \
  sh -c 'exec mongoimport \
    --host "mongodb" \
    --port "27017" \
    --db "'${MONGO_DB_NAME}'" \
    --collection "'${MONGO_COLLECTION_NAME}'" \
    --upsert \
    --file "'${CONTAINER_IMPORT_FILE}'"'

echo ""
echo "Data was imported into MongoDB '$MONGO_DB_NAME', collection '$MONGO_COLLECTION_NAME'."

rm "$LOCAL_IMPORT_FILE"
