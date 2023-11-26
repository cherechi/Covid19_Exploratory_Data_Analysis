--	Covid 19 Exploratory Data Analysis to ascertain the various Covid Metrics (Infections, Deaths, and Vaccinations) between January 2020 to July 24th 2022
--						Confirming table contents
select *
from dbo.CovidDeaths
where continent is not null
order by 3,
	4 --					Location, date, new_vaccinations, total_vaccinations 
select *
from dbo.CovidVaccinations
where continent is not null
order by 3,
	4;
--					Select Data for Analysis from Covid Deaths Table Bisquit main
select Location,
	date,
	population,
	COALESCE(new_cases, 0) as New_Cases,
	COALESCE(total_cases, 0) as Total_Cases,
	COALESCE(new_deaths, 0) as New_Deaths,
	COALESCE(total_deaths, 0) as Total_Deaths
from dbo.CovidDeaths
where continent is not null
order by 1,
	2;
--						Main Data Analysis On the Death table
---Query to find Total deaths per country
select Location,
	COALESCE(SUM(cast(new_deaths as int)), 0) as Total_Deaths
from dbo.CovidDeaths
where continent is not null
Group by Location
order by Total_Deaths DESC ---Query to Find Total Infection per Country
select Location,
	COALESCE(SUM(cast(New_cases as int)), 0) as Total_Infections
from dbo.CovidDeaths
where continent is not null
Group by Location
order by Total_Infections DESC --Query to Rank Countries by Death Count and show the Top 5 Countries
select Location,
	COALESCE(SUM(cast(new_deaths as int)), 0) as Total_Deaths,
	RANK () OVER (
		ORDER BY COALESCE(SUM(cast(new_deaths as int)), 0) DESC
	) Mortality_Ranking
from dbo.CovidDeaths
where continent is not null
Group by Location --Query to show the Top 5 Countries With Highest Deaths from Covid
select TOP 5 Location,
	COALESCE(SUM(cast(new_deaths as int)), 0) as Total_Deaths,
	RANK () OVER (
		ORDER BY COALESCE(SUM(cast(new_deaths as int)), 0) DESC
	) Mortality_Ranking
from dbo.CovidDeaths
where continent is not null
Group by Location --Query to Rank Countries by Infection Count and show the Top 5 Countries
select Location,
	COALESCE(SUM(cast(new_cases as int)), 0) as Total_Infections,
	RANK () OVER (
		ORDER BY COALESCE(SUM(cast(new_cases as int)), 0) DESC
	) Infections_Ranking
from dbo.CovidDeaths
where continent is not null
Group by Location --Query to show the Top 5 Countries With Highest Covid Infections
select top 5 Location,
	COALESCE(SUM(cast(new_cases as int)), 0) as Total_Infections,
	RANK () OVER (
		ORDER BY COALESCE(SUM(cast(new_cases as int)), 0) DESC
	) Infections_Ranking
from dbo.CovidDeaths
where continent is not null
Group by Location --- Query to find the daily %age death from Covid per country
select Location,
	date,
	COALESCE(total_cases, 0) as Daily_Total_Cases,
	COALESCE(total_deaths, 0) as Daily_deaths,
	COALESCE((total_deaths / total_cases) * 100, 0) as Percentage_Daily_Deaths
from dbo.CovidDeaths
where continent is not null
order by 1,
	2;
--- Query to find the daily Population percentage COVID infection per country
select Location,
	date,
	population,
	total_cases,
	(total_cases / population) * 100 as percentage_infections
from dbo.CovidDeaths
where continent is not null
order by 1,
	2;
--- Query to find the countries with the highest infection rate per population
select Location,
	population,
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases / population)) * 100 as percentage_infections
from dbo.CovidDeaths
where continent is not null
GROUP BY location,
	population
order by percentage_infections DESC;
----Query to find the countries with the highest death count
select Location,
	MAX(cast(total_deaths as int)) as HighestDeathCount
