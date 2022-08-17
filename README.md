# WBI
Repository to host code relating to my work with the [Women's Brick Initiative](https://womensbrickinitiative.com/) Summer 2022

The Women's Brick Initiative Advocates for diversity, equity, and inclusion within LEGO products. My work as an intern in summer 2022 included conducting research on various aspects of diversity and representation in LEGO products, especially [minifigures](https://en.wikipedia.org/wiki/Lego_minifigure), and writing blog posts to share our findings that will soon be posted on the WBI [website](https://womensbrickinitiative.com/). This work will also be shared with the broader LEGO community and with representatives from The LEGO Group in order to highlight opportunities for improvement and advocate for broader representation. 

This repository contains all of the data used in our analyses as well as the R code used to wrangle and visualize the data. There are several different sub-projects within this repository, which I will outline below.

## Contributers (WBI Interns Summer 2022)

- [Rose Porta](https://www.linkedin.com/in/rose-porta-40ba7719a/)
- [Yutong Zhang](https://www.linkedin.com/in/yutong-zhang-a557b1196/)
- [Kira Seshaiah](https://www.linkedin.com/in/kira-seshaiah-120835229/)

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

#### Data

The data is in [data/starwars](https://github.com/rporta23/WBI/tree/main/data/starwars). The screentime data is sourced from [IMDB](https://www.imdb.com/list/ls027631145/), and the minifig data is sourced from the [Star Wars](https://www.bricklink.com/catalogList.asp?catType=M&catString=65) minifigure category in BrickLink. The gender and species data were filled in manually. 

#### Articles

- Are Star Wars Minifigs Accurately Representative of Star Wars Films? An analysis of screen time versus number of minifigs by gender (Part 1: Main Films)

#### [Interactive Shiny App](https://rporta.shinyapps.io/starwars_minifigs/)

#### Code

The code is in [minifigs/starwars](https://github.com/rporta23/WBI/tree/main/minifigs/starwars)

### Analysis of Head Repetition in Star Wars Characters

We conducted an analysis on the frequency of minifig head reuse for several of the main Star Wars characters. We found that the female characters generally had less variety in heads, and heads of female characters were more frequently used for other characters (inside or outside of Star Wars). Although this analysis was only done on a few characters and we cannot draw broad conclusions, it seems that LEGO is less willing to invest in female characters. 

We also conducted a broader analysis on head overlap between Star Wars, Jurassic World, and MCU characters.

#### Data

The data is sourced from the [Star Wars](https://www.bricklink.com/catalogList.asp?catType=M&catString=65) minifigure category in BrickLink.

#### Articles

- Do Princess Leia and Captain Marvel Look Alike? Repetition of Minifig Heads in Star Wars Characters (Part 1)
- The Intersection of Star Wars, Jurassic World, and the MCU: A Head Study (Part 2)

#### Code

The code is in [minifigs/head_repetition/starwars_head_repetition.R](https://github.com/rporta23/WBI/blob/main/minifigs/head_repetition/starwars_head_repetition.R). 

### Analysis of Neutral Minifig Heads

We conducted an analysis on the gender distributions of minifigs which have "neutral" heads, meaning the head is not explicitly identified as male or female. We started with all neutral heads from minifigs in the Town category released between 2017-2022 and from there, looked at the genders of the minifigs for which each head was used (each head was used for multiple minifigs). We found that most of these heads are used for about half male minifigs and half neutral minifigs, while only a few are used for female minifigs. Of the ones used for female minifigs, they tended to be used only for female minifigs only a small percentage of the time, or a very large percentage of the time, but not in between. These findings imply that "neutral" heads are not truly being used for all genders equally, and instead are used for male minifigs more often than female minifigs. 

#### Data

The data is in [data/town/town_parts_2017-2022.csv](https://github.com/rporta23/WBI/blob/main/data/town/town_parts_2017-2022.csv) and is sourced from the [Town](https://www.bricklink.com/catalogList.asp?catType=M&catString=67) Minifigure category on BrickLink. 

#### Articles

- Are Neutral Minifigure Heads Really Gender Neutral?

#### Code

The code is in [minifigs/neutral_heads.R](https://github.com/rporta23/WBI/blob/main/minifigs/neutral_heads.R).

### Analysis of Cultural Representation in Minifigs

We conducted an analysis of which cultures have been represented, how they have been represented, and how representation has changed over time in LEGO minifigs. We found that most regions of the world are very under-represented in minifigs, and there are many opportunities for improvement in respectfully representing the diverse population of the world. 

#### Data 

The data is in [data/cultural](https://github.com/rporta23/WBI/tree/main/data/cultural) and is sourced from a variety of categories within the [Minifigure](https://www.bricklink.com/catalogTree.asp?itemType=M) section on BrickLink.

#### Articles

- How Well Do Minifigs Represent People from Around the World? Analysis of Cultural Representation in Minifigs (Part 1: Overview)
- How Well Do Minifigs Represent People from Around the World? Analysis of Cultural Representation in Minifigs (Part 2: Head Repetition)

#### Code 

The code is in [minifigs/cultural](https://github.com/rporta23/WBI/tree/main/minifigs/cultural)

### Analysis of Gender, Age, and Flesh Tone Color Diversity in Minifig Heads Over Time

We conducted an analysis of gender, age, and flesh tone color diversity for all available minifigure heads on BrickLink. We found that there are by far the most options for heads representing white, young adult males and very few options for (especially child or older adult) women and non-binary folks of color. Consistent with our LUGBULK analysis, diversity of flesh tone colors has improved some but not much over time, yet gender equity has improved significantly. 

#### Data 

The data is in [data/flowchart_data_2022_corrected.csv](https://github.com/rporta23/WBI/blob/main/data/flowchart_data_2022_corrected.csv) and is sourced from the [Minifigure, Head](https://www.bricklink.com/catalogList.asp?catType=P&catString=238) category of the Parts section on BrickLink. 

#### Articles

- Thousands of Minifig Heads, and Still Not Enough Options? Analysis of Diverse Representation in Minifigure Heads (Part 1)
- Thousands of Minifig Heads, and Still Not Enough Options? Analysis of Diverse Representation in Minifigure Heads (Part 2)

#### Code 

The code is in [flowchart_update/heads_2022.R](https://github.com/rporta23/WBI/blob/main/flowchart_update/heads_2022.R)


