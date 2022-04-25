/*
Queries used for Tableau Project
*/



-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 AS DeathPercentage
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location = 'Nigeria'
--WHERE location = 'World'
----GROUP BY date
--ORDER BY 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(new_deaths) AS TotalDeathCount
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = '%states%'
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
GROUP BY location, population, date
--ORDER BY PercentPopulationInfected DESC