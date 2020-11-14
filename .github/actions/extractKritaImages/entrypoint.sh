#!/bin/sh
targetDir="/github/workspace/"

if [ "$BASE_DIR" -ne "" ]; then
    targetDir="/github/workspace/${BASE_DIR}/"
fi

targetListJSON=${targetDir}/list.json

echo "debug: targetDir = ${targetDir}"
ls -al "${targetDir}"

# remove old temporary folder (if available)
rm -Rf "${targetDir}/.temp" >/dev/null 2>&1

echo -n "[" >"${targetListJSON}"

cnt=0
for i in "${targetDir}"/*.kra; do
    cnt=$((cnt + 1))
    echo "${cnt}: processing ${i}"
    exportName=$(echo "${i}" | sed 's/\.kra$/.png/g')
    exportNameThumb=$(echo "${i}" | sed 's/\.kra$/_thumb.png/g')
    if [ ! -e "$exportName" ]; then
        mkdir .temp
        cd .temp || exit
        unzip -qq ../"${i}"
        if [ -e "mergedimage.png" ]; then
            convert -trim "mergedimage.png" -border 10x10 "$exportName"
            if [ -e "preview.png" ]; then
                convert -trim "preview.png" -border 10x10 "$exportNameThumb"
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
        echo -n "," >>"${targetListJSON}"
    fi
    echo "\"${i}.png\"" >>"${targetListJSON}"
done

echo -n "]" >>"${targetListJSON}"
