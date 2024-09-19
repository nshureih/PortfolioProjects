SELECT *
FROM `covid-project-433723.CovidData.CovidVaccinations` 
WHERE continent IS NOT NULL
ORDER BY 3,4;

--Selecting Data which will be used

SELECT continent, date, total_cases, new_cases, total_deaths, population
FROM `covid-project-433723.CovidData.CovidDeaths` 
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking at Total Cases vs. Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `covid-project-433723.CovidData.CovidDeaths` 
WHERE location LIKE '%states%' and continent IS NOT NULL
ORDER BY 1,2;

--Perecentage of population infected by Covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/population)*100 as PercentPopulationInfected
FROM `covid-project-433723.CovidData.CovidDeaths` 
WHERE Location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2;

--Countries with Highest Infection Rate Compared to Population
SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM `covid-project-433723.CovidData.CovidDeaths` 
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY PercentofPopulationInfected asc;

--Breaking things down by continent

--Continents with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM `covid-project-433723.CovidData.CovidDeaths`
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM `covid-project-433723.CovidData.CovidDeaths`
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM `covid-project-433723.CovidData.CovidDeaths` dea
JOIN `covid-project-433723.CovidData.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--CTE

WITH PopvsVac
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-project-433723.CovidData.CovidDeaths` dea
JOIN `covid-project-433723.CovidData.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP TABLE

DROP TABLE IF EXISTS CovidData.PercentPopulationVaccinated;
CREATE TABLE CovidData.PercentPopulationVaccinated
(
continent string (255),
location string (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
);

INSERT INTO CovidData.PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-project-433723.CovidData.CovidDeaths` dea
JOIN `covid-project-433723.CovidData.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date;
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM CovidData.PercentPopulationVaccinated;

DROP TABLE IF EXISTS CovidData.PercentPopulationVaccinated;
CREATE VIEW CovidData.PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-project-433723.CovidData.CovidDeaths` dea
JOIN `covid-project-433723.CovidData.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

