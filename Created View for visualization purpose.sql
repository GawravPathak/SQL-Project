--- Creating View

--- Death_Percent only India

Create View DeathPercent as
select location, population, max(total_cases) as Total_Cases, max(total_deaths) as Total_Deaths, round((max(total_deaths)/max(total_cases))*100,2) as Death_Percentage
from Portfolio_Project..CovidDeaths
--where total_deaths is not null and location = 'India' and continent is not null
where location = 'India'
group by location, population
order by population desc
OFFSET 0 ROWS;


--- Infection_Percent

Create View Infection_Percent as
Select location, population,  max(total_cases) as MaxCovidCases, round(Max(total_cases/population)*100,4) as InfectionPercentCount
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location,population
order by InfectionPercentCount desc
offset (0) rows;



--- Death_Percent (Country wise)

Create View Death_Percent as
Select location, max(total_deaths) as DeathCounts, round(max(total_deaths/total_cases)*100,4) as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by DeathCounts desc
offset (0) rows;



--- CasesandDeath_Counts

Create View CasesandDeath_Counts as
Select Continent, max(total_cases) as Infection_Counts, max(total_deaths) as Death_Counts from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by Death_Counts desc
offset (0) rows;


--- Global_Numbers

Create View Global_Numbers as
Select  Continent, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, round(sum(new_deaths)/sum(new_cases)*100,4) as Death_Percentage
from Portfolio_Project..CovidDeaths
where continent is not null
group By continent
order by 1,2
offset (0) rows;


--- Vaccination_Status

create view Vaccination_Status as
 With PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccination, Rolling_Vaccinations)
 as 
 (
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(CV.new_vaccinations) over (partition by cd.location order by cd.date) as Rolling_Vaccinations
from Portfolio_Project..CovidDeaths CD join Portfolio_Project..CovidVaccinations CV
on CD.location = CV.location and CD.date = CV.date
where cd.continent is not null and new_vaccinations is not null
--order by 2,3;
)

Select Location, Population,
Max(round((Rolling_Vaccinations/Population)*100,4)) as Vaccination_Percent
from PopulationVsVaccinations
where Continent is not null
group by Location, Population
order by 2 desc
offset (0) rows;




--- We can see here the view that is created and later on we can import that in visualization tools.
Select * from Vaccination_Status;
Select * from CasesandDeath_Counts;
Select * from Infection_Percent
Select * from Global_Numbers
Select * from Death_Percent; --- Whole world
Select * from DeathPercent; -- Only India
Select * from Vaccination_Status;