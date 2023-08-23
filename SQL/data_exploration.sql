/*Covid 19 Data Exploration
Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--------------------------------------------------------------------------------------------------------------------------

select *
from covid_cases
where region is not null 
order by date, location

select country, total_vaccinations, new_vaccinations, total_cases, population
from covid_cases 
order by country, total_cases

--------------------------------------------------------------------------------------------------------------------------

/*Looking at New Cases vs Total Deaths*/

select country, date, new_cases, total_deaths,
    (new_cases/population)*100 as case_percentage
from covid_cases 
where country = 'United States'
order by country, date

--------------------------------------------------------------------------------------------------------------------------

/*Looking at Infection Rate vs Population*/

select region, date, population, new_cases, total_deaths,
    (new_cases/population)*100 as infection_rate
from covid_cases
where region = 'Asia'
order by region, date

--------------------------------------------------------------------------------------------------------------------------

/*Countries with Highest Recovery rate compared to Cases*/

select country, population, max(recovered_cases), 
    max(recovered_cases/total_cases)*100 as percent_population_recovered
from covid_cases
group by country, population
order by percent_population_recovered desc

--------------------------------------------------------------------------------------------------------------------------

/*Showing Regions with Highest Recovery Count per Population*/

select region, sum(recovered_cases) as total_recovery_count
from covid_cases
where region is not null
group by region
order by total_recovery_count desc

--------------------------------------------------------------------------------------------------------------------------

/*GLOBAL STATISTICS*/

select date, sum(new_cases) as total_new_cases, sum(new_deaths) as total_new_deaths,
    sum(new_deaths)/sum(new_cases)*100 as new_death_percentage
from covid_cases
where region is not null
group by date

--------------------------------------------------------------------------------------------------------------------------

/*Vaccination Analysis with Joins*/

select cc.region, cc.country, cc.date, cc.population, cv.new_vaccinations
from covid_cases cc
join covid_vaccinations cv
    on cc.country = cv.country
    and cc.date = cv.date
where cv.new_vaccinations is not null

--------------------------------------------------------------------------------------------------------------------------

/*Using Temp Table for Vaccination Analysis*/

drop temporary table if exists vaccination_analysis
create temporary table vaccination_analysis
(
Region varchar(255),
Country varchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric
)

insert into vaccination_analysis
select cc.region, cc.country, cc.date, cc.population, cv.new_vaccinations
from covid_cases cc
join covid_vaccinations cv
    on cc.country = cv.country
    and cc.date = cv.date
where cv.new_vaccinations is not null

select *, (New_Vaccinations/Population)*100 as vaccination_rate
from vaccination_analysis

--------------------------------------------------------------------------------------------------------------------------

/*Creating View for Vaccination Analysis*/

create or replace view vaccination_analysis as
select cc.region, cc.country, cc.date, cc.population, cv.new_vaccinations
from covid_cases cc
join covid_vaccinations cv
    on cc.country = cv.country
    and cc.date = cv.date
where cv.new_vaccinations is not null

--------------------------------------------------------------------------------------------------------------------------
