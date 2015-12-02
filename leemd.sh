#!/usr/bin/bash.exe

if [ $# -lt 1 ]; then
	echo This script requires a file name.
	exit
fi

for file in "$@"; do
	if [ -e "$file" ]; then
		if [ ! ${file: -4} == ".csv" ]; then
			echo File must be a CSV.
		else
			if [ ! "${file:0:1}" == "/" ]; then
				file="$PWD/$file"
			fi
			cd "/cygdrive/c/Documents and Settings/pos/Desktop/Website/BJ/Git/LeeMd/lib/"
			ruby './leemd.rb' "$file"
		fi
	else
		echo "$file" does not exist in this location.
	fi
done
