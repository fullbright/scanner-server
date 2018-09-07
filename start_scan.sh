#!/bin/bash

DEST=temp/dest

function scan_pages(){

    echo "Generate a token for this scan"
    todayandnow=$(date +%Y%m%d_%H%M%S)
    echo "Token is $todayandnow"

    echo "Scanning ..."
    scanimage --format tiff --batch=temp/$todayandnow.p%04d.tiff \
            --resolution 150 --batch-prompt --progress \
            -l 0 -t 0 -x 210 -y 295

    echo "Reduce the weight of the images"
    for scanfile in temp/$todayandnow.*.tiff; do
        scanfilebase=$(basename "$scanfile")
        convert "$scanfile" "temp/$scanfilebase.jpg"
    done
    #convert big-image.jpg -strip -quality 90 .jpg

    echo "Convert the scanned documents into pdf"
    convert temp/$todayandnow.*.jpg $DEST/myawesome_scan_$todayandnow.pdf && \

    echo "Remove temporary scanned tiff files"
    rm temp/$todayandnow*.jpg
    rm temp/$todayandnow*.tiff

}

until [[ $REPLY =~ ^[Nn]$ ]]
do
  scan_pages
  read -s -p "Scan another document ? [y/N]: " REPLY
done
