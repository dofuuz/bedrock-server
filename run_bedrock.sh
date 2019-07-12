#!/usr/bin/env bash

cd /opt/bedrock

mkdir -p backup
mkdir -p download


# Create backup
if [ -d "server" ]; then
    Timestamp=$(date +%Y%m%d-%H%M%S)
    Ver=$(<server/version.txt)
    BackupFile="backup/${Timestamp}_${Ver}.tar.gz"
    echo "Creating backup to $BackupFile"
    tar -caf "$BackupFile" \
        server/worlds \
        server/permissions.json \
        server/server.properties \
        server/whitelist.json
fi


# Server update
echo "Checking for the latest version..."

# Download server index.html to check latest version
curl -LsS -o download/version.html https://minecraft.net/en-us/download/server/bedrock/
URL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' download/version.html)
if [ "$?" != 0 ]; then
    echo "WARNING: Unable to check version. Skipping update."
else
    DownloadZip=$(basename "$URL")
    NewVer=$(basename "$URL" .zip)

    # Download latest version of Bedrock dedicated server if a new one is available
    if [ -f "download/$DownloadZip" ] && [ -d "server" ]; then
        echo "Bedrock server is up to date."
    else
        echo "New version $NewVer is available."
        echo "Downloading $URL"
        curl -LsS -o "download/$DownloadZip" "$URL"

        echo "Extracting..."
        unzip -oq "download/$DownloadZip" -x server.properties permissions.json whitelist.json -d server
        unzip -nq "download/$DownloadZip" server.properties permissions.json whitelist.json -d server
        echo "$NewVer" > server/version.txt
    fi
fi

echo

cd server
LD_LIBRARY_PATH=. ./bedrock_server
