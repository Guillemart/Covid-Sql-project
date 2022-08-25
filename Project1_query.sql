select * 
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
order by 3,4

--select * 
--from Portfolio_Project.dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using
select Location,date,total_cases,new_cases,total_deaths,population
from Portfolio_Project.dbo.CovidDeaths$
order by 1,2

--- Looking at total cases vs total deaths
--- Shows likelihood of dying if you contract Covid in your country
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project.dbo.CovidDeaths$
where location like '%states%' and continent is not null
order by 1,2

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project.dbo.CovidDeaths$
where location = 'Argentina' and continent is not null
order by 1,2

-- Looking at total cases Vs Population
-- Shows percentage of population got Covid
select Location,date,total_cases,population,(total_cases/population)*100 as Percentage_cases
from Portfolio_Project.dbo.CovidDeaths$
where location like '%states%' and continent is not null
order by 1,2

select Location,date,total_cases,population,(total_cases/population)*100 as Percentage_cases
from Portfolio_Project.dbo.CovidDeaths$ 
where location = 'Argentina'and continent is not null
order by 1,2

--- Looking at Conuntries with highest infection rate compared to popuation
select continent,population,max(total_cases) as Highest_Infection_count,max((total_cases/population))*100 as 
Percent_of_Population_Infected
from Portfolio_Project.dbo.CovidDeaths$
group by continent,population
order by Percent_of_Population_Infected desc

--- Showing the Countries with highest Death count per population
select continent,max(cast(total_deaths as int)) as Total_deaths_count
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
group by continent
order by Total_deaths_count desc

--- Lets break things down by continent
select continent,max(cast(total_deaths as int)) as Total_deaths_count
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
group by continent
order by Total_deaths_count desc

--- Showing the continets with the highest death count per population

select continent,max(cast(total_deaths as int)) as Total_deaths_count
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
group by continent
order by Total_deaths_count desc

--- Global numbers

select date,sum(new_cases) as Total_cases, sum(cast(new_deaths as int))as Total_deaths,( sum(cast(new_deaths as int))/sum(new_cases)) *100 as Death_percentage
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int))as Total_deaths,( sum(cast(new_deaths as int))/sum(new_cases)) *100 as Death_percentage
from Portfolio_Project.dbo.CovidDeaths$
where continent is not null
order by 1,2


--- looking at total population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)) as 
Rolling_people_vaccinated
---(Rolling_people_vaccinated/dea.population)*100
from Portfolio_Project.dbo.CovidDeaths$ as dea
join Portfolio_Project.dbo.CovidVaccinations as vac
    on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--- Use CTE to make a formula to view the percentage of people that is vaccinated per Country
with PopvsVac(Continent,Location,Date,Population,new_vaccinations,Rolling_people_vaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)) as 
Rolling_people_vaccinated
from Portfolio_Project.dbo.CovidDeaths$ as dea
join Portfolio_Project.dbo.CovidVaccinations as vac
    on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
)

select *,(Rolling_people_vaccinated/Population)*100
from PopvsVac

---Use Temp table to make a formula to view the percentage of people that is vaccinated per Country

drop table if exists #Percent_population_vaccinated
create table #Percent_population_vaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)
insert into #Percent_population_vaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)) as 
Rolling_people_vaccinated
from Portfolio_Project.dbo.CovidDeaths$ as dea
join Portfolio_Project.dbo.CovidVaccinations as vac
    on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null

	select *,(Rolling_people_vaccinated/Population)*100
from #Percent_population_vaccinated

--- creating view to store data for later visualizations
drop view if exists Percent_population_vaccinated
create view Percent_population_vaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
(sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)) as 
Rolling_people_vaccinated
from Portfolio_Project.dbo.CovidDeaths$ as dea
join Portfolio_Project.dbo.CovidVaccinations as vac
    on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null


	select *
	from Percent_population_vaccinated
	
