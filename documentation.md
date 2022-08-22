# Documentation for WBI Summer 2022

The purpose of this document is to help future interns navigate this repository and build off of the work that we did this summer. It outlines the contents of all data in the repository as well as the data collection process and some other useful info to know. 

With any questions, contact rosecporta@icloud.com](mailto:rosecporta@icloud.com).

## Functions

[wbi_colors.R](https://github.com/rporta23/WBI/blob/main/wbi_colors.R) contains several useful functions for customizing graphs to WBI work. 

* Functions to customize ggplot colors to WBI pink, lime, orange, and grey. All functions below can be added to a ggplot as a layer.
 * <i>scale_fill_wbi()</i> customizes fill colors-- use for bar plots, box plots, or any other plot type with fill colors
 * <i>scale_color_wbi()</i> customizes point/line colors-- use for scatter plots, line graphs, or any other plot type with fill colors
 * <i>scale_y_continuous_wbi()</i> creates a gradient color scale from WBI lime to WBI pink-- use when you have a continuous value where you want color to represent value (i.e. smaller values would be more green, larger values would be more pink)

* Functions to customize ggplot colors to LEGO flesh tone colors. All functions below can be added to a ggplot as a layer.
  * <i>scale_fill_skintones()</i> customizes fill colors-- use for bar plots, box plots, or any other plot type with fill colors
  * <i>scale_color_skintones()</i> customizes point/line colors-- use for scatter plots, line graphs, or any other plot type with fill colors

* <i>add_logo</i> adds the two WBI logos ([socials.png](https://github.com/rporta23/WBI/blob/main/socials.png) and [logo.png](https://github.com/rporta23/WBI/blob/main/logo.png)) to the bottom left and bottom right corners of a ggplot, respectively. This function can be added as a layer to a ggplot. 

## General Data Collection Process

Most of the data in this repository has been scraped from [BrickLink](https://www.bricklink.com/v2/main.page) using the [rvest](https://rvest.tidyverse.org/) R package. If you are not familiar with this process, you can learn the basics with this [tutorial](https://www.analyticsvidhya.com/blog/2017/03/beginners-guide-on-web-scraping-in-r-using-rvest-with-hands-on-knowledge/). 

Most of the time, this method will be fairly simple and will make data collection quick and efficient. If you are trying to scrape a lot of information at once, don't be surprised if the code takes up to an hour or two to run. Also, it is helpful to be aware of BrickLink quota limits-- for certain types of scraping, it will only let you pull data from a certain number of pages at a time. If after you run the scraping code, you notice that a bunch of values at the end are missing, you have probably reached the quota limit, and you may have to split up the data into smaller chunks to scrape them separately, then combine them all back together at the end. If you wait a few hours, the quota limit will re-set. 

## Data

### [minifigs_data.csv](https://github.com/rporta23/WBI/blob/main/data/minifigs_data.csv) 

Dataset containing information about all minifigs on BrickLink as of May 2022

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

Intermediary dataset used in the process of creating
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

Intermediary dataset used in the process of creating
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

Sub-folder containing data related to minifigs in the Town theme. This theme is useful for analysis because all minifigs are meant to be humans and not other types of creatures. 

#### [town_minifig.csv](https://github.com/rporta23/WBI/blob/main/data/town/town_minifig.csv)

Subset of [minifigs_data.csv](https://github.com/rporta23/WBI/blob/main/data/minifigs_data.csv) filtered to only the Town category. Also contains release year information for each minifig.

#### [town_parts_2017-2022.csv](https://github.com/rporta23/WBI/blob/main/data/town/town_parts_2017-2022.csv)

Dataset containing information about each individual part of each minifig in the Town category between the years 2017-2022.

<b>Dimensions:</b> 3945 rows (one row = one part), 8 columns

<b>Variables</b>
  * <i>item_number</i> (BrickLink part id for minifig containing part) 
  * <i>description</i> (BrickLink item description for minifig containing part)
  * <i>category</i> (BrickLink broad category-- somewhat trivial because it is Town for all of them)
  * <i>item_link</i> (link to minifig containing part on BrickLink)
  * <i>parts_link</i> (link to part on BrickLink)
  * <i>release_year</i> (first year released)
  * <i>parts_id</i> (BrickLink part id)
  * <i>parts_description</i> (BrickLink item description)

<b>Script used to create it</b>:
[female_heads_recent.R](https://github.com/rporta23/WBI/blob/main/minifigs/head_repetition/female_heads_recent.R)

<b>Source</b>:
[BrickLink](https://www.bricklink.com/catalogTree.asp?itemType=M)

#### [sets_data_3626bp02.csv](https://github.com/rporta23/WBI/blob/main/data/town/sets_data_3626bp02.csv)

Dataset containing minifig part information for one piece of the head repetition analysis. For more information, contact [rosecporta@icloud.com](mailto:rosecporta@icloud.com). 
