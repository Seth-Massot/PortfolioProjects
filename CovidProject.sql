Select *
From CovidProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From CovidProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using


Select location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Alter Table [dbo].[CovidDeaths]
Alter Column total_cases float;

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidProject..CovidDeaths
--Where Location like '%states%'
Order by 1,2


-- Looking at Total Cases vs Population
--Shows what percentage of population has contracted covid

Select location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
From CovidProject..CovidDeaths
--Where Location like '%states%'
Order by 1,2


-- Looking at Countries with highest Infection Rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
From CovidProject..CovidDeaths
--Where Location like '%states%'
Group by location, population
Order by InfectionPercentage desc


-- Showing Countries with the highest Death Count per Population

Select location, MAX(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
--Where Location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc


-- LET'S BREAK IT DOWN BY CONTINENT

-- Showing continents with the highest death count per population


--Select location, MAX(total_deaths) as TotalDeathCount
--From CovidProject..CovidDeaths
--Where continent is null
--Group by location
--Order by TotalDeathCount desc


Select continent, MAX(total_deaths) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 AS DeathPercentage
From CovidProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by date
Order by 1,2


Select SUM(cast(new_cases as float)) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeaths, (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 AS DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Order by 1,2



-- Looking at Total Population vs Vaccinations

Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths as Deaths
Join CovidProject..CovidVaccinations as Vax
	On Deaths.location = Vax.location
	and Deaths.date = Vax.date
Where Deaths.continent is not null
Order by 2,3


-- Use CTE

With PopvsVax (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(Convert(float, vax.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths as Deaths
Join CovidProject..CovidVaccinations as Vax
	On Deaths.location = Vax.location
	and Deaths.date = Vax.date
Where Deaths.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVax
Order by 2,3


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(Convert(float, vax.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths as Deaths
Join CovidProject..CovidVaccinations as Vax
	On Deaths.location = Vax.location
	and Deaths.date = Vax.date
Where Deaths.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
Order by 2,3


-- Creating View to store data for later visualizations

Create View PercentPeopleVaccinated as
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vax.new_vaccinations
, SUM(Convert(float, vax.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths as Deaths
Join CovidProject..CovidVaccinations as Vax
	On Deaths.location = Vax.location
	and Deaths.date = Vax.date
Where Deaths.continent is not null

Select *
From PercentPeopleVaccinated