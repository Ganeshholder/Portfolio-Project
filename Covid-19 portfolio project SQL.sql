select *
from Portfolio..CovidDeath
where continent is not null
order by 3,4

--Total cases Vs Total Deaths in India daily

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeath
where location like '%india%'
order by 1,2

--Total cases Vs Population in India

select location, date, total_cases, population, (total_cases/population)*100 as PositivePercentage
from Portfolio..CovidDeath
where location like '%india%'
order by 1,2

--Highest POSITIVE percentage in every location

select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as PositivePercentage
from Portfolio..CovidDeath
group by location, population
order by PositivePercentage desc

--Highest Death count in every location

select location, MAX(CAST(total_deaths as int)) as HighestDeathCount
from Portfolio..CovidDeath
where continent is null
group by location
order by HighestDeathCount desc

--highest Death count in every continent

select continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
from Portfolio..CovidDeath
where continent is not null
group by continent
order by HighestDeathCount desc

--Worldwide Death percentage

select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Portfolio..CovidDeath
where continent is not null
order by DeathPercentage

--Vaccine

select *
from Portfolio..CovidVacination

--Worldwide population vaccinated

select SUM(dea.population) as TotalPoplation , SUM(CAST(vac.new_vaccinations as bigint)) as PeopleVaccinated
from Portfolio..CovidDeath as dea join Portfolio..CovidVacination as vac on (dea.location=vac.location) and (dea.date=vac.date)
--where  vac.people_fully_vaccinated is not null
--group by vac.people_fully_vaccinated

--Total population Vs Vaccination

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from Portfolio..CovidDeath as dea join Portfolio..CovidVacination as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--CTE

with PopVsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from Portfolio..CovidDeath as dea join Portfolio..CovidVacination as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *
from PopVsVac

--Temp Table


drop table PercentagePeopleVaccinated
create table PercentagePeopleVaccinated
(
continent nvarchar(255),location nvarchar(225), date datetime, population numeric, new_vaccinations numeric, PeopleVaccinated numeric
)
insert into PercentagePeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
from Portfolio..CovidDeath as dea join Portfolio..CovidVacination as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3
select *, (PeopleVaccinated/population)*100
from PercentagePeopleVaccinated

--Create View

create view PercentagePeopleVaccinated2 as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from Portfolio..CovidDeath as dea join Portfolio..CovidVacination as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
