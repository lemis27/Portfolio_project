
---- Totals cases vs total deaths
----Shows the likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
from CovidDeaths
where location = 'india' 
order by 1,2;

----Shows what percentage of population got covid.
select location,date,population,total_cases, (total_cases/population)*100 as TotalCovidCases
from CovidDeaths
order by 1,2;

--Looking at countries with highest Infection rate compared to population.
select location,population,Max(total_cases) as Highest_Infections,max(total_cases/population)*100 as TotalCovidCases
from CovidDeaths
where continent is not null
group by location,population
order by TotalCovidCases desc;


---Showing countries with highest death count per populations

select location,max(cast(total_deaths as int)) as Highest_deaths
from CovidDeaths
where continent is not null
group by location

order by Highest_deaths desc;


-----Lets break things down by Continent
select continent,max(cast(total_deaths as int)) as Highest_deaths
from CovidDeaths
where continent is not null
group by continent
order by Highest_deaths desc;


--Breaking global numbers;
select date, SUM(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_deaths,sum(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1 ,2;

--- Looking at total population Vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

---Looking at Vaccination percentage in your country
select dea.location,dea.date,dea.population,vac.total_vaccinations,(vac.total_vaccinations/dea.population)*100 as VaccinePercentage
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location= 'India'
order by VaccinePercentage desc;


---Looking at Highest Vaccination percentage in every country
select dea.location,MAX(cast(vac.total_vaccinations as int)) as totalVaccination
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
group by dea.location
order by totalVaccination desc;

-- Looking at total Population vs Vaccinations in India
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.location = 'india'
order by 2,3;



--- Use CTE

with popvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


)
select *, (RollingPeopleVaccinated/population)*100
from popvsVac



--- Temp Table

Drop table if exists #PercentPeopleVaccinated

create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPeopleVaccinated



---Views


create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths as dea
join CovidVaccinations$ as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null






