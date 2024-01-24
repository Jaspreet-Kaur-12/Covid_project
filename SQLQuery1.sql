Select * from CovidDeaths;


Select * from CovidDeaths where continent is not null order by 3,4;

---Select * from dbo.CovidVaccinations$ order by 3,4;

----Select Data that would be useful 
Select Location,date,total_cases, new_cases,total_deaths,
population from CovidDeaths where continent is not null order by 1,2;

---Looking at Total Cases vs Total Deaths 

Select Location,date,total_cases,total_deaths, 
(total_deaths/convert(float,total_cases))*100 as DeathPercentage
from CovidDeaths where location like '%canada%' 
and continent is not null order by 1,2;

----looking at total cases vs population 
----shows what percentage of population got covid

Select Location,date,total_cases,population, 
(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths 
---where location like '%canada%' 
order by 1,2;

-----looking at countries with Highest Infection Rate Compared to Population 

Select location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
from CovidDeaths 
where continent is not null
group by location,population
order by PercentPopulationInfected desc;

----Break things down by continent
----Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
--from CovidDeaths 
--where continent is null
--group by location
--order by TotalDeathCount desc;

----showing countries/continents with highest death count per population
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc;

----global numbers
Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_cases)*100
as DeathPercentage
from CovidDeaths 
---where location like '%canada%' 
where continent is not null 
---group by date
order by 1,2;


Select death.continent,death.location, 
death.date, death.population, vaccination.new_vaccinations,
sum(convert(int,vaccination.new_vaccinations)) 
over (partition by death.location order by death.location,death.Date) 
as RollingPeopleVaccinated
from CovidDeaths death
join CovidVaccination vaccination
on death.location=vaccination.location
and death.date= vaccination.date
where death.continent is not null 
order by 2,3;


----USE CTE

with PopvsVac( Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent,death.location, 
death.date, death.population, vaccination.new_vaccinations,
sum(convert(int,vaccination.new_vaccinations)) 
over (partition by death.location order by death.location,death.Date) 
as RollingPeopleVaccinated
from CovidDeaths death
join CovidVaccination vaccination
on death.location=vaccination.location
and death.date= vaccination.date
where death.continent is not null 
---order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


---Temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent, 
death.location, death.date, death.population, vaccination.new_vaccinations,
sum(convert(int,vaccination.new_vaccinations)) 
over (partition by death.location order by death.location,death.Date) 
as RollingPeopleVaccinated
from CovidDeaths death
join CovidVaccination vaccination
on death.location=vaccination.location
and death.date= vaccination.date
where death.continent is not null 
---order by 2,3

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


----creating view to store data for later visualization
Create View PercentPopulationVaccinated as 
select death.continent, 
death.location, death.date, death.population, vaccination.new_vaccinations,
sum(convert(int,vaccination.new_vaccinations)) 
over (partition by death.location order by death.location,death.Date) 
as RollingPeopleVaccinated
from CovidDeaths death
join CovidVaccination vaccination
on death.location=vaccination.location
and death.date= vaccination.date
where death.continent is not null 

Select * from PercentPopulationVaccinated;