/* 
Covid 19 Data EXPLORATION

SKILLS USED : Join's, Order by , Group by,Conveting Data Types, Window Functions, CTE's, Temp Tables, Aggregate Functions, Creating Views

*/




select * 
FROM PortfolioProject. . CovidDeaths
WHERE continent is not null
ORDER BY 3,4

select * 
FROM PortfolioProject. . CovidVaccination
ORDER BY 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject. .CovidDeaths
where continent is not null
ORDER BY 1,2

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject. .CovidDeaths
WHERE continent is not null
order by 1,2

-- looking at Total cases vs total Deaths

select location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject. .CovidDeaths
where continent is not null
ORDER BY 1,2

--Showing likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject. .CovidDeaths
WHERE location like '%India%' 
and continent is not null
ORDER BY 1,2

--looking at Total cases vs population
-- shows that what Percentage of population infected with covid

select location, date, population, total_cases, (total_cases/population)*100 As PercentagePopulationInfected
FROM PortfolioProject. . CovidDeaths
WHERE location like '%state%' and continent is not null
ORDER BY 1,2

--looking at countries with Highest Infection Rate compared to Population

select location, population, MAX (total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM PortfolioProject. .CovidDeaths
--WHERE location like '%India%'
where continent is not null
GROUP BY location, population
ORDER BY 1,2

--looking at countries with Highest Infection Rate compared to Population in DESC order to understand with country has highest Infected rate

select location, population, MAX(total_cases),MAX(total_cases/population)*100 As PercentagePopulationInfected
FROM PortfolioProject. .CovidDeaths
--where location like '%'
where continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--showing countries with Highest Death Count per population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject. .CovidDeaths
--WHERE location like '%State%'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--showing continents with highest Deaths count per population (Breaking things down by continent)

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject. .CovidDeaths
--where location like '%state%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject. .CovidDeaths
--where location like '%state%'
where continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global Numbers

select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject. .CovidDeaths
--where location like '%state%
where continent is not null
GROUP BY date
ORDER BY 1,2

select  SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject. .CovidDeaths
--where location like '%state%
where continent is not null
--GROUP BY date
ORDER BY 1,2

--JOIN TWO TABLES

select * 
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccination vac
	ON dea.location =vac.location
	and dea.date= vac.date

--Looking at Total Population vs Vaccinations
--showing Percentage of Population that has recieved at least one covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccination vac
	ON dea.location =vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccination vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select vac.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE (To perfrom calculation on Partition by in previous query)

DROP TABLE IF Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
population numeric,
Date datetime,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select vac.continent, dea.location, sum(convert(int,dea.date)), dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating VIEWS for later Visualization

Create VIEW PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject. .CovidDeaths dea
JOIN PortfolioProject. .CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3

select * 
FROM PercentPopulationVaccinated


-