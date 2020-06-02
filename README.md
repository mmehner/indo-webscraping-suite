# journal webscraping suite
cumulative download, sensible renaming, and pdf-to-text for some Indology-related journals

## Dependencies
wget, sed, pdftotext, pdfinfo

## Usage
1. (If applicable) make sure you are on a network with access to the resource you want to scrape,
2. make script executable with `chmod +x /PATH/TO/SCRIPTNAME_scrape.sh`,
3. create a directory for the journal somewhere in your filesystem with `mkdir DIRNAME`,
4. `cd DIRNAME` into this directory,
5. run script with `/PATH/TO/SCRIPTNAME_scrape.sh`; if there is a “pdfindex”-file in the working directory from a previous run, the script will only download new additions. 

## Scripts and corresponding repositories/journals
- **zii-scrape.sh** : [Zeitschrift für Indologie und Iranistik](http://nbn-resolving.de/urn:nbn:de:gbv:3:5-7081)
- **zdmg-scrape.sh** : [Zeitschrift der Deutschen Morgenländischen Gesellschaft](http://nbn-resolving.de/urn:nbn:de:gbv:3:5-8179)
- **idgf-scrape.sh** : [Indogermanische Forschungen](https://www.degruyter.com/view/j/indo)
- **muktabodha_scrape.sh** : [Muktabodha Indological Text Collection and Search Engine](https://etexts.muktabodha.org/DL_CATALOG_USER_INTERFACE/dl_user_interface_frameset.htm)
- **xasia-books_scrape.sh** : [xasia eBooks](https://crossasia-books.ub.uni-heidelberg.de/xasia/catalog/index?per_page=1000)

## Continuing an aborted run
- If the script exits or is cancelled for some reason while downloading pdfs, it will ask you if you wish to continue downloading based on indices that have been written in the previous run. Before that, you should *delete the last pdf file the script attempted to download*, as that will probably be incomplete but would still be recognized as already downloaded.