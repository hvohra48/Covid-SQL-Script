Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..Covidvaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population, new_deaths
From PortfolioProject..CovidDeaths
order by 1,3

--total death vs total cases
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where Location like '%States%'
order by 1,2

--Looking at total cases vs population
Select Location, date, total_cases, population, (total_cases/population)*100 as AffectedPercentage
From PortfolioProject..CovidDeaths
where Location like '%States%'
order by 3,4

--Looking at countries with highest Infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
--where Location like '%States%'
Group by Location, population
order by InfectedPercentage Desc

--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as HighestdeathCount 
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by HighestdeathCount Desc

--Lets breakdown by continent
Select continent, MAX(cast(total_deaths as int)) as totaldeathCount 
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by totaldeathCount  Desc

--showing continent with highest death count as per population
Select continent , MAX(cast(total_deaths as int)) AS Highestdeath, MAX(total_deaths/population)*100 AS highestdeathpercapita
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by highestdeathpercapita Desc

--GLOBAL Number
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) /SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null 
Order by 2,3;

--Use CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int )) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp table 
DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int )) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
On dea.location=vac.location
and dea.date=vac.date
--Where dea.continent is not null
--Order by 2,3
select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--creating view
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
Join PortfolioProject..Covidvaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null 
--Order by 2,3;

Select *
From PercentPopulationVaccinated 