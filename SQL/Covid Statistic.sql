select *
from CovidDeaths
order by 3,4;

select *
from CovidVaccinations
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2;

-- Death Percentage
select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%israel%'
order by 1, 2;

-- Cases Percentage
select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from CovidDeaths
where location like '%thailand%'
order by 1, 2;

-- Countries that have highest infected rate
select location, population, max(total_cases) as highest_Infected, max((total_cases/population)*100) as InfectedRate
from CovidDeaths
group by location, population
order by 4 desc;

-- Countries that have highest deaths
select location, max(cast(total_deaths as int)) as highest_deaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc;

-- Continent that have highest deaths
select continent, max(cast(total_deaths as int)) as highest_deaths
from CovidDeaths
where continent is not null
group by continent
order by 2 desc;

-- Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2;

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1, 2;



select *
from CovidVaccinations;

-- Vaccination rate
select deaths.continent, deaths.location, deaths.date, deaths.population, vacci.new_vaccinations
, (vacci.new_vaccinations/deaths.population)*100 as VaccinationRate
from CovidDeaths as deaths
join CovidVaccinations as vacci
	on deaths.location = vacci.location
	and deaths.date = vacci.date
where deaths.continent is not null
order by 2, 3;	

-- Vaccination counts
select deaths.continent, deaths.location, deaths.date, deaths.population, vacci.new_vaccinations
, sum(cast(vacci.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date) as RollingVaccinated
from CovidDeaths as deaths
join CovidVaccinations as vacci
	on deaths.location = vacci.location
	and deaths.date = vacci.date
where deaths.continent is not null
order by 2, 3;

-- female, male smoker
select location, sum(female_smokers) as female_smokers, sum(male_smokers) as male_smokers
from CovidVaccinations
where continent is not null
and female_smokers is not null or male_smokers is not null
group by location
order by 1;

select location, date, female_smokers, male_smokers
, cardiovasc_death_rate
from CovidVaccinations
where continent is not null
and female_smokers is not null or male_smokers is not null
--group by location
order by 1;

-- Use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as(
select deaths.continent, deaths.location, deaths.date, deaths.population, vacci.new_vaccinations
, sum(cast(vacci.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingVaccinated
from CovidDeaths as deaths
join CovidVaccinations as vacci
	on deaths.location = vacci.location
	and deaths.date = vacci.date
where deaths.continent is not null
--order by 2, 3
)
select *, (RollingVaccinated/Population)*100 as VaccinatedPercentage
from PopvsVac
order by 7 desc;

-- Temp table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinated numeric
)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vacci.new_vaccinations
, sum(cast(vacci.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingVaccinated
from CovidDeaths as deaths
join CovidVaccinations as vacci
	on deaths.location = vacci.location
	and deaths.date = vacci.date
where deaths.continent is not null
--order by 2, 3

select *, (RollingVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated;



drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinated numeric
)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vacci.new_vaccinations
, sum(cast(vacci.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingVaccinated
from CovidDeaths as deaths
join CovidVaccinations as vacci
	on deaths.location = vacci.location
	and deaths.date = vacci.date
--where deaths.continent is not null
--order by 2, 3

select *, (RollingVaccinated/Population)*100 as VaccinatedPercentage
from #PercentPopulationVaccinated


-- Create views
create view PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vacci.new_vaccinations
, sum(cast(vacci.new_vaccinations as int)) over (partition by deaths.location order by deaths.location, deaths.date)
as RollingVaccinated
from CovidDeaths as deaths
join CovidVaccinations as vacci
	on deaths.location = vacci.location
	and deaths.date = vacci.date
where deaths.continent is not null
--order by 2, 3

