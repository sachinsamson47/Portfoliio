/*
Covid 19 Data Exploration - Looking at the effect of covid on smokers
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
SELECT *
FROM   data
WHERE  continent IS NOT NULL
ORDER  BY 3,4

--Looking at total deaths by country
SELECT Max(Cast(total_deaths AS INT)) AS deaths,
       location
FROM   data
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY 1 DESC 

--Checking total deaths by percentage of male smokers
SELECT Max(Cast(male_smokers AS DECIMAL(10, 5))) AS smokers,
       location,
       Max(Cast(total_deaths AS INT))            AS deaths
FROM   data
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY 3 DESC 

--Checking total deaths by percentage of male smokers where more than 50% of males smoke
SELECT Max(Cast(male_smokers AS DECIMAL(10, 5))) AS smokers,
       location,
       Max(Cast(total_deaths AS INT))            AS deaths
FROM   data
WHERE  continent IS NOT NULL
GROUP  BY location
HAVING Max(Cast(male_smokers AS DECIMAL(10, 5))) > 50
ORDER  BY 3 DESC 

 --To see a more accurate representation of effects of covid on smokers we need to look at both male and female smokers
 --After a quick websrape from wikipedia a table of sex ratio(dbo.sexratio) is joined in
SELECT * FROM sexratio

SELECT Max(Cast(male_smokers AS DECIMAL(10, 5)))   AS male_smoker_percent,
       location,
       Max(Cast(total_deaths AS INT))              AS deaths,
       Max(population)                             AS population,
       Max(Cast(female_smokers AS DECIMAL(10, 5))) AS female_smoker_percent,
       Max(sex_ratio)                              AS sexratio
FROM   data
       JOIN dbo.sexratio
         ON data.location = sexratio.country
WHERE  continent IS NOT NULL
GROUP  BY location
HAVING Max(Cast(male_smokers AS DECIMAL(10, 5))) > 50
ORDER  BY 4 DESC 

--Now lets try to calculate The Gender Populations 
SELECT Max(Cast(male_smokers AS DECIMAL(10, 5)))     AS male_smoker_percent,
       location,
       Max(Cast(total_deaths AS INT))                AS deaths,
       Max(population)                               AS population,
       Max(Cast(female_smokers AS DECIMAL(10, 5)))   AS female_smoker_percent,
       Max(sex_ratio)                                AS sexratio,
       Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) 
						     AS males,
       Max(population) - ( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(
                           population) )
                                                     AS females
FROM   data
       JOIN dbo.sexratio
         ON data.location = sexratio.country
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY 4 DESC 

--Lets round everything so it looks neat
SELECT Max(Cast(male_smokers AS DECIMAL(10, 2)))         AS male_smoker_percent,
       location,
       Max(Cast(total_deaths AS INT))                    AS deaths,
       Max(population)                                   AS population,
       Max(Cast(female_smokers AS DECIMAL(10, 2)))       AS female_smoker_percent,
       Max(sex_ratio)                                    AS sexratio,
       Round(( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) ), 0)
		                                         AS males,
       Round(Max(population) - ( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) ), 0)                           
			                                 AS females
FROM   data
       JOIN dbo.sexratio
         ON data.location = sexratio.country
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY 4 DESC 

--Calculating The number of male and female smokers
SELECT Max(Cast(male_smokers AS DECIMAL(10, 2)))         AS male_smoker_percent,
       location,
       Max(Cast(total_deaths AS INT))                    AS deaths,
       Max(population)                                   AS population,
       Max(Cast(female_smokers AS DECIMAL(10, 2)))       AS female_smoker_percent,
       Max(sex_ratio)                                    AS sexratio,
       Round(( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) ), 0)
							 AS males,
       Round(Max(population) - ( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) ), 0)                           
				                         AS females,
       Round((Max(Cast(male_smokers AS DECIMAL(10, 2)))*Round(( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) ), 0))/100,0)
							 AS male_smokers,
       Round((Max(Cast(female_smokers AS DECIMAL(10, 2)))*Round(Max(population) - ( Max(sex_ratio) / ( Max(sex_ratio) + 1 ) * Max(population) ), 0))/100,0)
							 AS female_smokers
FROM   data
       JOIN dbo.sexratio
         ON data.location = sexratio.country
WHERE  continent IS NOT NULL
GROUP  BY location
ORDER  BY 4 DESC 
