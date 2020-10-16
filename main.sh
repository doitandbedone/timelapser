#!/bin/bash
DEFAULT_MEDIA_DIRECTORY=/Volumes/disk2/appdata/ispyagentdvr/media/video/
TIMELAPSE_RATE=0.1

function scanDirectory() {
    local format=$1
    for dir in */; do
        echo "Scanning directory $dir for $format files."
        curMediaDir=$MEDIA_DIRECTORY/$dir
        cd $curMediaDir
        dirName=$(echo "$dir" | tr -d /)
        mediaFileList=${format}_clips.txt
        listMediaFiles $mediaFileList $format
        combineFiles $mediaFileList $format
        toTimeLapse $curMediaDir$dirName.$format $dirName $format $curMediaDir
    done
    echo "Scan for $format files completed."
}

function listMediaFiles() {
    local file=$1
    local format=$2
    echo "Creating list file $file."
    printf "file '%s'\n" *.$format >$file
    echo "Found the following files:"
    cat $mediaFileList
}

function combineFiles() {
    local file=$1
    local format=$2
    curDir=${PWD##*/}
    echo "Combining files for directory $curDir."
    ffmpeg -f concat -i $file -c copy $curDir.$format
}

function validateDirectory() {
    local result=false
    if [ -d $1 ]; then
        result=true
        echo "Directory is valid. Proceeding with scan..."
    else
        echo "Directory $1 is invalid."
    fi
    echo $result
}

function toTimeLapse() {
    local file=$1
    local outputFileName=$2
    local format=$3
    local outputDir=$4
    echo "Converting $file to timelapse file $outputDir${outputFileName}_timelapse.$format."
    ffmpeg -i $file -filter:v "setpts=$TIMELAPSE_RATE*PTS" -an $outputDir${outputFileName}_timelapse.$format
}

formats=(mkv webm)
dirValid=false
while [ "$dirValid" = false ]; do
    echo "Please provide root directory for file scan:"
    read MEDIA_DIRECTORY
    dirValid=$(validateDirectory $MEDIA_DIRECTORY)
done
for format in ${formats[@]}; do
    cd $MEDIA_DIRECTORY
    scanDirectory $format
done
