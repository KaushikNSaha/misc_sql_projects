
select *
from Portfolio_Project..covid_deaths
order by 3,4;

select *
from Portfolio_Project..covid_deaths
Where location = 'India' and date < '2021-08-19'
order by 3,4;


select *
from Portfolio_Project..covid_vaccinations
order by 3,4;

-- Exploration

Select 
	location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..covid_deaths
Order by 1,2;

-- total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select 
	location, date, total_cases, total_deaths,
	(total_deaths / total_cases) * 100 as DeathPercentage
From Portfolio_Project..covid_deaths
Order by 1,2;

-- DeathPercentage in INDIA and Bangladesh

Select 
	location, date, total_cases, total_deaths,
	round((total_deaths / total_cases) * 100, 4) as DeathPercentage
From Portfolio_Project..covid_deaths
Where location IN ('India', 'Bangladesh') and date < '2021-08-19'
Order by 1,2;


-- looking at Total cases vs Population
-- shows what percentage of population got covid

Select 
	location, cast(date as date) date, population, total_cases, 
	(total_cases / population) * 100 as infected_pop
From Portfolio_Project..covid_deaths
Order by 1,2;


-- Affected Population in Bangladesh and India

Select 
	location, cast(date as date) date, population, total_cases, 
	(total_cases / population) * 100 as infected_pop
From Portfolio_Project..covid_deaths
Where location IN ('India', 'Bangladesh') and date < '2021-08-19'
Order by 1,2;

-- looking at countries with Highest Infection Rate compared to population

Select
	Location, Population,
	Max(total_cases) as HighestInfectionCount,
	Max((total_cases / population) * 100) as Infected_population
From Portfolio_Project..covid_deaths
-- Where location IN ('India', 'Bangladesh') and date < '2021-08-19'
Group by Location, population
Order by Infected_population DESC;


-- showing Countries with Highest Death Count per population

Select
	Location, 
	Max(cast(total_deaths as int)) as totaL_death_count
From Portfolio_Project..covid_deaths
where continent is not null
-- Where location IN ('India', 'Bangladesh') and date < '2021-08-19'
Group by Location
Order by totaL_death_count DESC;


-- showing continent with Highest Death Count per population

Select
	location, continent,
	Max(cast(total_deaths as int)) as totaL_death_count
From Portfolio_Project..covid_deaths
-- Where location IN ('India', 'Bangladesh')
where continent is null
Group by location, continent
Order by totaL_death_count DESC;

-- global numbers

-- per day
Select
	date, SUM(new_cases) as total_cases,
	Sum(cast(new_deaths as int)) as total_deaths,
	Sum(cast(new_deaths as int)) / SUM(new_cases) * 100 as death_percentage 
From Portfolio_Project..covid_deaths
where continent is not null
Group by date
order by 1,2;

-- total 

Select
	SUM(new_cases) as total_cases,
	Sum(cast(new_deaths as int)) as total_deaths,
	Sum(cast(new_deaths as int)) / SUM(new_cases) * 100 as total_death_percentage 
From Portfolio_Project..covid_deaths
where continent is not null
order by 1,2;



-- number for india

Select
	date, 
	new_cases,
	new_deaths,
	(cast(new_deaths as int) / new_cases) * 100 as death_percentage_per_day 
From Portfolio_Project..covid_deaths
where location = 'India' and date < '2021-08-19'
order by 1,2;

-- total for india

Select
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_death,
	SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as total_death_percentage 
From Portfolio_Project..covid_deaths
where location = 'India' and date < '2021-08-19'
order by 1,2;


-- number of icu patients, new deaths per day
-- no data for india

select 
	date,
	new_cases,
	icu_patients_per_million,
	new_deaths
From Portfolio_Project..covid_deaths
where location = 'India' and date < '2021-08-19'
order by 1,2;

-- Vaccinations
-- looking for Total Population vs Vaccinations

select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1, 2, 3;

-- total vaccinated people


select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3;

-- use cte

With popvsVac(Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as 
(
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2, 3
)
Select *, (RollingPeopleVaccinated/ Population)* 100 as percentage_vaccinated
From popvsVac

-- for india

select 
	dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) over (order by dea.date)
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'India' and dea.date < '2021-08-19'
order by 1, 2, 3;




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2, 3

Select *, (RollingPeopleVaccinated/ Population)* 100 as percentage_vaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) over (Partition By dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2, 3


select * 
From PercentPopulationVaccinated



-- people fully vaccinated in india

select 
	TOP (1) dea.date, dea.population,
	people_fully_vaccinated,
	cast(people_fully_vaccinated as int) / dea.population * 100 as percentage_fully_vacccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'India' and dea.date < '2021-08-19'
order by 1 desc;


-- Table for VIZ
-- total factors


select 
	dea.population as Total_population,
	SUM(dea.new_cases) as total_cases,
	SUM(cast(dea.new_deaths as int)) as total_deaths,
	SUM(cast(dea.new_deaths as int)) / SUM(dea.new_cases) * 100 as total_death_percentage,
	SUM(cast(vac.new_vaccinations as int)) as total_vaccinated,
	MAX(cast(people_fully_vaccinated as int)) / dea.population * 100 as percentage_people_fully_vaccinated
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'India' and dea.date < '2021-08-19'
group by dea.population;



-- time series datas
WITH time_series (Date, Population, HighestInfectionCount, PercentPopulationInfected,
total_vaccinated, PercentPopulationVaccinated, DeathCount) as 
(
select
	dea.date,
	dea.population,
	MAX(dea.total_cases) as HighestInfectionCount,
	Max(dea.total_cases/dea.population)* 100 as PercentPopulationInfected,
	MAX(cast(vac.total_vaccinations as int)) as total_vaccinated,
	MAX(cast(vac.total_vaccinations as int)/dea.population) * 100 as PercentPopulationVaccinated,
	MAX(dea.total_deaths) as DeathCount
From Portfolio_Project..covid_deaths dea
Join Portfolio_Project..covid_vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.location = 'India' and dea.date < '2021-08-19'
group by dea.date, dea.population
)
SELECT *, DeathCount/ HighestInfectionCount * 100 as DeathPerCases
FROM time_series;