--Select * from covidvacinations
--order by 3,4
select * from coviddeathdata
order by 3,4

--select Data that we are going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
from coviddeathdata
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from coviddeathdata
where location = 'India'

order by 1,2


-- Looking at Total Cases vs Population
--Shows what percentage of population got Covid 

Select location, date, total_cases, population , (total_cases/ population)*100 as percentagePopulationInfected
from coviddeathdata
where location = 'India'
order by 1,2


-- Looking Tat Countries with Highest Infection Rate compared to Population 


select location, population , MAX(total_cases) as HighestInfectionCount, MAX( (total_cases/ population))*100 as percentagePopulationInfected
from coviddeathdata
--where location = 'India'
group by location, population
order by percentagePopulationInfected desc

--Showing Countries with Highest Death Count per Populaton 

-- lets break things down by continent 
--showing the continent with highest death count perpopulation 
select continent , MAX(cast (total_deaths as int)) as TotalDeathCount
from coviddeathdata
--where location = 'India'
where continent is not null
group by  continent
order by TotalDeathCount desc

--GLOBAL NUMBER by date 

select date, SUM (new_cases) as total_cases, SUM (CAST (new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int))/ SUM (new_cases)*100 as DeathPercentage 
from coviddeathdata
where continent is not null
Group by date 
order by 1, 2 

--total global number 
select  SUM (new_cases) as total_cases, SUM (CAST (new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int))/ SUM (new_cases)*100 as DeathPercentage 
from coviddeathdata
where continent is not null
--Group by date 
order by 1, 2 

-- Looing at total population vs vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as rollingPeopleVaccinated 
from coviddeathdata dea
join  covidvacinations vac 
on dea.location = vac.location 
and dea.date = vac.date  
where dea.continent is not null
order by 2,3  


--USE CTE
 
 With PopvsVac (continent, location ,date, population, new_vaccinations,  RollingPeopleVaccinated )
 as (
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated 
from coviddeathdata dea
join  covidvacinations vac 
on dea.location = vac.location 
and dea.date = vac.date  
where dea.continent is not null
--order by 2,3 
) 

select*, (RollingPeopleVaccinated / population)*100
from PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
LOcation nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
 RollingPeopleVaccinated  numeric
 )

Insert into  #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated 
from coviddeathdata dea
join  covidvacinations vac 
on dea.location = vac.location 
and dea.date = vac.date  
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated
 

 -- creating view to store data for later  visualizations
 create view PercentPopulationVaccinated as
 
 Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations )) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated 
from coviddeathdata dea
join  covidvacinations vac 
on dea.location = vac.location 
and dea.date = vac.date  
where dea.continent is not null
--order by 2,3