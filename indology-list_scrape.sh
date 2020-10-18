#!/bin/bash

# dependencies: curl, wget, sed, w3m

# subroutines
## (over)write indices
indolistscrapeindex(){
    # get month-index
    echo "Fetching month-index"
    curl -s https://list.indology.info/pipermail/indology_list.indology.info/ | \
	grep "/thread.htm" | \
	sed 's_^.*<a href="\(.*\)".*_https://list.indology.info/pipermail/indology\_list.indology.info/\1_I' > monthindex

    # get post-indix
    echo "Fetching post-index, this may take a while"
    > postindex
    for l in $(cat monthindex)
    do
	curl -s ${l} | \
	    grep -i "<li><a href=" |
	    sed -e "s|^.*<a href=\"\(.*\)\".*|${l}/\1|I"  -e 's_/thread.html__g' >> postindex
    done
    
    # diff with archive
    if [ -f dlindex ]
    then
	diff --new-line-format="" --unchanged-line-format="" postindex dlindex  > postindex_new
    else
	cp postindex postindex_new
    fi
}

## view posts with w3m, save (thus converting char encoding) and delete replies
indolistscrapeposts(){
    if [ -s postindex_new ];
    then
	mkdir -pv posts/
	for l in $(cat postindex_new)
	do
	    echo "Fetching ${l}"
	    w3m ${l} | sed '/^>/d' > posts/$(echo ${l} | sed -e 's_^.*\.info/\(.*\)\.html_\1_I' -e 's|/|_|g' )
	done
	rm postindex_new
	mv postindex dlindex
    else
	echo "No new additions since last run; exiting."
	exit
    fi
}

# main function
## check when last index was created
if [ -f postindex_new ];
then
    read -p "The last run seems to have been aborted, do you want to skip indexing and continue downloading based on the existing index? " yn
    case $yn in
	[Yy]* ) indolistscrapeposts ;;
	[Nn]* ) indolistscrapeindex; indolistscrapeposts ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    indolistscrapeindex
    indolistscrapeposts
fi

exit
