#!/bin/bash
# trigger me with a shortcut key

PORT="22"
SERVER="lord.geek.nz"
KEY="$HOME/.ssh/sftp-key"
USER="jailedsftp"
REMOTEDIR="f"

DIR=$(mktemp -d)
pushd "$DIR"
filename=$(date +%Y%m%d%M%S | openssl sha1 | head -c 5).png

echo "cd $REMOTEDIR
put $filename" > batch;

screencapture -i "$filename";
if [[ $? != 0 ]]; then
    # no file saved, or something
    rm -rf "$DIR";
    echo "Screen capture failed.";
    exit 1;
fi
# debug
echo "$DIR/$filename";
ls "$DIR";
# qlmanage -p "$DIR/$filename" > /dev/null 2>&1

sftp -i "$KEY" -P "$PORT" -b batch "$USER"@"$SERVER";

echo "$SERVER/$REMOTEDIR/$filename" | pbcopy

# cleanup
popd;
rm -rf "$DIR";
