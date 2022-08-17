# WBI
Repository to host code relating to my work with the [Women's Brick Initiative](https://womensbrickinitiative.com/) Summer 2022

The Women's Brick Initiative Advocates for diversity, equity, and inclusion within LEGO products. My work as an intern in summer 2022 included conducting research on various aspects of diversity and representation in LEGO products, especially [minifigures](https://en.wikipedia.org/wiki/Lego_minifigure), and writing blog posts to share our findings that will soon be posted on the WBI [website](https://womensbrickinitiative.com/). This work will also be shared with the broader LEGO community and with representatives from The LEGO Group in order to highlight opportunities for improvement and advocate for broader representation. 

This repository contains all of the data used in our analyses as well as the R code used to wrangle and visualize the data. There are several different sub-projects within this repository, which I will outline below.

## Projects

### Analysis of Gender and Flesh Tone Equity in LUGBULK parts

LUGBULK is a system through which Recognized Lego Communities (commonly known as LUGS), which are groups of LEGO fans who generally assemble in the same geographic region, have the opportunity to purchase LEGO parts in bulk yearly. Because the parts are purchased in bulk, they are less expensive than they would be to purchase individually. Many of the parts available are minifigure parts, including hair, heads, torsos, legs, and accessories.

#### Data

Since WBI is a Recognized LEGO Community, we had access to information about all of the available parts for each year from 2015-2022. The data for this project is not included in the repository, as it is not publicly available. 

#### Articles

- Is LEGO Putting a Price on Diversity? An exploration of LUGBULK, where cheap LEGOs are bought in bulk (Part 1: Minifig Heads)

We conducted an analysis on gender equity and flesh tone diversity in minifig heads available and how this has changed over time from 2015-2022. We found that flesh tone diversity has improved somewhat but not much, yet gender diversity has improved significantly such that the percentages of male, female, and neutral heads are almost exactly equal in 2022. 

- Is LEGO Putting a Price on Diversity? An exploration of LUGBULK, where cheap LEGOs are bought in bulk (Part 2: Minifig Wigs)

We conducted an analysis comparing the number of female wigs to the number of male wigs available as well as comparing the price distributions for female versus male wigs in 2022. We found that the number of wigs was fairly gender-equitable, yet female wigs were surprisingly more expensive than male wigs.

#### Code
The code relating to this project is in [lugbulk_parts](https://github.com/rporta23/WBI/tree/main/lugbulk_parts)

### Analysis of Representation in Professions

We conducted an analysis on the distribution of male-female-neutral minifigs within nine of the most common professions in the LEGO Town theme, as well as how these distributions have changed over time and how the representation of females within these professions has changed over time. We found that females tend to be under-represented in most professions, and many common professions are not represented at all.

#### Data

The data is in [data/town](https://github.com/rporta23/WBI/tree/main/data/town) and is sourced from the [Town](https://www.bricklink.com/catalogList.asp?catType=M&catString=67) Minifigure category on BrickLink.

#### Articles

- How Does LEGO See Working Women? Analysis of Gender Representation in Professions

#### Code

The code is in [minifigs/professions.Rmd](https://github.com/rporta23/WBI/blob/main/minifigs/professions.Rmd)

### Analysis of Head Repetition in Minifigures

When LEGO creates new minifigure designs, they often reuse the same head design for multiple different minifigures. This analysis compares the frequency of head reuse by gender for minifigs within the Town category. The first part focuses on a specific female head used most around the late 1990s-early 2000s and compares it to frequency of reuse for male heads released in the same sets. The second part looks at the most frequently used heads for all genders within the past 5 years (2017-2022). We found that female heads tend to be reused much more frequently than male or neutral heads, which implies that LEGO is less willing to invest female minifigs.

#### Data

The two datasets used are [data/town/sets_data_3626bp02.csv](https://github.com/rporta23/WBI/blob/main/data/town/sets_data_3626bp02.csv) and [data/town/town_parts_2017-2022.csv](https://github.com/rporta23/WBI/blob/main/data/town/town_parts_2017-2022.csv). The data is sourced from the [Town](https://www.bricklink.com/catalogList.asp?catType=M&catString=67) Minifigure category on BrickLink.

#### Articles

- How often does LEGO use the same head on a minifigure? Analysis of Head Repetition Part 1
- How Many Female Minifigs in LEGO Town Have the Same Face? Analysis of Head Repetition Part 2 (2017-2022)

#### Code

The code is in [minifigs/head_repetition](https://github.com/rporta23/WBI/tree/main/minifigs/head_repetition)

### Analysis of the Relationship between Screen Time, Gender and Number of Minifigs for Star Wars Characters

Star Wars is a major theme that inspires LEGO sets, and LEGO has created over 1000 Star Wars minifigs since 1999. We conducted an analysis of the relationship between screen time, gender and number of minifigs for Star Wars characters in order to investigate how representative LEGO minifigs are of the Star Wars films. Star Wars is already a very male-dominated series, so it makes sense that there are more male minifigs, but are the gender proportions equal when comparing characters in the films to their minifigs? We used screen time as a proxy for prominence of a character and analyzed the trend in the number of minifigures produced as screen time increases. We found that in general, the more screen time a character has, the more minifigs they have, but there are a few interesting exceptions. We also found that the positive relationship between screentime and number of minifigs is much weaker for female characters, i.e., as screen time increases, number of minifigs stays relatively low. Furthermore, the gender distribution for Star Wars minifigs is even more disproportionately skewed towards males than are the films themselves. 

