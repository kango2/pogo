#!/bin/bash

# Input directory
dir=""

# Usage message
usage() {
  echo "Usage: $0 -d directory"
  echo "Generates md5 checksums for all files in the directory and subdirectories, including compressed files"
  exit 1
}

# Help message
help() {
  echo "Usage: $0 [OPTION]"
  echo "Generates md5 checksums for all files in the directory and subdirectories, including compressed files"
  echo ""
  echo "Options:"
  echo "  -d  directory to generate checksums for (required)"
  echo "  -h  display this help message"
  exit 0
}

# Use getopts to parse options
while getopts "d:h" opt; do
  case $opt in
    d) dir=$OPTARG ;;
    h) help ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

# Check if directory was provided
if [ -z "$dir" ]; then
  echo "Error: directory must be provided" >&2
  usage
fi

# Check if directory exists
if [ ! -d "$dir" ]; then
  echo "Error: directory $dir does not exist" >&2
  exit 1
fi

# Change to the directory
cd "$dir"


# Generate md5 checksum for all files in the directory and subdirectories, including compressed files
for file in `find . -type f`;
do
	md5 -r ${file} >>checksums.txt	

	extension=${file##*.}
	if [[ "$extension" == "zip" ]]; 
	then
		echo $(unzip -p ${file} | md5) ${file},unzippedcontent >> checksums.txt
	
	elif [[ "$extension" == "gz" ]]; 
	then
		echo $(gunzip -c ${file} | md5) ${file},unzippedcontent >>checksums.txt
	fi
  ##add bits for .tar file
done


# Print message indicating completion
echo "md5 checksums generated for all files in $dir and subdirectories, including compressed files"
