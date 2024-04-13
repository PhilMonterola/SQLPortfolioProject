Select *
From PortfolioProject..CovidDeaths
Where continent is not null /*added later*/
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we're going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null /*added later*/
order by 1,2

-- looking at total cases vs total deaths
alter table [CovidDeaths] alter column [total_cases] float /*these are not in the video tutorial*/
alter table [CovidDeaths] alter column [total_deaths] float /*these are not in the video tutorial*/
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Philippines' and continent is not null /*added later*/
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentofPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'Philippines'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as PercentofPopulationInfected
From PortfolioProject..CovidDeaths
--Where location = 'Philippines'
group by location, population
order by PercentofPopulationInfected desc

-- Showing Countries with highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Philippines'
Where continent is not null /*added later*/
group by location
order by TotalDeathCount desc

/*
-Collapse dbo.CovidDeaths
-Collapse Columns
-total_deaths (checking the data type, it's already in float which is good)

cast([columnName] as [dataType])
*/

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where continent is null
--Group by location
--order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Philippines'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

alter table [CovidDeaths] alter column [new_cases] float /*these are not in the video tutorial*/
alter table [CovidDeaths] alter column [new_deaths] float /*these are not in the video tutorial*/

Select /*date,*/ SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Philippines' 
Where continent is not null /*added later*/
--Group by date
order by 1,2
/*you no longer have to cast new_deaths as int since you've modified its
data type during importing process*/

-- Looking at Total Population vs Vaccinations
/*
try:
SUM(cast(vac.new_vaccinations as int))
or
SUM(CONVERT(int, vac.new_vaccinations))*/

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, Mew_Vaccinations, RollingPeopleVaccinated) /*if number of columns in CTE is different in Select. It yields an error*/
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 /*order clause can't be in here*/
)
Select *, (CONVERT(float, RollingPeopleVaccinated)/CONVERT(float, Population))*100
From PopvsVac
order by 2,3



-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (CONVERT(float, RollingPeopleVaccinated)/CONVERT(float, Population))*100
From #PercentPopulationVaccinated
order by 2,3
/*Unlike CTEs, only execute the three line of scripts above to see
contents of our temp table*/


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

/*
-Go to Databases
-PortfolioProject
-Tables
-Views
-dbo.PercemtPopulationVaccinated

Note: Database must be on PortfolioProject for your file to appear in Views folder
*/

Select *
From PercentPopulationVaccinated

/*Do some of these for the rest*/

