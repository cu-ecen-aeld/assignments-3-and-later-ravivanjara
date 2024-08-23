#!/bin/sh
#Finds 2nd arugment text/string in files contained in 1st arguement which is target directory
#Author: Ravi Vanjara
#usage : find.sh /home/directory-name hereisthetexttofind

filesdir=$1
searchstr=$2


#find_in_files() {
#num_files=0
#num_files=$( find $filesdir -type f | wc -l )

#echo INFO: Files found $num_files
#echo The number of files are $num_files  and the number of matching lines are Y
#return 5
#}




if [ $# -lt 2 ]; then
    echo ERROR: Too less arguements. Please provide directory and text to find
    exit 1
fi

if [ ! -d "$1" ]; then
    echo ERROR: $1 is not a directory
    exit 1
fi

#find_in_files()
num_files=$( find $filesdir -type f -follow | wc -l )
num_matching_lines=$( grep -ir $searchstr $filesdir | wc -l ) 


echo looking through files in directory $filesdir for $searchstr

echo INFO: $num_files files found 
echo RESULT: The number of files are $num_files and the number of matching lines are $num_matching_lines




