#!/bin/bash
# trigger me with a shortcut key
# integrates with an Alfred workflow: first line of stdout will become a notification
# takes an argument for screencapture type

PORT="22"
MODE=$1
if [[ $MODE != "i" && $MODE != "S" ]]; then
    echo "Invalid mode (from Automator?)"
    exit 1;
fi

SERVER="lord.geek.nz"
KEY="$HOME/.ssh/sftp-key"
USER="jailedsftp"
REMOTEDIR="f"
PROTOCOL="https"

DIR=$(mktemp -d) || (echo "Unable to mktemp" && exit 1)
pushd "$DIR" > /dev/null;
filename=$(date +%Y%m%d%M%S | openssl sha1 | head -c 5).png

echo "cd $REMOTEDIR
put $filename" > batch;

screencapture -"$MODE" "$filename" -t png;
if [[ $? != 0 ]]; then
    # no file saved, or something
    rm -rf "$DIR";
    echo "Screen capture failed.";
    exit 1;
fi
# debug
# echo "$DIR/$filename";
# ls "$DIR";
# qlmanage -p "$DIR/$filename" > /dev/null 2>&1

# redirect stderr to stdout and blackhole stdout
# shellcheck disable=SC2069
sftp -i "$KEY" -P "$PORT" -b batch "$USER"@"$SERVER" 2>&1 >/dev/null;
if [[ $? != 0 ]]; then
    # terrible happened and was printed to stdout
    exit 1;
fi

echo -n "${PROTOCOL}://$SERVER/$REMOTEDIR/$filename" | pbcopy
echo "$filename"

# cleanup
popd > /dev/null;
rm -rf "$DIR";

# the killer feature that dropshare lacked:
# preload it assuming we're behind a caching proxy eg squid
# (also assuming the remote server sends useful expiry info)
curl "${PROTOCOL}://${SERVER}/${REMOTEDIR}/${filename}" > /dev/null 2>&1
