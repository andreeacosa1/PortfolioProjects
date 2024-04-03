Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2



-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))*100 AS DeathPercentage 
From PortfolioProject..CovidDeaths
order by 1,2



-- Total Cases vs Total Deaths in Romania

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))*100 AS DeathPercentage 
From PortfolioProject..CovidDeaths
where location='Romania'
order by 1,2



--Total cases vs Population

Select location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 AS CasePerPopulation 
From PortfolioProject..CovidDeaths
order by CasePerPopulation desc



--Total cases vs Population in Romania

Select location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 AS CasePerPopulation 
From PortfolioProject..CovidDeaths
where location='Romania'
order by CasePerPopulation desc



--Countries with Highest Infection Rate compared to Population

Select location, population, MAX(convert(float, total_cases)) as HighestInfectionCount, MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 AS PercentPopulationInfected 
From PortfolioProject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc



--Countries with the Highest deaths

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent <> ''
Group by Location 
order by TotalDeathCount desc



--Continents with the highest death count 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent <> ''
Group by continent 
order by TotalDeathCount desc




--Joining the tables together

Select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date




--Looking at new vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent <> ''
	 order by 2,3



--Using CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' 
)

Select *, (RollingPeopleVaccinated/NULLIF(CONVERT(float, population),0))*100 
From PopvsVac




--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date nvarchar (255), 
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent <> ''


SELECT *, (CAST(RollingPeopleVaccinated AS DECIMAL(18, 2)) / NULLIF(Population, 0)) * 100 AS PercentageVaccinated
FROM  #PercentPopulationVaccinated;





-- Queries for Tableau

-- 1. 

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- 2. 

-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent = '' 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(cast(total_cases as float)) as HighestInfectionCount,  Max(cast(total_cases as float)/NULLIF(cast(population as float),0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- 4.

Select Location, Population,date, MAX(cast(total_cases as float)) as HighestInfectionCount,  Max(cast(total_cases as float)/NULLIF(cast(population as float),0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc
