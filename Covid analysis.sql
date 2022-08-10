Select *
From PortfolioProject.CovidDeaths
where continent is not null
order by 3,4;

--Select *
--From PortfolioProject.CovidVaccinations
--order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your continent

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of the population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
order by 1,2

-- Looking at Countries with Highest Infection rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as HighestInfectionPercentage
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
Group by Location, Population
order by HighestInfectionPercentage desc
 
-- Showing countries with the highest death count per population

Select Location, Max(total_deaths) as TotalDeathCount
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

Select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases), SUM(new_deaths) -- (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths
--where location like '%Africa%'
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccination
-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, CumulativeVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations
from PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select * , (CumulativeVaccinations/Population)*100
From PopvsVac

-- Temp Table

Create Table [IF NOT EXISTS] #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinations numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativeVaccinations
from PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (CumulativeVaccinations/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

create view DeathPercentage as
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.CovidDeaths
-- where location like '%Africa%'
where continent is not null
group by date
order by 1,2
