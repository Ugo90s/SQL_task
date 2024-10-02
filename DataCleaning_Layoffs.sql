-- Data Cleaning
SELECT * 
FROM `world_layoffs`.layoffs
;

-- Remove Duplicates
-- Standardize the Data
-- Check for Null Values or Blank Values
-- Remove Uneeded Rows/Columns (Best practice, create a duplicate for data manipulation and analysis)


-- Staging table for manipulation ie creating duplicate table from original dataset

CREATE TABLE layoffs_staging1
LIKE layoffs;

-- confirm all columns are recreated on staging dataset
SELECT *
FROM layoffs_staging1;

-- Insert data into staging table from original dataset
INSERT layoffs_staging1
SELECT *
FROM layoffs;

-- Removing Duplicates, Since there are no unique IDs to check for duplicates, we'd use Row_Number, over partition to unique count all fields in each row and filter for any count >=2

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised_millions) As row_num
FROM layoffs_staging1;

-- Create cte or use output below as subquery to query for where row_num is greater than 1 

SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,industry,total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging1
)
WHERE row_num > 1;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging1
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


-- since the created "row_num" field (on cte) cannot be used as a condition to delete records in MySQL, a new staging2 table is created with the "row_num" column added
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- confirms new staging(table) is created
SELECT *
FROM layoffs_staging2;

-- Insert values to new table to query for duplicates
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company,industry,total_laid_off, percentage_laid_off, `date`,stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging1;

-- Query Duplicate rows, ensure output is accurate
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Delete Duplicate row
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing data
SELECT company, TRIM(company)
FROM layoffs_staging2;

Update layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
Order by 1;

SELECT DISTINCT Country
FROM layoffs_staging2
Order by 1;

-- Convert date to month/day/year format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2;

-- set datatype for date
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Adding "NULL" is industry entry is empty
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
;

-- Join dataset with itself on company name to find matching industry records
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    WHERE (t1.industry IS NULL OR t1.industry = '')
    AND t2.industry IS NOT NULL;
    
-- Update industry record from NOT NULL industry value matching company name
UPDATE layoff_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

    
 -- Delete data not helpful with key information ( in this case entry without total or percentage laid off)
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Drop uneeded column
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


