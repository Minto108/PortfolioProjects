SELECT * FROM PortfolioProject..CovidDeaths$
where continent is NOT NULL
order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$ order by 1,2;

-- Looking at the total cases vs total deaths

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$ order by 1,2;

-- Find out the percantage of covid deaths
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 from PortfolioProject..CovidDeaths$ order by 1,2;

-- Likelihood of dying if you get covid in India
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as Death_Percentage from PortfolioProject..CovidDeaths$ 
where location like '%India%'  order by 1,2;

--Shows what percentage of the population got Covid
SELECT location, date, total_cases, population,
(total_cases/population)*100 as Case_Percentage from PortfolioProject..CovidDeaths$ 
--where location like '%India%' 
order by 1,2;

--Looking at countries with highest infection rate compared to population
SELECT location, MAX(total_cases) as max_cases, population, MAX((total_cases/population))*100 as percentage_infected
from PortfolioProject..CovidDeaths$ 
where continent is NOT NULL
group by location, population
order by percentage_infected desc;

--Looking at countries with highest death rate 
SELECT location, MAX(cast(total_deaths as int)) as Total_Death
from PortfolioProject..CovidDeaths$ 
where continent is NOT NULL
group by location
order by Total_Death desc;

--Highest death rate by continent
--SELECT location, MAX(cast(total_deaths as int)) as Total_Death
--from PortfolioProject..CovidDeaths$ 
--where continent IS  NULL
--group by location
--order by Total_Death desc;

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death
from PortfolioProject..CovidDeaths$ 
where continent IS NOT NULL
group by continent
order by Total_Death desc;

--Global numbers
SELECT --date,
SUM(cast(new_cases as int)) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,
(SUM(CAST(new_deaths as int))/SUM(new_cases)*100) as Death_Percentage
from PortfolioProject..CovidDeaths$
where continent IS NOT NULL
--Group by date
order by 1,2;


SELECT * FROM PortfolioProject..CovidVaccinations$; 

SELECT * FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND
dea.date = vac.date;


-- Looking at Total Population vs Total Vaccinations
SELECT  dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location order by dea.location, vac.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
order by 2,3;

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT  dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location order by dea.location, vac.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100  FROM PopvsVac;

-- USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric);

Insert into #PercentPeopleVaccinated
SELECT  dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location order by dea.location, vac.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100  FROM #PercentPeopleVaccinated order by 2,3;


-- Creating views
CREATE VIEW PercentPeopleVaccinated AS
SELECT  dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location order by dea.location, vac.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.population IS NOT NULL;

SELECT * FROM PercentPeopleVaccinated;

CREATE VIEW GlobalNumber AS
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death
from PortfolioProject..CovidDeaths$ 
where continent IS NOT NULL
group by continent
--order by Total_Death desc;

SELECT * FROM GlobalNumber;