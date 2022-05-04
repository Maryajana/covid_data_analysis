select *
from portfolio_project..covid_deaths$
order by 3,4

select *
from portfolio_project..covid_vaccination$
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..covid_deaths$
order by 1,2;

-- Total cases vs Total deaths--
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..covid_deaths$
where location like '%states%'
order by 1,2;

---total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as covid_case_percentage
from portfolio_project..covid_deaths$
order by 1,2;

---countries with highest infection rate 
select location, Max(total_cases) as highestinfection, population, Max((total_cases/population))*100 as covid_case_percentage
from portfolio_project..covid_deaths$
group by location, population
order by covid_case_percentage desc;

---showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as deathcount
from portfolio_project..covid_deaths$
where continent is not null
group by location
order by deathcount desc;

---breakdown by Continent


---showing continents with the highest death count per population
select location, max(cast(total_deaths as int)) as deathcount
from portfolio_project..covid_deaths$
where continent is null
group by Location
order by deathcount desc;

----Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from portfolio_project..covid_deaths$
where continent is not null
--group by date
order by 1,2;
--- total population vs total vaccination

select PPCD.continent, PPCD.location, PPCD.date, PPCD.population, PPCV.new_vaccinations,
SUM(CAST(PPCV.new_vaccinations AS BIGINT)) OVER (PARTITION BY PPCD.location)
from portfolio_project..covid_deaths$ PPCD
join portfolio_project..covid_vaccination$ PPCV
 On PPCD.location = PPCV.location
 and PPCD.date = PPCV.date
 where PPCD.continent is NOT null
 order by 2,3;
 --OR
 select PPCD.continent, PPCD.location, PPCD.date, PPCD.population, PPCV.new_vaccinations,
SUM(CONVERT(bigint, PPCV.new_vaccinations )) OVER (PARTITION BY PPCD.location ORDER BY PPCD.LOCATION,
PPCD.DATE) AS VAC_PEOPLE
from portfolio_project..covid_deaths$ PPCD
join portfolio_project..covid_vaccination$ PPCV
 On PPCD.location = PPCV.location
 and PPCD.date = PPCV.date
 where PPCD.continent is NOT null
 order by 2,3;
---total cases vs Total deaths after Vaccination


--cte
with people_vaccinated (continent, location, date, population, new_vaccination, VAC_PEOPLE)
as
(select PPCD.continent, PPCD.location, PPCD.date, PPCD.population, PPCV.new_vaccinations,
SUM(CONVERT(bigint, PPCV.new_vaccinations )) OVER (PARTITION BY PPCD.location ORDER BY PPCD.LOCATION,
PPCD.DATE) AS VAC_PEOPLE
from portfolio_project..covid_deaths$ PPCD
join portfolio_project..covid_vaccination$ PPCV
 On PPCD.location = PPCV.location
 and PPCD.date = PPCV.date
 where PPCD.continent is NOT null
 --order by 2,3
 )
 select *, (VAC_PEOPLE/population)*100 as people_vac
 from people_vaccinated

 --temp table
 Drop table if exists percent_vaccinated

 create table percent_vaccinated
 ( continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccination numeric,
 VAC_PEOPLE numeric);


 insert into percent_vaccinated
 select PPCD.continent, PPCD.location, PPCD.date, PPCD.population, PPCV.new_vaccinations,
SUM(CONVERT(bigint, PPCV.new_vaccinations )) OVER (PARTITION BY PPCD.location ORDER BY PPCD.LOCATION,
PPCD.DATE) AS VAC_PEOPLE
from portfolio_project..covid_deaths$ PPCD
join portfolio_project..covid_vaccination$ PPCV
 On PPCD.location = PPCV.location
 and PPCD.date = PPCV.date
 where PPCD.continent is NOT null
 --order by 2,3

  select *, (VAC_PEOPLE/population)*100 as people_vac
 from percent_vaccinated;

 ----creating view
 create view percent_vaccine as
 select PPCD.continent, PPCD.location, PPCD.date, PPCD.population, PPCV.new_vaccinations,
SUM(CONVERT(bigint, PPCV.new_vaccinations )) OVER (PARTITION BY PPCD.location ORDER BY PPCD.LOCATION,
PPCD.DATE) AS VAC_PEOPLE
from portfolio_project..covid_deaths$ PPCD
join portfolio_project..covid_vaccination$ PPCV
 On PPCD.location = PPCV.location
 and PPCD.date = PPCV.date
 where PPCD.continent is NOT null
 --order by 2,3;

 select *
 from percent_vaccine