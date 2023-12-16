SELECT *
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3,4

-- SELECT *
-- From [Covid Portfolio Project]..CovidVaccinations
-- Order by 3,4


-- data being used

Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

-- total cases vs total deaths
--likelihood of dying if you contract covid in india (insert country)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
Where location like '%india%'
and continent is not null
Order by 1,2

-- total cases vs population
--% of populatino got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopInfected
From [Covid Portfolio Project]..CovidDeaths
Where location like '%india%'
and continent is not null
Order by 1,2

-- countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by population, location
Order by PercentPopInfected desc


Select location, MAX(cast(total_deaths as int)) as Totaldeathcount
-- countries with highest death count per population
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by location
Order by Totaldeathcount desc

--Filter by continent

-- add continent to group by in above queires^^

-- continents with highest death count per population ^^
Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From [Covid Portfolio Project]..CovidDeaths
--Where location like '%india%'
Where continent is not null
Group by continent
Order by Totaldeathcount desc


-- worldwide 
Select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From [Covid Portfolio Project]..CovidDeaths
where continent is not null
Group by date
Order by 1,2


-- if you comment out Group by date and remove date from select statement you get 1 row. Total death pecentage without date. Use for different analysis?


-- vaccination table below



-- total pop vs total vaccinationcs

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,  -- can use cast instead of convert
dea.date) as RollingPeopleVaccinated-- , (RollingPeopleVaccinated/population)*100    
From [Covid Portfolio Project]..CovidDeaths dea  -- alias
Join [Covid Portfolio Project]..CovidVaccinations vac  --alias
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- CTE (or temp table options available, you decide)

With PopVsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,  -- can use cast instead of convert
dea.date) as RollingPeopleVaccinated-- , (RollingPeopleVaccinated/population)*100    
From [Covid Portfolio Project]..CovidDeaths dea  -- alias
Join [Covid Portfolio Project]..CovidVaccinations vac  --alias
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



-- TEMP Table (or CTE your choice)

DROP Table if exists #PercentPopulationVaccinated      -- good for adding when running multiple times. Hiring interview
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,  -- can use cast instead of convert
dea.date) as RollingPeopleVaccinated-- , (RollingPeopleVaccinated/population)*100    
From [Covid Portfolio Project]..CovidDeaths dea  -- alias
Join [Covid Portfolio Project]..CovidVaccinations vac  --alias
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create view to store data for later visualization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,  -- can use cast instead of convert
dea.date) as RollingPeopleVaccinated-- , (RollingPeopleVaccinated/population)*100    
From [Covid Portfolio Project]..CovidDeaths dea  -- alias
Join [Covid Portfolio Project]..CovidVaccinations vac  --alias
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated