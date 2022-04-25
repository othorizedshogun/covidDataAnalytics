/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM "covidDataAnalytics".public.covid_deaths
WHERE continent IS NOT null 
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "covidDataAnalytics".public.covid_deaths
WHERE continent IS NOT null 
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM "covidDataAnalytics".public.covid_deaths
WHERE location = 'Nigeria'
AND continent IS NOT null 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT null AND total_deaths!=0
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT null 
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 AS DeathPercentage
FROM "covidDataAnalytics".public.covid_deaths
--WHERE location = 'Nigeria'
WHERE continent IS NOT null 
--GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT c_d.continent, c_d.location, c_d.date, c_d.population, c_v.new_vaccinations
, SUM(c_v.new_vaccinations) OVER (PARTITION BY c_d.Location ORDER BY c_d.location, c_d.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM "covidDataAnalytics".public.covid_deaths c_d
JOIN "covidDataAnalytics".public.covid_vaccinations c_v
	ON c_d.location = c_v.location
	AND c_d.date = c_v.date
WHERE c_d.continent IS NOT null 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT c_d.continent, c_d.location, c_d.date, c_d.population, c_v.new_vaccinations
, SUM(c_v.new_vaccinations) OVER (PARTITION BY c_d.location ORDER BY c_d.location, c_d.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM "covidDataAnalytics".public.covid_deaths c_d
JOIN "covidDataAnalytics".public.covid_vaccinations c_v
	ON c_d.location = c_v.location
	AND c_d.date = c_v.date
WHERE c_d.continent IS NOT null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMP TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
location VARCHAR(255),
date TIMESTAMP,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO PercentPopulationVaccinated
SELECT c_d.continent, c_d.location, c_d.date, c_d.population, c_v.new_vaccinations
, SUM(c_v.new_vaccinations) OVER (PARTITION BY c_d.Location ORDER BY c_d.location, c_d.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM "covidDataAnalytics".public.covid_deaths c_d
JOIN "covidDataAnalytics".public.covid_vaccinations c_v
	ON c_d.location = c_v.location
	AND c_d.date = c_v.date
--WHERE c_d.continent IS NOT null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT c_d.continent, c_d.location, c_d.date, c_d.population, c_v.new_vaccinations
, SUM(c_v.new_vaccinations) OVER (PARTITION BY c_d.Location ORDER BY c_d.location, c_d.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM "covidDataAnalytics".public.covid_deaths c_d
JOIN "covidDataAnalytics".public.covid_vaccinations c_v
	ON c_d.location = c_v.location
	AND c_d.date = c_v.date
WHERE c_d.continent IS NOT null 

