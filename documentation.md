## Data

### [minifigs_data.csv](https://github.com/rporta23/WBI/blob/main/data/minifigs_data.csv) 

dataset containing information about all minifigs on BrickLink as of May 2022

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

### [categories.csv](https://github.com/rporta23/WBI/blob/main/data/categories.csv)

an intermediary dataset used in the process of creating
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

### [category_counts.csv](https://github.com/rporta23/WBI/blob/main/data/category_counts.csv)

an intermediary dataset used in the process of creating
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

### [flowchart](https://github.com/rporta23/WBI/tree/main/data/flowchart)

Folder containing data for the 2022 head flowchart. 

#### [flowchart_data_2022_corrected.csv](https://github.com/rporta23/WBI/tree/main/data/flowchart/flowchart_data_2022_corrected.csv) 

Dataset containing all head options up to summer 2022.

<b>Dimensions:</b> 3300 rows (one row = one expression), 8 columns

<b>Variables</b>
  * <i>image</i> (placeholder column to insert images in google sheets) 
  * <i>item_numbery</i> (BrickLink item number)
  * <i>color_code</i> (BrickLink color code)
  * <i>description</i> (BrickLink description)
  * <i>color</i> (BrickLink color)
  * <i>gender</i> (gender-- male, female, or neutral)
  * <i>age</i> (age-- child, young adult, or older adult)
  * <i>emotion</i> (emotion-- happy, sad, sleepy, scared, evil, angry, smirk, annoyed, surprised, or neutral)

<b>Script used to create it</b>:
[heads_2022.R](https://github.com/rporta23/WBI/blob/main/flowchart_update/heads_2022.R)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogList.asp?catType=P&catString=238)

<b>Notes</b>: More info on how to use and update this in the [flowchart update guide](https://rporta23.github.io/WBI/flowchart_update/update_guide.html)

#### flowchart_counts

Sub-folder containing aggregated flowchart counts for each gender-age category separately. There are nine csv files, one for each category. More info in the [flowchart update guide](https://rporta23.github.io/WBI/flowchart_update/update_guide.html). 

#### flowchart_options

Sub-folder containing flowchart options for each gender-age category separately. There are nine csv files, one for each category. More info in the [flowchart update guide](https://rporta23.github.io/WBI/flowchart_update/update_guide.html).

### Cultural

Folder containing data for analysis of cultural representation in minifigs

#### [cultural_minifigs.csv](https://github.com/rporta23/WBI/blob/main/data/cultural/cultural_minifigs.csv)

Dataset containing information about minifigs representing specific cultures.

<b>Dimensions:</b> 685 rows (one row = one minifig), 13 columns

<b>Variables</b>
  * <i>image</i> (placeholder column to insert images in google sheets) 
  * <i>item_number</i> (BrickLink item number)
  * <i>description</i> (BrickLink description)
  * <i>culture_represented</i> (culture of minifig)
  * <i>set_id</i> (list of all BrickLink set ids where minifig appears in the set)
  * <i>set_description</i> (list of all BrickLink set descriptions where minifig appears in the set)
  * <i>category</i> (specific BrickLink category, including subcategory, or minifig)
  * <i>gender</i> (gender-- male, female, or neutral)
  * <i>year</i> (range of release years)
  * <i>inspiration</i> (TV show, film, series, etc. that inspired the minifig if applicable)
  * <i>link</i> (link to minifig on BrickLink)
  * <i>release_year</i> (first year released-- allows year to be used as a numeric variable which is not possible with a range of years)
  * <i>region</i> (broad geographic region that the minifig represents)

<b>Script used to create it</b>:
[cultural.R](https://github.com/rporta23/WBI/blob/main/minifigs/cultural/cultural.R)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogTree.asp?itemType=M)

#### [ninjago_repetition.csv](https://github.com/rporta23/WBI/blob/main/data/cultural/ninjago_repetition.csv)

A dataset containing information about heads of ninjago minifigs and how frequently they were reused inside and outside of the Ninjago theme.

<b>Dimensions:</b> 164 rows (one row = one unique head), 9 columns

<b>Variables</b>
  * <i>parts_id</i> (BrickLink part id) 
  * <i>count</i> (number of times the head has been used within Ninjago theme)
  * <i>head_link</i> (link to part on BrickLink)
  * <i>num_minifigs</i> (total number of times the head has been used)
  * <i>type</i> (gender-- male, female, or neutral)
  * <i>num_outside</i> (number of times the head has been used outside of Ninjago theme)
  * <i>perc_not</i> (percentage of minifigs outside of Ninjago that use the head-- out of total minifigs with the head)
  * <i>has_outside</i> (boolean indicating whether or not head has been used outside of Ninjago theme)
  * <i>minifigs_link</i> (link to page listing all minifigs using the head

<b>Script used to create it</b>:
[cultural_head_repetition.R](https://github.com/rporta23/WBI/blob/main/minifigs/cultural/cultural_head_repetition.R)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogTree.asp?itemType=M)

### starwars

Sub-folder containing data relating to analysis of screen time versus number of minifigs for Star Wars characters. For more information about individual files, contact [rosecporta@icloud.com](mailto:rosecporta@icloud.com)

### town
