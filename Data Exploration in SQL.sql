SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 2,3

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Comparing Total cases vs Total deaths
--Probability of death for a given location calculated as percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE location like '%States'
AND continent IS NOT NULL
ORDER BY 1,2

--Comparing Total cases vs Total deaths
--Calculating percentage of population that got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
FROM CovidDeaths$
--WHERE location like '%States'
WHERE continent IS NOT NULL
ORDER BY 1,2

--Comparing countries based on Highest infection rates compared to Population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 as HighestCasePercentage
FROM CovidDeaths$
--WHERE location like '%States'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestCasePercentage DESC

--Ordering countries with Highest death counts against population

SELECT location, MAX(cast(total_deaths as int)) AS MaxDeathCount
FROM CovidDeaths$
--WHERE location like '%States'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--Ordering continents with Highest death counts against population

SELECT continent, MAX(cast(total_deaths as int)) AS MaxDeathCount
FROM CovidDeaths$
--WHERE location like '%States'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeathCount DESC

--Global calculations

SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at Total population vs Vaccination

WITH PopVsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingVaccinationPercentage
FROM PopVsVac

--Temp Table

Drop Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingVaccinationPercentage
FROM #PercentPopulationVaccinated

--Creating views for data visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated