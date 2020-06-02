#!/bin/bash

# dependencies: wget, sed, pdftotext

# subroutines
## (over)write indices
idgfscrapeindex(){
    # get issue-link-list
    wget https://www.degruyter.com/view/j/indo -O indexraw
    grep -o "/view/j/indo\.[^\"]\+" indexraw | sed 's_^_https://www.degruyter.com_' | sort | uniq > index

    # get pdf-link-list
    mkdir -pv issues
    wget -P issues/ -i index -nc
    grep -o "/downloadpdf/[^\"]\+" issues/* | sed -e 's_^issues/.\+\.xml:_https://www.degruyter.com_' -e 's_xml$_pdf_' | sort | uniq > pdfindex_tmp
    touch pdfindex
    diff --new-line-format="" --unchanged-line-format="" pdfindex_tmp pdfindex > pdfindex_new
    rm pdfindex_tmp
    echo "New entries in pdfindex:"
    cat pdfindex_new
}

## download pdfs
idgfscrapedlpdf(){
    if [ -f pdfindex_new ];
       then
	   mkdir -pv pdf
	   wget -c --random-wait --tries=inf --retry-on-http-error=429 --waitretry=30 -P pdf/ -i pdfindex_new  -nc
	   # when done: cleanup pdfindices
	   cat pdfindex pdfindex_new | sort | uniq > tmpindex
	   mv tmpindex pdfindex
	   rm pdfindex_new
    else
	echo "No new additions since last run; exiting."
	exit
    fi
}

## rename pdfs, pdftotext, move txt files and cleanup
idgfscrapepostdl(){
    # rename to idgf_year-issue_page.pdf
    pushd pdf/
    for i in *;
    do mv "$i" "$(grep -o "^.*$i" ../pdfindex | sed 's_^.*/j/indo\.\([0-9]\+\)\.\([0-9]\+\).\+[-\.]\([0-9a-z]\+\.pdf\)$_idgf\_\1-\2\_\3_')";
    done
    popd
   
    # pdftotext pdf
    echo "running pdftotext …"
    for i in pdf/*.pdf; do pdftotext "$i"; done
    mkdir -pv txt
    mv pdf/*.txt txt/
}

# main function
## check when last index was created
if [ -f pdfindex_new ];
then
    read -p "The last run seems to have been aborted, do you want to skip indexing and continue downloading based on the existing index? " yn
    case $yn in
	[Yy]* ) idgfscrapedlpdf ;;
	[Nn]* ) idgfscrapeindex; idgfscrapedlpdf; ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    idgfscrapeindex
    idgfscrapedlpdf
fi
idgfscrapepostdl

exit
