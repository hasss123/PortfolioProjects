select * from 
portfolioproject1..CovidDeaths
where continent is not null
order by 3,4

--select * from 
--portfolioproject1..CovidVaccinations
--order by 3,4

-- select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population 
from portfolioproject1..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- likelyhood of dying if you have covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentages
from portfolioproject1..CovidDeaths
where location like 'Pakistan'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as casespercentage
from portfolioproject1..CovidDeaths
where location like 'Pakistan'
order by 1,2

--looking at countries with highest infection rate compared to population 
select location, population, max(total_cases) as highestinfectioncount , max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject1..CovidDeaths
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population

select location, max(CAST(total_deaths as int)) as totaldeathcount
from portfolioproject1..CovidDeaths
where continent is not null
group by location
order by totaldeathcount desc

--things by continent
select location, max(CAST(total_deaths as int)) as totaldeathcount
from portfolioproject1..CovidDeaths
where continent is null
group by location
order by totaldeathcount desc

select continent, max(CAST(total_deaths as int)) as totaldeathcount
from portfolioproject1..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--showing continents with hightest death count per population
select continent, max(CAST(total_deaths as int)) as totaldeathcount
from portfolioproject1..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--global numbers
select date, sum(cast(new_cases as int)) as totalnewcases, SUM(cast(new_deaths as int)) as totalnewdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject1..CovidDeaths
--where location like 'Pakistan'
where continent is not null
group by date
order by 1,2

select sum(cast(new_cases as int)) as totalnewcases, SUM(cast(new_deaths as int)) as totalnewdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject1..CovidDeaths
--where location like 'Pakistan'
where continent is not null
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated--, (rollingpeoplevaccinated/population)*100
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
order by 2,3


--use cte 

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated--, (rollingpeoplevaccinated/population)*100
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
)
select *, ( rollingpeoplevaccinated/population)*100
from popvsvac

--temp table 

drop table if exists #percentpopulationvacciated
create table #percentpopulationvacciated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvacciated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated--, (rollingpeoplevaccinated/population)*100
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
select *, ( rollingpeoplevaccinated/population)*100
from #percentpopulationvacciated



--creating view to store data for future visualizations 

create view percentpopulationvacciated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint))over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated--, (rollingpeoplevaccinated/population)*100
from portfolioproject1..CovidDeaths dea
join portfolioproject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null 
--order by 2,3


select * from percentpopulationvacciated
