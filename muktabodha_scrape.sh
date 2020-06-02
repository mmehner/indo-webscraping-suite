#!/bin/bash

# dependencies: wget, sed

# create directories
mkdir -pv linkcat texts

# get link-lists
wget https://etexts.muktabodha.org/DL_CATALOG_USER_INTERFACE/dl_user_interface_list_catalog_records.php?sort_key=title  -O indexraw
grep -o "<a href=\"dl_user_interface_display_catalog.[^\"]*" indexraw | sed 's_<a href="_https://etexts.muktabodha.org/DL\_CATALOG\_USER\_INTERFACE/_' > index
wget -i index -P linkcat/
grep -o "<a href=dl_user_interface_create_utf8_text.php?.* target=" linkcat/* | sed 's_^.*<a href=\(.*\) target=_https://etexts.muktabodha.org/DL\_CATALOG\_USER\_INTERFACE/\1_' > indexIAST

# download texts
wget -c --random-wait --tries=inf --retry-on-http-error=429 --waitretry=30 -P texts/ -i indexIAST  -nc

# rename
pushd texts/
for i in *;
do
    mv "$i" "$(echo "$i" | sed 's/dl_user_interface_create_utf8_text.php?hk_file_url=..%2FTEXTS%2FETEXTS%2F\(.*\)&miri_catalog_number=\(.*\)/\1_\2.htm/')"
done
popd
