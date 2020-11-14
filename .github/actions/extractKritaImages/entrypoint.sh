#!/bin/sh

echo "debug:"
ls -al /github/workspace
ls -al /github/workspace/* 

if [ "$BASE_DIR" -ne "" ]; then
    cd "/github/workspace/$BASE_DIR" || exit
fi

# remove old temporary folder (if available)
rm -Rf .temp >/dev/null 2>&1

echo -n "[" >list.json

cnt=0
for i in *.kra; do
    cnt=$((cnt + 1))
    echo "${cnt}: processing ${i}"
    exportName=$(echo "${i}" | sed 's/\.kra$/.png/g')
    exportNameThumb=$(echo "${i}" | sed 's/\.kra$/_thumb.png/g')
    if [ ! -e "$exportName" ]; then
        mkdir .temp
        cd .temp || exit
        unzip -qq ../"${i}"
        if [ -e "mergedimage.png" ]; then
            convert -trim "mergedimage.png" -border 10x10 "../$exportName"
            if [ -e "preview.png" ]; then
                convert -trim "preview.png" -border 10x10 "../$exportNameThumb"
            fi
        else
            echo "${cnt}: ${i}: cannot find mergedimage.png!"
        fi
        cd ..
        rm -Rf .temp
    else
        echo "skipped because it already exists."
    fi

    if [ "${cnt}" -gt "1" ]; then
        echo -n "," >>list.json
    fi
    echo "\"${i}.png\"" >>list.json
done

echo -n "]" >>list.json
