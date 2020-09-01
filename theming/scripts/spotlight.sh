#! /bin/bash

DIR=$1

# Wait for internet

while ! ping -c 1 -W 1 8.8.8.8; do
    sleep 1
done

# Get images

set +e

response=$(wget -qO- "https://arc.msn.com/v3/Delivery/Cache?pid=279978&fmt=json&ua=WindowsShellClient&lc=en,en-US&ctry=US")
status=$?


items=$(jq -r ".batchrsp.items" <<< $response)

function decodeURL
{
    printf "%b\n" "$(sed 's/+/ /g; s/%\([0-9A-F][0-9A-F]\)/\\x\1/g')"
}

function setImage
{
    index="$1"
    name="$2"

    item=$(jq -r ".[$index].item" <<< $items | perl -0pe 's/.*?adData = (.*?);.*/\1/s')

    landscapeUrl=$(jq -r ".ad.image_fullscreen_001_landscape.u" <<< $item)
    title=$(jq -r ".ad.title_text.tx" <<< $item)
    searchTerms=$(jq -r ".ad.title_destination_url.u" <<< $item | perl -pe 's/.*?q=(.*?)&.*/\1/' | decodeURL)

    path="$DIR/img/$name.jpg"

    wget -qO "$path" "$landscapeUrl"
}

setImage "0" "wallpaper"
setImage "1" "lockscreen"
setImage "2" "greeter"
# setImage "3" "wallpaper3"
# setImage "4" "wallpaper4"

exit 0
