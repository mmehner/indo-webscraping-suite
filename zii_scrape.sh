#!/bin/bash

# dependencies: wget, sed, pdftotext, pdfinfo

# subroutines
## (over)write indices
ziiscrapeindex(){
    # get issue-link-list
    wget http://nbn-resolving.de/urn:nbn:de:gbv:3:5-7081 -O indexraw
    grep -o "/dmg/periodical/structure/[0-9]*" indexraw | sed 's_^_http://menadoc.bibliothek.uni-halle.de_' > index

    # get pdf-link-list
    mkdir -pv issues
    wget -P issues/ -i index -nc
    grep -o "/download/pdf/[0-9]*" issues/* | sed 's_^issues/[0-9]\+:_http://menadoc.bibliothek.uni-halle.de_' | sort | uniq > pdfindex_tmp
    touch pdfindex
    diff --new-line-format="" --unchanged-line-format="" pdfindex_tmp pdfindex > pdfindex_new
    rm pdfindex_tmp
    echo "New entries in pdfindex:"
    cat pdfindex_new
}

## download pdfs
ziiscrapedlpdf(){
    if [ -f pdfindex_new ];
       then
	   mkdir -pv pdf
	   wget --user-agent=Mozilla --random-wait -P pdf/ -i pdfindex_new -nc
	   # when done: cleanup pdfindices
	   cat pdfindex pdfindex_new | sort | uniq > tmpindex
	   mv tmpindex pdfindex
	   rm pdfindex_new
    else
	echo "No new additions since last run; skipping."
    fi
}

## rename pdf, pdftotext, move txt files and cleanup
ziiscrapepostdl(){
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
    rm pdf/*__Zeitschrift-für-Indologie-und-Iranistik.*
    echo "done."
}

# main function
## check when last index was created
if [ -f pdfindex_new ];
then
    read -p "The last run seems to have been aborted, do you want to skip indexing and continue downloading based on the existing index? " yn
    case $yn in
	[Yy]* ) ziiscrapedlpdf ;;
	[Nn]* ) ziiscrapeindex; ziiscrapedlpdf; ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    ziiscrapeindex
    ziiscrapedlpdf
fi
ziiscrapepostdl

exit