from dbo.CovidDeaths
where continent is not null
GROUP BY location
order by HighestDeathCount DESC;
----Query to find the countries with the highest death count vs population.
select Location,
	population,
	MAX(cast(total_deaths as int)) as HighestDeathCount,
	MAX((total_deaths / population)) * 100 as percentage_deaths
from dbo.CovidDeaths
where continent is not null
GROUP BY location,
	population
order by percentage_deaths DESC;
--							CONTINENTAL BREAKDOWN
--- Query to find the daily percentage death from Covid per Continent
select Location,
	date,
	COALESCE(total_cases, 0),
	COALESCE(total_deaths, 0),
	COALESCE((total_deaths / total_cases) * 100, 0) as percentage_deaths
from dbo.CovidDeaths
where continent is null
order by 1,
	2;
--- Query to find the daily Population percentage COVID infection per continent
select Location,
	date,
	population,
	COALESCE(total_cases, 0),
	COALESCE((total_cases / population) * 100, 0) as percentage_infections
from dbo.CovidDeaths
where continent is null
order by 1,
	2;
-- Query to find COVID Infections by Continents
select Location,
	sum(new_cases) as total_continent_cases
from dbo.CovidDeaths
where location = 'Europe'
	or location = 'Africa'
	or location = 'North America'
	or location = 'South America'
	or location = 'Asia'
	or location = 'Oceania'
	and continent is null
group by location --- Query to find Total Global COVID infection
	with cte as(
		select Location,
			sum(new_cases) as total_continent_cases
		from dbo.CovidDeaths
		where location = 'Europe'
			or location = 'Africa'
			or location = 'North America'
			or location = 'South America'
			or location = 'Asia'
			or location = 'Oceania'
			and continent is null
		group by location
	)
select sum(total_continent_cases) as total_global_cases
from cte -- Query to Find Each Continents Percentage of Global Cases.
	with cte as (
		select Sum(new_cases) as Total_Global_Cases
		from dbo.CovidDeaths
		where location = 'Europe'
			or location = 'Africa'
			or location = 'North America'
			or location = 'South America'
			or location = 'Asia'
			or location = 'Oceania'
			and continent is null
	)
select CovidDeaths.location,
	Round(
		(
			Sum(CovidDeaths.new_cases) / cte.Total_Global_Cases
		),
		3
	) * 100 as percentage_Covid_Cases
from CovidDeaths,
	cte
where CovidDeaths.location = 'Europe'
	or CovidDeaths.location = 'Africa'
	or CovidDeaths.location = 'North America'
	or CovidDeaths.location = 'South America'
	or CovidDeaths.location = 'Asia'
	or CovidDeaths.location = 'Oceania'
	and CovidDeaths.continent is null
group by CovidDeaths.location,
	cte.Total_Global_Cases
order by percentage_Covid_Cases desc ----Query to find the Continental death counts.
select Location,
	SUM(cast(new_deaths as int)) as total_Continent_Deaths
from dbo.CovidDeaths
where location = 'Europe'
	or location = 'Africa'
	or location = 'North America'
	or location = 'South America'
	or location = 'Asia'
	or location = 'Oceania'
	and continent is null
GROUP BY location
order by total_Continent_Deaths DESC;
----Query to find the Continent  death count vs continent's population.
select Location,
	population,
	MAX(cast(total_deaths as int)) as Death_Count,
	MAX((total_deaths / population)) * 100 as percentage_deaths
from dbo.CovidDeaths
where location = 'Europe'
	or location = 'Africa'
	or location = 'North America'
	or location = 'South America'
	or location = 'Asia'
	or location = 'oceania'
	and continent is null
GROUP BY location,
	population
order by percentage_deaths DESC;
----								GLOBAL COVID NUMBERS 
-- Query to find monthly global Covid Numbers.
select FORMAT(Date, 'yyyy-MM') as Date,
	COALESCE(sum(new_cases), 0) as TotalGlobalCases,
	COALESCE(sum(cast(new_deaths as int)), 0) as TotalGlobalDeaths
