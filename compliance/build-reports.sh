#!/bin/bash

mkdir -p $1/html

dirs=$(echo $1/*/)
for dirname in $dirs; do
    count=0
    for filename in $dirname*.bzip2; do
        ((count=count + 1))
        if [ -f "$filename" ]; then
            echo "Unzipping $filename"
            xmlfile=${filename%.*}
            bunzip2 -c $filename > $xmlfile
            htmlfilename="${dirname#$1}$count.html"
            htmlfilename=$(echo $htmlfilename | sed 's/\///g')
            echo "Generating $htmlfilename"
            oscap xccdf generate report $xmlfile > $1/html/$htmlfilename
        fi
    done
done
