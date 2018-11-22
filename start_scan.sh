#!/bin/bash

DEST=temp/dest

function batch_convert_to_jpg(){

    todayandnow=$1
    echo "Converting images of batch $todayandnow from tiff to jpg"

    echo "Reduce the weight of the images"
    for scanfile in temp/$todayandnow*.tiff; do
        scanfilebase=$(basename "$scanfile")
        convert "$scanfile" "temp/$scanfilebase.jpg"
    done

    echo "Conversion finished."
}

function convert_jpg_to_pdf(){

    echo "Converting jpg from batch $1 to pdf"
    convert temp/$1*.jpg $DEST/myawesome_scan_$1.pdf

}

function clean_temp_files(){

    todayandnow=$1
    echo "Remove temporary scanned tiff and jpg files for batch $todayandnow"
    rm temp/$todayandnow*.jpg
    rm temp/$todayandnow*.tiff

}

function scan_pages(){

    echo "Generate a token for this scan"
    todayandnow=$(date +%Y%m%d_%H%M%S)
    echo "Token is $todayandnow"

    echo "Scanning ..."
    scanimage --format tiff --batch=temp/$todayandnow.p%04d.tiff \
            --resolution 150 --batch-prompt --progress \
            -l 0 -t 0 -x 210 -y 295

    echo "Reduce the weight of the images"
    #for scanfile in temp/$todayandnow.*.tiff; do
    #    scanfilebase=$(basename "$scanfile")
    #    convert "$scanfile" "temp/$scanfilebase.jpg"
    #done
    ##convert big-image.jpg -strip -quality 90 .jpg
    batch_convert_to_jpg "$todayandnow"

    echo "Convert the scanned documents into pdf"
    #convert temp/$todayandnow.*.jpg $DEST/myawesome_scan_$todayandnow.pdf && \
    convert_jpg_to_pdf "$todayandnow"

    echo "Remove temporary scanned tiff files"
    rm temp/$todayandnow*.jpg
    rm temp/$todayandnow*.tiff

}

function upload_scannedpages(){

    ORIGINAL_FOLDER=$PWD
    echo "Current folder is $ORIGINAL_FOLDER"

    echo "Moving into the $DEST folder"
    cd $DEST

    echo "Uploading scanned documents. No downloading"
    grive -u

    echo "Get back to original folder"
    cd $ORIGINAL_FOLDER
}

function interactive_scan(){

    until [[ $REPLY =~ ^[Nn]$ ]]
    do
        scan_pages
        read -s -p "Scan another document ? [y/N]: " REPLY
    done

    # Upload the files to Google Drive
    upload_scannedpages

}

#interactive_scan

# End of script
