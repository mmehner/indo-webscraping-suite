#!/bin/bash

# dependencies: wget, sed, weasyprint

_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# subroutines
## write indices
getidx(){
    # get issue-link-list
    wget http://digitalhumanities.org/dhq/index/title.html -O - | \
	grep -o "dhq/vol/[0-9/]*.html" | \
	sed -e 's_html$_xml_' -e 's_^_http://digitalhumanities.org/_' | \
	sort > xmlindex
    }

## download 
getdata(){
    # diff with archive
    if [ -f dlindex ]
    then
	diff --new-line-format="" --unchanged-line-format="" xmlindex dlindex > xmlindex_new
	echo "debug"
    else
	cp xmlindex xmlindex_new
    fi
    
    mkdir -pv xml
    mkdir -pv pdf
    while IFS= read -r l
    do
	fn="${l##*/}"
	
	echo "Downloading ${fn}"
	wget --user-agent=Mozilla --random-wait -P xml/ -nc -c "${l}"

	if grep -q "</TEI>" xml/"${fn}"
	then
	    nfn="$(xsltproc "${_dir}"/xslt/dhq-tei-filename.xsl xml/"${fn}" | \
	    sed -e 's_\s\+_-_g' \
		-e "s_[:,;–\.?\!'\"()/\\„“‚‘“”‘’]__g" \
		-e 's_[A-Z]_\L&_g' \
		-e 's_-\+_-_g' )"

	    # download or print pdf
	    if wget "${l%.*}.html" -q -O - | grep -q "${fn%.*}.pdf"
	    then
		echo "Found pdf, downloading …"
		wget --user-agent=Mozilla --random-wait -nc -c "${l%.*}.pdf" -O "pdf/${nfn}".pdf
	    else
		echo "Printing to pdf …"
		weasyprint "${l%.*}.html#" "pdf/${nfn}.pdf"
	    fi

	    echo "Renaming to ${nfn}"
	    mv xml/"${fn}" xml/"${nfn}".xml

	    echo "${l}" >> dlindex
	fi
    done < xmlindex_new
    rm xmlindex_new xmlindex
}

# main function
## check when last index was created
if [ -f xmlindex_new ];
then
    read -rp "The last run seems to have been aborted, do you want to skip indexing and continue downloading based on the existing index? " yn
    case $yn in
	[Yy]* ) getdata ;;
	[Nn]* ) getidx; getdata ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    getidx
    getdata
fi


exit
