--Exploration the data
SELECT 
  *
FROM 
  `vocal-ceiling-351315.deads_covid.covid_deads`
WHERE continent is not null
order by 3, 4 
LIMIT 1000
;


--Selecting the data that i used and exploring it

SELECT location,date,total_cases,new_cases, total_deaths, population
FROM `vocal-ceiling-351315.deads_covid.covid_deads`
WHERE continent is not null  
order by 1, 2
LIMIT 1000;

--Looking at Total cases vs Total deaths 
-- Shows likelihood of dying if you contract covid

SELECT location,date,total_cases, total_deaths, 100*(total_deaths/total_cases) AS percentage_deads_per_cases
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE continent is not null AND location LIKE '%Canada%'--you can choose the name of your country here if you want
order by 1, 2;

--Looking at total cases vs population
-- Shows what percentage of population got covid

SELECT location,population, MAX(total_cases) as infection_count,MAX((total_cases/population)*100) AS percentage_population_with_covid
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE continent is not null--you can choose the name of your country here if you want
GROUP BY 1, 2
order by 1, 2;

-- Looking at countries infection rate compared to population

SELECT location, population, MAX(total_cases ) as number_cases,MAX(100*(total_cases/population)) AS percentage_population_with_covid
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE continent is not null 
GROUP BY location, population
ORDER BY percentage_population_with_covid DESC;


-- Showing countries death count per population


SELECT location, population, MAX(total_deaths ) AS total_death ,MAX(100*(total_deaths/population)) AS percentage_deaths_country
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE continent is not null
GROUP BY location, population
order by percentage_deaths_country DESC;



--Let's try with income

--Looking at income infection rate compared to population

SELECT location, population, MAX(total_cases ) as Highest_infected_country,MAX(100*(total_cases/population)) AS percentage_population_with_covid
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE location LIKE '%income%'
GROUP BY location, population
ORDER BY percentage_population_with_covid DESC;

-- Showing income death count per population


SELECT location, population, MAX(total_deaths ) AS total_death_country ,MAX(100*(total_deaths/population)) AS percentage_deaths_country
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE location LIKE '%income%'
GROUP BY location, population
ORDER BY percentage_deaths_country DESC;


--Let's Break things down by continent
--Looking at continents with highest infection rate compared to population

SELECT continent, SUM(Highest_infected_country) AS total_cases_continent ,(100*(SUM(Highest_infected_country)/SUM(population))) AS percentage_cases_continent
FROM 
  (
    SELECT continent, location, population, MAX(total_cases ) as       Highest_infected_country,MAX(100*(total_cases/population)) AS percentage_population_with_covid
    FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
    WHERE continent is not null
    GROUP BY continent, location, population
    ORDER BY percentage_population_with_covid DESC)
WHERE continent is not null
GROUP BY continent
ORDER BY percentage_cases_continent DESC;



-- Looking at continents with highest death count per population
SELECT continent, SUM(total_death_country) AS total_death_continent ,(100*(SUM(total_death_country)/SUM(population))) AS percentage_death_continent
FROM 
  (
    SELECT continent, location, population, MAX(total_deaths ) AS total_death_country ,MAX(100*(total_deaths/population)) AS percentage_deaths_country
    FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
    WHERE continent is not null
    GROUP BY continent, location, population
    ORDER BY percentage_deaths_country DESC
  )
WHERE continent is not null
GROUP BY continent
order by percentage_death_continent DESC;


--Global numbers
--TOTAL CASES VS TOTAL DEATHs GLOBAL

SELECT SUM(new_cases) as Total_cases_globally, SUM(new_deaths) AS Total_deaths_globally, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage_globally
FROM `vocal-ceiling-351315.deads_covid.covid_deads`
WHERE continent is not null;


--LOOKING AT TOTAL POPULATION VS VACCINATIONS WITH A TEMP TABLE

DROP TABLE IF exists deads_covid.percent_population_vaccinated;
CREATE TABLE deads_covid.percent_population_vaccinated
(continent string,
location string(255),
date datetime,
population FLOAT64,
new_vaccinations FLOAT64,
accumulated_covid_vaccinations FLOAT64
);

INSERT INTO `vocal-ceiling-351315.deads_covid.percent_population_vaccinated`
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER ( partition by location order by location, date) AS accumulated_covid_vaccinations, 
FROM `vocal-ceiling-351315.deads_covid.covid_deads`
--WHERE continent IS NOT NULL
ORDER BY 2,3;

SELECT *, (accumulated_covid_vaccinations/population)*100 as percentage_vaccinated_population
FROM `vocal-ceiling-351315.deads_covid.percent_population_vaccinated`
;



--In the next part of the script i will create the views and with that create visualizations on tableu

--Creating views 

DROP VIEW IF exists deads_covid.percentage_population_vaccinated;
CREATE VIEW  deads_covid.percentage_population_vaccinated as
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER ( partition by location order by location, date) AS accumulated_covid_vaccinations, 
FROM `vocal-ceiling-351315.deads_covid.covid_deads`
WHERE continent IS NOT NULL
ORDER BY 2,3;

-- CREATING VIEW FOR countries infection rate compared to population

DROP VIEW IF exists deads_covid.countries_infection_rate;
CREATE VIEW  deads_covid.countries_infection_rate as
SELECT location, population, MAX(total_cases ) as number_cases,MAX(100*(total_cases/population)) AS percentage_population_with_covid
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE continent is not null 
GROUP BY location, population
ORDER BY percentage_population_with_covid DESC;

-- CREATING VIEW FOR countries death count per population

DROP VIEW IF exists deads_covid.countries_death_rate;
CREATE VIEW  deads_covid.countries_death_rate as
SELECT location, population, MAX(total_deaths ) AS total_death ,MAX(100*(total_deaths/population)) AS percentage_deaths_country
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE continent is not null
GROUP BY location, population
order by percentage_deaths_country DESC;


--CREATING VIEW FOR income infection rate compared to population

DROP VIEW IF exists deads_covid.income_infection_rate;
CREATE VIEW  deads_covid.income_infection_rate as
SELECT location, population, MAX(total_cases ) as Highest_infected_country,MAX(100*(total_cases/population)) AS percentage_population_with_covid
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE location LIKE '%income%'
GROUP BY location, population
ORDER BY percentage_population_with_covid DESC;

-- CREATING VIEW FOR income death count per population

DROP VIEW IF exists deads_covid.income_death_rate;
CREATE VIEW  deads_covid.income_death_rate as
SELECT location, population, MAX(total_deaths ) AS total_death_country ,MAX(100*(total_deaths/population)) AS percentage_deaths_country
FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
WHERE location LIKE '%income%'
GROUP BY location, population
ORDER BY percentage_deaths_country DESC;

--CREATING VIEW FOR continents with highest infection rate compared to population

DROP VIEW IF exists deads_covid.continents_infection_rate;
CREATE VIEW  deads_covid.continents_infection_rate as
SELECT continent, SUM(Highest_infected_country) AS total_cases_continent ,(100*(SUM(Highest_infected_country)/SUM(population))) AS percentage_cases_continent
FROM 
  (
    SELECT continent, location, population, MAX(total_cases ) as       Highest_infected_country,MAX(100*(total_cases/population)) AS percentage_population_with_covid
    FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
    WHERE continent is not null
    GROUP BY continent, location, population
    ORDER BY percentage_population_with_covid DESC)
WHERE continent is not null
GROUP BY continent
ORDER BY percentage_cases_continent DESC;



-- CREATING VIEW FOR continents with highest death count per population

DROP VIEW IF exists deads_covid.continents_death_rate;
CREATE VIEW  deads_covid.continents_death_rate as
SELECT continent, SUM(total_death_country) AS total_death_continent ,(100*(SUM(total_death_country)/SUM(population))) AS percentage_death_continent
FROM 
  (
    SELECT continent, location, population, MAX(total_deaths ) AS total_death_country ,MAX(100*(total_deaths/population)) AS percentage_deaths_country
    FROM `vocal-ceiling-351315.deads_covid.covid_deads` 
    WHERE continent is not null
    GROUP BY continent, location, population
    ORDER BY percentage_deaths_country DESC
  )
WHERE continent is not null
GROUP BY continent
order by percentage_death_continent DESC;


--CREATING VIEW FOR Global numbers
--TOTAL CASES VS TOTAL DEATHs GLOBAL

DROP VIEW IF exists deads_covid.global_death_rate;
CREATE VIEW  deads_covid.global_death_rate as
SELECT SUM(new_cases) as Total_cases_globally, SUM(new_deaths) AS Total_deaths_globally, (SUM(new_deaths)/SUM(new_cases))*100 as death_percentage_globally
FROM `vocal-ceiling-351315.deads_covid.covid_deads`
WHERE continent is not null;


-- CREATING VIEW FOR LOOKING AT TOTAL POPULATION VS VACCINATIONS

DROP VIEW IF exists deads_covid.population_vs_vaccination;
CREATE VIEW  deads_covid.population_vs_vaccination as
SELECT *, (accumulated_covid_vaccinations/population)*100 as percentage_vaccinated_population
FROM `vocal-ceiling-351315.deads_covid.percent_population_vaccinated`
;