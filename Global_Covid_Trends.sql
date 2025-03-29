-- Getting familiar with both the tables --
SELECT 
    location, date, total_cases, new_cases, total_deaths, population
FROM
    coviddeaths
ORDER BY location, date;

SELECT 
    location, date, total_vaccinations, new_vaccinations
FROM
    covidvaccinations
ORDER BY location, date;

-- Let's understand the coviddeaths table more --

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
ORDER BY location, date;

-- Total Deaths vs Total Cases --
-- Analyzing Death Percentage for each location (filtering for India as an example) --

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%India%'  -- Update this for broader analysis or parameterization
ORDER BY location, date;

-- Total Cases vs Population --
-- Shows what percentage of the population is infected --

SELECT 
    location,
    CAST(date AS DATETIME),
    population,
    total_cases,
    ROUND((total_cases / population) * 100, 2) AS InfectedPercentage
FROM
    coviddeaths
ORDER BY InfectedPercentage DESC;

-- Countries with the highest infection rate compared to population --

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    ROUND(MAX((total_cases / population) * 100), 2) AS InfectionPercentage
FROM
    coviddeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC;

-- Countries with the highest death count compared to population --

SELECT 
    continent,
    SUM(new_deaths) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent != ''
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Exploring some Global Numbers --
-- Summing up global data for cases, deaths, and death percentage --

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    ROUND((SUM(new_deaths) / SUM(new_cases)) * 100, 2) AS DeathPercentage
FROM
    coviddeaths
WHERE
    continent != ''
ORDER BY total_cases DESC;

-- Total Population Vs Vaccinations using CTE --

WITH PopVsVacc (Continent, Location, date, Population, New_vaccinations, RollingCountVacc) AS
(
    SELECT 
        dea.continent,
        dea.location,
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVacc
    FROM 
        coviddeaths AS dea
    JOIN 
        covidvaccinations AS vac
        ON dea.location = vac.location 
        AND dea.date = vac.date
    WHERE dea.continent != '' 
) 
SELECT 
    Continent,
    Location,
    date,
    Population,
    New_vaccinations,
    RollingCountVacc,
    ROUND((RollingCountVacc / Population) * 100, 2) AS VaccPercentage
FROM 
    PopVsVacc
ORDER BY VaccPercentage DESC;

-- Create a view for later visualization --

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountVacc
FROM 
    coviddeaths AS dea
JOIN 
    covidvaccinations AS vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent != '';


