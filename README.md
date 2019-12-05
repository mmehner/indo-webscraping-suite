# journal webscraping suite
cumulative download, sensible renaming, and pdftotext for some Indology-related journals

## Dependencies
wget, sed, pdftotext, pdfinfo

## Usage
1. (if applicable) Make sure you are on a network with access to the resource you want to scrape,
2. make sure the script can be executed with `chmod +x /PATH/TO/SCRIPTNAME_scrape.sh`,
3. create a directory for the journal somewhere in your filesystem with `mkdir DIRNAME`,
4. `cd DIRNAME` into this directory,
5. run script with `PATH/TO/SCRIPTNAME_scrape.sh`, if there is already a `pdfindex` in the working directory from a previous run, the script will only download new additions.

## Scripts and corresponding journals
- **zii-scrape.sh** : [Zeitschrift für Indologie und Iranistik](http://nbn-resolving.de/urn:nbn:de:gbv:3:5-7081)
- **zdmg-scrape.sh** : [Zeitschrift der Deutschen Morgenländischen Gesellschaft](http://nbn-resolving.de/urn:nbn:de:gbv:3:5-8179)
- **idgf-scrape.sh** : [Indogermanische Forschungen](https://www.degruyter.com/view/j/indo)