select * from covid_deaths$
select * from covid_vaccinations$

--likelihood of dying if infected in a country 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as 
death_percentage  from covid_deaths$ where location=' india' order by 1,2

--looking at total cases vs population 
select location,date,total_cases,population,(total_cases/population)*100 as 
contracted from covid_deaths$ where location='india' order by 1,2

---looking at countries with heightest infection rate compared to population 
select location,population,max(total_cases) as HighestInfectionCount ,
max((total_cases/population))*100 as 
PercentPopulationAffected from covid_deaths$ 
group by location,population order by PercentPopulationAffected desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as HighestDeaths 
from covid_deaths$ where continent is not null
group by location order by HighestDeaths desc


---Lets break things down by continent 
select continent,max(cast(total_deaths as int)) as HighestDeaths 
from covid_deaths$ where continent is not null
group by continent order by HighestDeaths desc

---breaking global numbers
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from covid_deaths$ where continent is not null --group by date 
order by 1,2

---use cte
With PopvsVac (continent,location,date,population,new_vaccinations,
RollingVaccinatedAtLocation)
as 
(
--Looking total population vs vaccinations
select dea.continent,dea.location ,dea.date,dea.population ,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order 
by dea.location,dea.date) as 
RollingVaccinatedAtLocation
from covid_vaccinations$ as vac join covid_deaths$ as dea 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

select distinct(location),population,max(RollingVaccinatedAtLocation) as Total_vaccinated,(max(RollingVaccinatedAtLocation)/population)*100 
as TotalVaccinatedPopluation from PopvsVac
group by location,population order by TotalVaccinatedPopluation desc,population desc


---Temp Table 
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingVaccinatedAtLocation numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location ,dea.date,dea.population ,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order 
by dea.location,dea.date) as 
RollingVaccinatedAtLocation
from covid_vaccinations$ as vac join covid_deaths$ as dea 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *,(RollingVaccinatedAtLocation/population)*100 
as TotalVaccinatedPopluationPercent from #PercentPopulationVaccinated 


--creating view 
create view PercentPopVaccinated as
select dea.continent,dea.location ,dea.date,dea.population ,vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order 
by dea.location,dea.date) as 
RollingVaccinatedAtLocation
from covid_vaccinations$ as vac join covid_deaths$ as dea 
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopVaccinated
