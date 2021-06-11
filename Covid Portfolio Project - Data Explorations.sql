/* 
Covid 19 Data Exploration

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like'%states%'
order by 1,2



-- Looking at the Total Cases vs Total Deaths
-- Shows what percentage of population got Covid

Select location, date,population, total_cases,(total_cases/population)*100 as PercentofPopulation
From PortfolioProject..CovidDeaths$
--Where location like'%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location,population, max(total_cases) as HighestInfectionCount,
max((total_cases/population))*100 as PrecentofPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like'%states%'
Group by location,population
order by PrecentofPopulationInfected desc


--Showing Countries with Highest Death COunt per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Breakdown by Continent


-- Showing the Continents with the Highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, 
sum(new_cases) as Total_cases, 
sum(cast(new_deaths as int)) as Total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like'%states%'
Where continent is not null
Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least on Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- Rolling Count Column
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3


--USE CTE (Rolling Percentage of Vaccinated People) to perform Calculation on Partition By previous query
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- Rolling Count Column
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null