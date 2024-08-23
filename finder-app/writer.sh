#!/bin/sh
#Writes 2nd arugement string into 1st arguement absolute path
#Author: Ravi Vanjara
#usage: writer.sh /home/directory-name/filename texttowriteinfile

writefile=$1
writestr=$2

if [ $# -lt 2 ]; then
    echo ERROR: Too less arugements. Please provide full path to file and text to write in file
    exit 1
fi

filepath=$( dirname $1 )

if [ ! -d "$filepath" ]; then
    $( mkdir -p $filepath )
fi

echo $writestr > $writefile 
if [ ! $?  -eq 0 ]; then
    echo ERROR: File $writefile not created successfully.
    exit 1
fi