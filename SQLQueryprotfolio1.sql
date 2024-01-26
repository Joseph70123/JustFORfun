
--Select *
--from Portfolio_covid..Coviddeaths
--order by 3,4

--Select *
--from Portfolio_covid..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_covid..Coviddeaths
where continent is not null
order by 1,2


--total_cases v/s totaldeaths

SELECT
    Location,
    date,
    total_cases,
    total_deaths,
    (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS mortality_rate
FROM Portfolio_covid..Coviddeaths
Where Location (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) *100 <1 and continent is not null
 order by 1, 2

--LOKKING AT TOTAL CASES VS POPULATION
--THIS SHOWS AS WHAT PERCENTAGE OF POPULATION GOT COVID

Select Location, date, Population, total_cases, (CONVERT(float, total_cases)/CONVERT(float, Population)) * 100 as infection_rate
From Portfolio_covid..Coviddeaths
where Lower(Location) like '%china%'
order by 1,2

--Looking at countries at highest infection rates 

Select Location, Population, MAX(total_cases)as 
max_total_cases, MAX((CONVERT(float, total_cases)/CONVERT(float, Population))) * 100 as MAX_infection_rate
From Portfolio_covid..Coviddeaths
where continent is not null
Group by Location, Population 
order by MAX_infection_rate desc

--Showing countries with highest death count per population

Select Location, Population, MAX(cast (total_deaths as int))as max_total_deaths, MAX((convert(float,total_deaths)/convert(float, population)))*100 as max_death_count_per_population
From Portfolio_covid..Coviddeaths
where continent is not null
Group by Location, Population 
order by max_death_count_per_population desc

--GLOBAL NUMBERS

Select date, SUM(CAST(new_cases as int))as total_cases_globally, SUM (cast(new_deaths as int))as total_deaths_globally,((SUM (cast(new_deaths as float )))/(SUM(CAST(new_cases as float ))))*100 as death_percentage_globally
From Portfolio_covid..Coviddeaths
where continent is not null
Group by date 
order by 1,2


SELECT
    date,
    SUM(CAST(new_cases AS INT)) AS daily_total_cases_globally,
    SUM(CAST(new_deaths AS INT)) AS daily_total_deaths_globally,
    (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))) * 100 AS daily_death_percentage_globally
FROM Portfolio_covid..Coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

--lokking at total populations 
SELECT dea.continent  , dea.location , dea.date , dea.population ,vac.new_vaccinations
from Portfolio_covid ..Coviddeaths dea
join Portfolio_covid ..CovidVaccinations vac
     on dea.location= vac.location 
	 and dea.date = vac.date
WHERE dea.continent IS NOT NULL
order by 2,3

-- looking at total population vs vaccinations
--SELECT dea.continent  , dea.location , dea.date , dea.population ,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int) OVER (Partition by dea.Location)
--from Portfolio_covid ..Coviddeaths dea
--join Portfolio_covid ..CovidVaccinations vac
--     on dea.location= vac.location 
--	 and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--order by 2,3

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.Location ORDER BY dea.date) AS cumulative_vaccinations
FROM Portfolio_covid..Coviddeaths AS dea
JOIN Portfolio_covid..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

--NOW TO FIND TOTAL VACCINATED PERCENTAGE
--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint ,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
   FROM Portfolio_covid..Coviddeaths AS dea
JOIN Portfolio_covid..CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

CREATE TABLE population_vs_vaccinations
( continent varchar 255,
location varchar 55
date dob
population int 16
new vaccination




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint ,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
   FROM Portfolio_covid..Coviddeaths AS dea
JOIN Portfolio_covid..CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Create the population_vs_vaccinations table

DROP Table if exists population_vs_vaccinations
CREATE TABLE population_vs_vaccinations (
    continent varchar(255),
    location varchar(55),
    date date,
    population int,
    new_vaccination int,
    RollingPeopleVaccinated bigint -- Assuming it's a bigint
);

-- Populate the population_vs_vaccinations table with data
INSERT INTO population_vs_vaccinations (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio_covid..Coviddeaths AS dea
JOIN Portfolio_covid..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Calculate the percentage of rolling people vaccinated
SELECT *,
    (RollingPeopleVaccinated * 100.0 / population) AS PercentagePeopleVaccinated
FROM population_vs_vaccinations;




--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS:

Create View Population_vs_vaccinations1 as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio_covid..Coviddeaths AS dea
JOIN Portfolio_covid..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

