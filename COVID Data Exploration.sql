--SELECT *
--FROM PortfolioProject..CovidDeaths

--SELECT *
--FROM PortfolioProject..CovidVaccinations


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) /total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
Where location = 'India'
ORDER BY date

-- Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (CAST(total_cases AS FLOAT) / population)*100 as Percentage_Affected
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
Order By date

--Looking at countries with highest infection rates

SELECT location, population, MAX(total_cases) as Max_Cases, (CAST(MAX(total_cases) AS FLOAT) / population)*100 as Max_Infection_Rate 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Max_Infection_Rate DESC

--Looking at countries with highest testing rate

SELECT location, population, MAX(total_tests) as Max_Tested, (CAST(MAX(total_tests) AS FLOAT) / population)*100 as Max_Testing_Rate 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Max_Testing_Rate DESC

--Looking at total deaths by continents

SELECT temp.continent, SUM(temp.MaxDeaths_in_Countries) as Total_Deaths
FROM (SELECT continent, location, MAX(total_deaths) AS MaxDeaths_in_Countries
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location) as temp
GROUP BY temp.continent
ORDER BY Total_Deaths DESC


SELECT location, MAX(total_deaths) as Total_Deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location <> 'World'
GROUP BY location
ORDER BY Total_Deaths DESC

--Global numbers

--New Cases vs New deaths per day

SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (SUM(CAST(new_deaths as Float))/NULLIF(SUM(new_cases),0))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Overall total cases vs total deaths 

SELECT SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, (SUM(CAST(new_deaths as Float))/SUM(new_cases))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

--Count of people vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, (CAST(vac.new_vaccinations AS FLOAT)/dea.population)*100 AS Vaccination_Percentage
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

--Percentage of people vaccinated

--Using CTE

WITH CET_Vacc_Count AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Count_Vaccinated 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CAST(Count_Vaccinated AS FLOAT)/population)*100 AS Vaccinated_Percentage
FROM CET_Vacc_Count

--Using Temp Table

DROP Table IF EXISTS #temp_vacc_count
CREATE TABLE #temp_vacc_count
(
continent nvarchar(50),
location nvarchar(50),
date datetime,
population bigint,
new_vaccinations int,
Count_vaccinated int,
)

INSERT INTO #temp_vacc_count
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Count_Vaccinated 
FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CAST(Count_Vaccinated AS FLOAT)/population)*100 AS Vaccinated_Percentage
FROM #temp_vacc_count
ORDER BY location, date