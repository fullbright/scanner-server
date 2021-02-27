#!/bin/sh

function usage()
{
    echo "This should print the help. Work in progress."
    echo "scan2pdf.sh -m <mode> -r|d <resolution> -o <outputfilename> -s <source> -k <keep_tmp> -h|?"
}

function process_option()
{
	declare -a ARRAY=("${!1}"); shift
	VALUE=$1; shift
	DEFAULT=$1; shift
	MESSAGE=$1; shift
	if in_array ARRAY[@] "${VALUE}"; then
		echo ${VALUE}
		exit 0
	fi
	if [ ${VALUE} -lt 0 -o ${VALUE} -ge ${#ARRAY[@]} ]; then
		echo "$0: ${MESSAGE}"
		list_array ARRAY[@] "$DEFAULT"
		exit 1
	fi >&2
	echo ${ARRAY[${VALUE}]}
}

function in_array()
{
	declare -a ARRAY=("${!1}"); shift
	VALUE=$1; shift
	for i in ${!ARRAY[@]}; do
		test "${ARRAY[$i]}" = "${VALUE}" && return 0
	done
	return 1
}

function list_array()
{
	declare -a ARRAY=("${!1}"); shift
	DEFAULT=$1; shift
	for i in ${!ARRAY[@]}; do
		MARK_DEFAULT=" "
		test "${ARRAY[$i]}" = "${DEFAULT}" && MARK_DEFAULT="*"
		echo "  ${MARK_DEFAULT} [$i]  ${ARRAY[$i]}"
	done
}

function start_scan_process()
{	
	while getopts m:s:r:d:o:kh OPTION
	do
		case ${OPTION} in
			m)
				MODE=$(process_option MODES[@] "${OPTARG}" "${MODE}" "invalid mode, valid values for -m are:")
				test $? -gt 0 && exit 1
				;;
			r|d)
				RESOLUTION=$(process_option RESOLUTIONS[@] "${OPTARG}" "${RESOLUTION}" "invalid resolution, valid values for -r are:")
				test $? -gt 0 && exit 1
				;;
			s)
				SOURCE=$(process_option SOURCES[@] "${OPTARG}" "${SOURCE}" "invalid source, valid values for -s are:")
				test $? -gt 0 && exit 1
				;;
			o)
				OUTFILE=${OPTARG}
				;;
			k)
				KEEP_TMP=1
				;;
			h|?)
				usage
				exit 2
		esac
	done

	test -z "${OUTFILE}" && usage

	echo -e "\e[1mScanning options:\e[0m"
	echo -e "\e[33mMODE:    \e[1m${MODE}\e[0m"
	echo -e "\e[33mDPI:     \e[1m${RESOLUTION}\e[0m"
	echo -e "\e[33mSOURCE:  \e[1m${SOURCE}\e[0m"
	echo -e "\e[33mOUTFILE: \e[1m${OUTFILE}\e[0m"

	#SCANIMAGE_OPTS=' --resolution 150 --brightness 20 --contrast 20 -l 0 -t 0 -x 210 -y 290'
	SCANIMAGE_OPTS=' -l 0 -t 0 -x 210 -y 290'

	if [ "$1" = "" ]; then
			echo "Usage: $0 <output-file-name.pdf>"
			exit 1
	fi

	TMPDIR=$(mktemp -d /tmp/scan2pdf.XXXXXXX)

	echo "Temporary files kept in: ${TMPDIR}"

	cd ${TMPDIR}

	set +e
	scanimage --device ${DEVICE} ${SCANIMAGE_OPTS} --resolution ${RESOLUTION} --source="${SOURCE}" --mode="${MODE}" --progress --verbose --format=tiff --batch  # --batch-prompt
	set -e
	ls -1 out*.tif > /dev/null

	tiffcp -c lzw out*.tif scan.tiff

	cd -

	tiff2pdf -z ${TMPDIR}/scan.tiff > ${OUTFILE}

	ls -l ${OUTFILE}

	if [ -z "${KEEP_TMP}" ]; then
			rm -rf ${TEMPDIR}
	else
			echo "Temporary files are in ${TEMPDIR}"
	fi
}

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

function check_temp_files(){
	files="temp/*.tiff"
	regex="temp/(.*).p[0-9]{4}.tiff$"
	for f in $files    # unquoted in order to allow the glob to expand
	do
		if [[ $f =~ $regex ]]
		then
			name="${BASH_REMATCH[1]}"
			echo "Found the match : ${name}"    # concatenate strings
			name_match="${name}"    # same thing stored in a variable

			# Converting the images to pdf
			batch_convert_to_jpg ${name}
			convert_jpg_to_pdf ${name}
		else
			echo "$f doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
		fi
	done
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
    #rm temp/$todayandnow*.jpg
    #rm temp/$todayandnow*.tiff

}

function upload_scannedpages(){

    ORIGINAL_FOLDER=$PWD
    echo "Current folder is $ORIGINAL_FOLDER"

    #echo "Moving into the $DEST folder"
    #cd $DEST

    echo "Uploading scanned documents. No downloading"
    #grive -u
    rclone copy -P temp/dest scans_home_extended:/scans/xubuntu_laptop/scans

    #echo "Get back to original folder"
    #cd $ORIGINAL_FOLDER
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

# 
if [ "${1}" != "--source-only" ]; then
    start_scan_process "${@}"
fi
