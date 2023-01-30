#!/bin/bash

# dependencies: wget, curl, sed, pdftotext, pdfinfo

# subroutines
## (over)write indices
haspscrapeindex(){
    # get issue-link-list
    wget https://hasp.ub.uni-heidelberg.de/catalog/index?per_page=1000 -O indexraw
    grep -o "/catalog/book/[0-9]*" indexraw | sed 's_^_https://hasp.ub.uni-heidelberg.de_' index
    
    # get pdf-link-list
    mkdir -pv books
    wget -P books/ -i index -nc
    grep -o "/reader/download/[0-9]*/[0-9]*-42-[^\"]*" books/* | sed 's_^books/[0-9]\+:_https://hasp.ub.uni-heidelberg.de_' | sort | uniq > pdfindex_tmp
    touch pdfindex
    diff --new-line-format="" --unchanged-line-format="" pdfindex_tmp pdfindex > pdfindex_new
    rm pdfindex_tmp
    echo "New entries in pdfindex:"
    cat pdfindex_new
}

## download pdfs
haspscrapedlpdf(){
    if [ -f pdfindex_new ];
    then
	mkdir -pv pdf
	wget --user-agent=Mozilla --random-wait -P pdf/ -i pdfindex_new -nc
	# when done: cleanup pdfindices
	cat pdfindex pdfindex_new | sort | uniq > tmpindex
	mv tmpindex pdfindex
	rm pdfindex_new
    else
	echo "No new additions since last run; exiting."
	exit
    fi
}

## rename pdf, pdftotext, move txt files and cleanup
haspscrapepostdl(){
    # extract titles from book-pages
    for i in books/*;
    do
	sed -n '/Empfohlene Zitierweise.*/,/<\/p>/p' ${i} | sed -n '/^\s*[a-zA-Z].*/p' | sed -e 's/^\s*//g' -e 's/  \+/_/g' -e 's/ /-/g' -e 's/[\.,;:'\''\?"\/()&#]//g' -e 's/-Heidelberg--Berlin-CrossAsia-eBooks-//g' | cut -c -120 > ${i}_title
    done

    find books/ -empty -delete

    # rename pdfs
    for i in pdf/[0-9]*;
    do
	mv "${i}" "pdf/$(cat $(echo ${i} | sed -n 's/^pdf\(\/[0-9]*\)-.*/books\/\1_title/p')).pdf"
    done

    # pdftotext pdf
    echo "running pdftotext …"
    for i in pdf/*.pdf; do pdftotext "$i"; done
    mkdir -pv txt
    mv pdf/*.txt txt/
}

# main function
## check when last index was created
if [ -s pdfindex_new ];
then
    read -p "The last run seems to have been aborted, do you want to skip indexing and continue downloading based on the existing index? " yn
    case $yn in
	[Yy]* ) haspscrapedlpdf; haspscrapepostdl ;;
	[Nn]* ) haspcrapeindex; haspscrapedlpdf; haspscrapepostdl ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    haspscrapeindex
    haspscrapedlpdf
    haspscrapepostdl
fi

exit
