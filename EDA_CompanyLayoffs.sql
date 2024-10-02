SELECT * FROM `world_layoffs`.layoffs;

-- Exploratory Data Analysis

-- Show max number of layoff done by a company and max percentage of a company that have been let go at once
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- shows companies with high funds raised but laid 100% of its employee
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- To Showcase company stage with most layoff
SELECT stage, Sum(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_off DESC;

-- Timeline of the dataset
SELECT MAX(`date`), MIN(`date`)
FROM layoffs_staging2;

-- total number of layoffs each month in a year
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)AS total_off
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- CREATE Rolling total cte to view layoff total over time

WITH Rolling_total AS (
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC)
SELECT `MONTH`, total_off,SUM(total_off) OVER(ORDER BY `MONTH`)AS rolling_total
FROM Rolling_total;

-- View total layoffs for each company by year
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_off DESC;

-- Ranking company layoff count, showcasing top 5 companies with highest layoff each year

WITH Company_Year (company, years, total_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_off DESC) AS Ranking
FROM Company_Year
)
SELECT *
FROM Company_Rank
WHERE Ranking <=5;


