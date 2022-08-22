## Data

* [minifigs_data.csv](https://github.com/rporta23/WBI/blob/main/data/minifigs_data.csv)
    is a dataset containing information about all minifigs on BrickLink
    as of May 2022.

<b>Dimensions:</b> 14,217 rows (one row = one minifig), 4 columns

<b>Variables</b>
  * <i>item_number</i> (BrickLink item number)
  * <i>description</i> (BrickLink item description)
  * <i>category</i> (BrickLink broad category-- does not include subcategories)
  * <i>item_link</i> (link to item on BrickLink)

<b>Script used to create it</b>:
[minifigs_scraping.Rmd](https://github.com/rporta23/WBI/blob/main/minifigs/minifigs_scraping.Rmd)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogTree.asp?itemType=M)

<b>Notes</b>: This dataset is very useful for any analyses related to
minifigs. I would recommend updating it every year to keep it current if
possible. The process for creating it was a bit convoluted because of
BrickLink's quotas for scraping, but may be easier to update if you can
avoid scraping everything from scratch again.

* [categories.csv](https://github.com/rporta23/WBI/blob/main/data/categories.csv) is an intermediary dataset used in the process of creating
    [minifigs_data.csv](https://github.com/rporta23/WBI/blob/main/data/minifigs_data.csv).
    It contains the links to each individual page of each minifig
    category on BrickLink.

<b>Dimensions:</b> 325 rows (one row = one page of one category), 4
columns

<b>Variables</b>
  * <i>..1</i> (row id, not super relevant)
  * <i>category</i> (BrickLink broad category-- does not include subcategories)
  * <i>link</i> (link to one page of a category)
  * <i>num_pages</i> (total number of pages in category)

<b>Script used to create it</b>:
[minifigs_scraping.Rmd](https://github.com/rporta23/WBI/blob/main/minifigs/minifigs_scraping.Rmd)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogTree.asp?itemType=M)

<b>Notes</b>: I never used this directly for analysis, but useful as an
intermediary to scrape minifig data.

* [category_counts.csv](https://github.com/rporta23/WBI/blob/main/data/category_counts.csv)
    is an intermediary dataset used in the process of creating
    [minifigs_data.csv](https://github.com/rporta23/WBI/blob/main/data/minifigs_data.csv).
    It contains information about each broad minifig category on
    BrickLink.

<b>Dimensions:</b> 108 rows (one row = one category), 5 columns

<b>Variables</b>
  * <i>..1</i> (row id, not super relevant) 
  * <i>category</i> (BrickLink broad category-- does not include subcategories)
  * <i>num_pages</i> (total number of pages in category)
  * <i>num_figs</i> (total number of minifigs in category)
  * <i>link</i> (link to first page of category)

<b>Script used to create it</b>:
[minifigs_scraping.Rmd](https://github.com/rporta23/WBI/blob/main/minifigs/minifigs_scraping.Rmd)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogTree.asp?itemType=M)

<b>Notes</b>: I never used this directly for analysis, but useful as an
intermediary to scrape minifig data.
