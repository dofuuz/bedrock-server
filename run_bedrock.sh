#!/usr/bin/env bash
# Minecraft Bedrock dedicated server helper script
# Auto backup and update
# https://github.com/dofuuz/bedrock-server


VersionTxt=server/version.txt
CurrentVer=$(cat "$VersionTxt" 2> /dev/null)

mkdir -p backup
mkdir -p download


# Create backup
if [ -d "server" ]; then
    Timestamp=$(date +%Y%m%d-%H%M%S)
    BackupFile="backup/${Timestamp}_${CurrentVer}.tar.gz"
    echo "Creating backup to $BackupFile"
    tar -caf "$BackupFile" \
        server/worlds \
        server/permissions.json \
        server/server.properties \
        server/whitelist.json
fi


# Check latest version
echo "Checking for the latest version..."
curl -LsS -o download/version.html https://minecraft.net/en-us/download/server/bedrock/
URL=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' download/version.html)
if [ "$?" != 0 ]; then
    echo "WARNING: Unable to check version. Skipping update."
else
    DownloadZip=download/$(basename "$URL")
    NewVer=$(basename "$URL" .zip)

    # Check for Latest server is installed
    if [ "$CurrentVer" == "$NewVer" ]; then
        echo "Bedrock server is up to date."
    else
        # Download and install/update server
        echo "New version $NewVer is available."
        echo "Downloading $URL"
        curl -L -o "$DownloadZip" "$URL"

        echo "Extracting..."
        unzip -oq "$DownloadZip" -x permissions.json server.properties whitelist.json -d server
        unzip -nq "$DownloadZip" permissions.json server.properties whitelist.json -d server
        echo "$NewVer" > "$VersionTxt"
    fi
fi

echo

cd server
LD_LIBRARY_PATH=. ./bedrock_server

echo
