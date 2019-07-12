#!/usr/bin/env bash
# Minecraft Bedrock dedicated server helper script
# Auto backup and update
# https://github.com/dofuuz/bedrock-server


mkdir -p backup
mkdir -p download

VersionTxt=server/version.txt
CurrentVer=$(cat "$VersionTxt" 2> /dev/null)

# Create backup
if [ -d "server" ]; then
    Timestamp=$(date +%Y%m%d-%H%M%S)
    BackupTgz="backup/${Timestamp}_${CurrentVer}.tar.gz"
    echo "Creating backup to $BackupTgz"
    tar -caf "$BackupTgz" \
        server/worlds \
        server/permissions.json \
        server/server.properties \
        server/whitelist.json
fi


# Check latest version
echo "Checking for the latest version..."
VersionHtml=download/version.html
curl -LsS -o "$VersionHtml" https://minecraft.net/en-us/download/server/bedrock/
ServerUrl=$(grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' "$VersionHtml")
if [ "$?" != 0 ]; then
    echo "WARNING: Unable to check version. Skipping update."
else
    ServerZip=download/$(basename "$ServerUrl")
    NewVer=$(basename "$ServerUrl" .zip)

    # Check for Latest server is installed
    if [ "$CurrentVer" == "$NewVer" ]; then
        echo "Bedrock server is up to date."
    else
        # Download and install/update server
        echo "New version $NewVer is available."
        echo "Downloading $ServerUrl"
        curl -L -o "$ServerZip" "$ServerUrl"

        echo "Extracting..."
        unzip -oq "$ServerZip" -x permissions.json server.properties whitelist.json -d server
        unzip -nq "$ServerZip" permissions.json server.properties whitelist.json -d server
        echo "$NewVer" > "$VersionTxt"
    fi
fi

echo

cd server
LD_LIBRARY_PATH=. ./bedrock_server

echo