from dbo.CovidDeaths
where continent is not null
group by FORMAT(Date, 'yyyy-MM')
order by date -- Query to find overall global Covid Numbers.
select Sum(new_cases) as Total_Global_Cases,
	sum(cast(new_deaths as int)) as Total_Global_Deaths,
	sum(cast(new_deaths as int)) / Sum(new_cases) * 100 as Percentage_Global_Deaths
from dbo.CovidDeaths
where continent is not null
order by 1,
	2;
----- Query to combine both Covid Deaths  and Covid Vaccinations for further Analysis
select *
from dbo.CovidDeaths dea
	join dbo.CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
order by dea.location --Query to show Total Full vaccinations per country
select dea.Location,
	dea.Population,
	COALESCE(
		MAX(cast(vac.people_fully_vaccinated as bigint)),
		0
	) as Total_Full_vaccinations,
	COALESCE(
		(
			MAX(cast(vac.people_fully_vaccinated as bigint)) / population
		) * 100,
		0
	) as Percentage_fully_Vaccinated
from dbo.CovidDeaths dea
	join dbo.CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Group by dea.Location,
	dea.population
order by Total_Full_vaccinations DESC -- Query to find total people vaccinated as against the world population
select dea.continent,
	dea.location,
	dea.date,
	dea.population,
	COALESCE(vac.new_vaccinations, 0)
from dbo.CovidDeaths dea
	join dbo.CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,
	3;
--	Query to get total country population fully vaccinated 
select dea.location,
	COALESCE(
		MAX(cast(vac.people_fully_vaccinated as bigint)),
		0
	) as Total_Country_vaccinations
from dbo.CovidDeaths dea
	join dbo.CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.location
order by dea.location --	Query to get Global vaccination total
	with cte as (
		select location,
			COALESCE(MAX(cast(people_fully_vaccinated as bigint)), 0) as Total_Continent_vaccinations
		from dbo.CovidVaccinations
		where location = 'Europe'
			or location = 'Africa'
			or location = 'North America'
			or location = 'South America'
			or location = 'Asia'
			or location = 'Oceania'
			and continent is null
		group by location
	)
select sum(Total_Continent_vaccinations) as Total_Global_Vaccination
from cte -- Query to find monthly global vaccination numbers.
select FORMAT(dea.Date, 'yyyy-MM') as Date,
	COALESCE(sum(cast(vac.new_vaccinations as bigint)), 0) as TotalGlobal_vaccination,
	COALESCE(sum(cast(dea.new_deaths as bigint)), 0) as TotalGlobal_deaths
from dbo.CovidDeaths dea
	join dbo.CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by FORMAT(dea.Date, 'yyyy-MM')
order by date -- Query to find fully vaccinated population per Continent
select dea.Location,
	COALESCE(
		MAX(cast(vac.people_fully_vaccinated as bigint)),
		0
	) as total_Continent_vaccinations
from dbo.CovidDeaths dea
	join dbo.CovidVaccinations vac on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'Europe'
	or dea.location = 'Africa'
	or dea.location = 'North America'
	or dea.location = 'South America'
	or dea.location = 'Asia'
	or dea.location = 'Oceania'
	and dea.continent is null
GROUP BY dea.location
order by total_Continent_vaccinations DESC;
-- Query to find each continents percentage of global vaccinations
with continent as (
	select location,
		COALESCE(MAX(cast(people_fully_vaccinated as float)), 0) as Total_Continent_vaccinations
	from dbo.CovidVaccinations
	where location = 'Europe'
		or location = 'Africa'
		or location = 'North America'
		or location = 'South America'
		or location = 'Asia'
		or location = 'Oceania'
		and continent is null
	group by location
),
main as(
	select sum(Total_Continent_vaccinations) as Total_Global_Vaccination
	from continent
)
select continent.location,
	continent.Total_Continent_vaccinations,
	(
		continent.Total_Continent_vaccinations / main.Total_Global_Vaccination
	) as global_vaccination_percentage,
	main.Total_Global_Vaccination
from continent,
	main