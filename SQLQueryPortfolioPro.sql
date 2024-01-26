SELECT *
FROM PortfolioProject..CovidDeaths
Order BY 3,4



SELECT *
FROM PortfolioProject..CovidVaccinations
Order BY 3,4

-- SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order BY 1,2

--looking at total cases and total deaths
SELECT location, date, total_cases ,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%india%'
Order BY 1,2

--Show what percentage of population got covid
SELECT location,date,population , total_cases , (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%india%'
Order BY 1,2


--Looking at countries with highest infection rate compared to population
SELECT location,population , MAX(total_cases) AS HighestinfectionCount, MAX(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
GROUP BY population,location
Order BY InfectedPercentage DESC

--showing the countries with highest death count per population
SELECT location , MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
Order BY HighestDeathCount DESC


--lets break this down by continent
SELECT location , MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NULL
GROUP BY location
Order BY HighestDeathCount DESC


--showing continent with highest death count
SELECT continent , MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
Order BY HighestDeathCount DESC

-- GLOBAL NUMBERS

--SELECT date,total_cases , total_deaths , (total_deaths/total_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
----WHERE location LIKE '%india%'
--WHERE continent IS NOT NULL
--GROUP BY date
--Order BY 1,2

SELECT date,SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths as int)) AS TotalDeaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL
GROUP BY date
Order BY 1,2

--total cases and deaths in world
SELECT SUM(new_cases) AS TotalCases,SUM(CAST(new_deaths as int)) AS TotalDeaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%india%'
WHERE continent IS NOT NULL

Order BY 1,2


--looking at total population vs vaccination


SELECT death.continent, death.location, death.date, death.population, vacin.new_vaccinations,
SUM(CAST(vacin.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacin
	ON death.location = vacin.location
	AND death.date = vacin.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3


--USE CTE
WITH Popvsvac(Continent,
			  Location,
			  Date,
			  population,
			  new_vaccinations,
			  Rollingpeoplevaccinated)
AS
(
SELECT 
	death.continent,
	death.location,
	death.date,
	death.population, 
	vacin.new_vaccinations,
	SUM(CAST(vacin.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacin
	ON death.location = vacin.location
	AND death.date = vacin.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

)
SELECT *,(Rollingpeoplevaccinated/population)*100 AS VacVsPop
FROM Popvsvac


  --TEMP TABLES
  DROP TABLE IF EXISTS #percentagePopulationVaccinated

  CREATE TABLE #percentagePopulationVaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  Rollingpeoplevaccinated numeric
  )

	SELECT 
	death.continent,
	death.location,
	death.date,
	death.population, 
	vacin.new_vaccinations,
	SUM(CAST(vacin.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacin
	ON death.location = vacin.location
	AND death.date = vacin.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3


SELECT *,(Rollingpeoplevaccinated/population)*100 AS VacVsPop
FROM #percentagePopulationVaccinated
  


 -- Creating View to store data for later visualizations





 CREATE VIEW percentagePopulationVaccinated AS

SELECT 
	death.continent,
	death.location,
	death.date,
	death.population, 
	vacin.new_vaccinations,
	SUM(CAST(vacin.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)  AS Rollingpeoplevaccinated
--(Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vacin
	ON death.location = vacin.location
	AND death.date = vacin.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM percentagePopulationVaccinated



