# SQL_world_layoff_EDA
World company layoff exploratory data analysis from March 2020 to March 2023

Software tool used; MySQL Workbench


## Data Overview & Insight

Over 2,000 records of world layoffs that have taken place over a period of 3 years was explored to find insights and discover any trends amongst company layoff.

Some insight found includes;
- The most number of layoffs seem to have happened in 2022
- Uber had the most number of layoffs in 2020, over 7,000 empoyees
- Majority of layoffs took place with companies that are already post-IPO
- The "Consumer" and "Retail" industry saw more layoffs within this 3 years
- The max number of employees laid off at once was about 18,000
- Per country, United States saw the most number of layoffs within this 3 year dataset, followed by India



## Challenges

- Issues with importing all rows of data at once into MySQL workbench, this was solved by transforming the date format to accepted SQL format (YYYY-MM-DD) first on excel
- Use of window functions and additional column to identify duplicates since dataset had no unique ID
