#!/bin/bash
# trigger me with a shortcut key

f=$(mktemp)
screencapture -i "$f"
if [[ $? == 1 ]]; then
    # no file saved, or something
    rm -rf "$f";
    exit 1;
fi
# debug
echo "$f";
qlmanage -p "$f" > /dev/null 2>&1

# TODO: determine name
# TODO: upload to server
# TODO: copy URL to clipboard

# cleanup
rm -rf "$f"
