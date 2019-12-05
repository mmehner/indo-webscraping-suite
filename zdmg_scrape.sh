#!/bin/bash

# dependencies: wget, sed, pdftotext, pdfinfo

# subroutines
## (over)write indices
zdmgscrapeindex(){
    # get issue-link-list
    wget http://nbn-resolving.de/urn:nbn:de:gbv:3:5-8179 -O indexraw
    grep -o "/dmg/periodical/structure/[0-9]*" indexraw | sed 's_^_http://menadoc.bibliothek.uni-halle.de_' > index
    
    # get pdf-link-list
    mkdir -pv issues
    wget -P issues/ -i index -nc
    grep -o "/download/pdf/[0-9]*" issues/* | sed 's_^issues/[0-9]\+:_http://menadoc.bibliothek.uni-halle.de_' >> pdfindex
    sort pdfindex | uniq -u > pdfindex_new
    echo "New entries in pdfindex:"
    cat pdfindex_new
}

## download pdfs
zdmgscrapedlpdf(){
    if [ -f pdfindex_new ];
       then
	   mkdir -pv pdf
	   wget --user-agent=Mozilla --random-wait -P pdf/ -i pdfindex_new -nc
	   # when done: cleanup pdfindices
	   rm pdfindex_new
	   sort pdfindex | uniq > tmpindex
	   mv tmpindex pdfindex
    else
	echo "No new additions since last run; exiting."
	exit
    fi
}

## rename pdf, pdftotext, move txt files and cleanup
zdmgscrapepostdl(){
    # rename pdfs
    for i in pdf/*{0..9};
    do
	mv "$i" "${i}"_"$(pdfinfo "$i" | sed -n 's/^Author:\s*\([^,\. ]*\).*/\1/p')"_"$(pdfinfo "$i" | sed -n 's/^Title:\s*\(.*\)/\1/p' | sed -e 's/ /-/g' -e 's/[\.,;:'\''\?"\/()]//g')".pdf;
    done

    # pdftotext pdf
    echo "running pdftotext …"
    for i in pdf/*.pdf; do pdftotext "$i"; done
    mkdir -pv txt
    mv pdf/*.txt txt/

    #cleanup
    echo "cleaning up …"
    rm pdf/*_Zeitschrift-der-Deutschen-Morgenländischen-Gesellschaft.*
    echo "done."
}

# main function
## check when last index was created
if [ "$(date -r pdfindex +"%Y-%m-%d")" = "$(date +"%Y-%m-%d")" ];
then
    read -p "Last pdfindex was created today, do you want to skip indexing and continue downloading based on the existing index? " yn
    case $yn in
	[Yy]* ) zdmgscrapedlpdf ;;
	[Nn]* ) zdmgscrapeindex; zdmgscrapedlpdf; ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    zdmgscrapeindex
    zdmgscrapedlpdf
fi
zdmgscrapepostdl

exit
