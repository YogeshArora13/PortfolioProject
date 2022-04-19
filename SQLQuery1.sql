create database PortfolioProject;
use PortfolioProject;



Select Location,date, new_cases, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Total cases vs Total Deaths
Select Location, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'

order by 1,2 ;

--Total Cases vs Population

Select Location, total_cases,population,(total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2 ;

--Looking at Countries with HighestInfection Rate
Select Location,population, MAX(total_cases) as InfectionCount,MAX((total_cases/population))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population

order by PopulationPercentageInfected desc ;


--Highest Deaths




-- Sort by Continents

Select continent, MAX(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc;

Select continent, MAX(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by DeathCount desc;

-- Global Numbers

Select  SUM(new_cases)as total_cases, Sum(cast(new_deaths as int)) as total_deaths,(Sum(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
--group by date
order by 1,2 ;

--Looking at Populations vs Vaccination

Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum( case when cast(vac.new_vaccinations as int) is null then 0 else 1 end ) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject ..CovidVaccination vac
on dea.date= vac.date 
and dea.location=vac.location
where dea.continent is not null
order by 1,3;

--Use CTE

with PopvsVac ( continent,location, date, population, new_vaccinations, rollingpeoplevaccinated)
as (
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum( case when cast(vac.new_vaccinations as int) is null then 0 else 1 end ) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject ..CovidVaccination vac
on dea.date= vac.date 
and dea.location=vac.location
where dea.continent is not null
)
select * ,( Rollingpeoplevaccinated/population)*100 
from PopvsVac;

--Temp Table
drop table if exists #peoplevaccinated
Create table #PeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric)

Insert into #PeopleVaccinated
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum( case when cast(vac.new_vaccinations as int) is null then 0 else 1 end ) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject ..CovidVaccination vac
on dea.date= vac.date 
and dea.location=vac.location
where dea.continent is not null
select * ,( Rollingpeoplevaccinated/population)*100 
from #PeopleVaccinated;

create view PeopleVaccinated as 
Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum( case when cast(vac.new_vaccinations as int) is null then 0 else 1 end ) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject ..CovidVaccination vac
on dea.date= vac.date 
and dea.location=vac.location
where dea.continent is not null