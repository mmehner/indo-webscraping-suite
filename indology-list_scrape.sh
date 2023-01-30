#!/bin/bash

# dependencies: curl, wget, sed, w3m

# subroutines
## (over)write indices
getidx(){
    # get month-index
    echo "Fetching month-index"
    curl -s https://list.indology.info/pipermail/indology/ | \
	grep "/thread.htm" | \
	sed 's_^.*<a href="\(.*\)".*_https://list.indology.info/pipermail/indology/\1_I' > monthindex

    # get post-indix
    echo "Fetching post-index, this may take a while"
    > postindex
    for l in $(cat monthindex)
    do
	curl -s ${l} | \
	    grep -i "<li><a href=" |
	    sed -e "s|^.*<a href=\"\(.*\)\".*|${l}/\1|I"  -e 's_/thread.html__g' >> postindex
    done
}

getdata(){
    # diff with archive
    sort -o postindex postindex
    
    if [ -f dlindex ]
    then
	sort -o dlindex dlindex
	diff --new-line-format="" --unchanged-line-format="" postindex dlindex  > postindex_new
    else
	cp postindex postindex_new
    fi

    ## view posts with w3m, save (thus converting char encoding) and delete replies
    if [ -s postindex_new ];
    then
	mkdir -pv posts/
	while IFS= read -r l
	do
	    echo "Fetching ${l}"
	    w3m ${l} | sed '/^>/d' > posts/$(echo ${l} | sed -e 's_^.*\.info/pipermail/indology/\(.*\)\.html_\1_I' -e 's|/|_|g' )
	    echo "${l}" >> dlindex
	done < postindex_new
	rm postindex_new postindex
    else
	rm postindex_new
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
	[Yy]* ) getdata ;;
	[Nn]* ) getidx; getdata ;;
	* ) echo "Please answer y[es] or n[o]."; exit ;;
    esac
else
    getidx
    getdata
fi

exit
