
--- syntax to know the schema of the Database.
--SELECT 
--TABLE_CATALOG,
--TABLE_SCHEMA,
--TABLE_NAME,
--COLUMN_NAME,
--DATA_TYPE
--FROM INFORMATION_SCHEMA.COLUMNS ;


--- Data that we needed to get insights from.

select location,date, new_cases, total_cases, total_deaths,population
from Portfolio_Project..CovidDeaths
where continent is not null
order by 2,3;


-- What is the likelihood of dying if you contract COVID-19 in your country?

select location, population, max(total_cases) as Total_Cases, max(total_deaths) as Total_Deaths, round((max(total_deaths)/max(total_cases))*100,2) as Death_Percentage
from Portfolio_Project..CovidDeaths
--where total_deaths is not null and location = 'India' and continent is not null
where location = 'India'
group by location, population
order by 1,2;




--- Sort the data according to the country having highest Covid_19 cases.

Select location, population,  max(total_cases) as MaxCovidCases, round(Max(total_cases/population)*100,4) as InfectionPercentCount
from Portfolio_Project..CovidDeaths
where continent is not null
Group by location,population
order by InfectionPercentCount desc;


--- List the Countries having highest death percentage.

Select location, max(total_deaths) as DeathCounts, round(max(total_deaths/total_cases)*100,4) as DeathPercentage
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by DeathCounts desc;


--- Highest Cases and Death Counts by Continents

Select Continent, max(total_cases) as Infection_Counts, max(total_deaths) as Death_Counts from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by Death_Counts desc;


--- Global Numbers accross the continents
--- Total Cases and Deaths in the World.

Select  Continent, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, round(sum(new_deaths)/sum(new_cases)*100,4) as Death_Percentage
from Portfolio_Project..CovidDeaths
where continent is not null
group By continent
order by 1,2;



--- Checking Vaccination Status

--- Lets join CovidDeaths table with CovidVaccinations on the basis of locations and dates

Select * from Portfolio_Project..CovidDeaths CD join Portfolio_Project..CovidVaccinations CV
on CD.location = CV.location and CD.date = CV.date


--- Total Population VS Total Vaccinations.

--- partitioned by location withthin that location it will be partition by date so it will add up every new vaccination for current date with the consecutive dates.

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(CV.new_vaccinations) over (partition by cd.location order by cd.date) as Rolling_Vaccinations
from Portfolio_Project..CovidDeaths CD join Portfolio_Project..CovidVaccinations CV
on CD.location = CV.location and CD.date = CV.date
where cd.continent is not null and new_vaccinations is not null
order by 2,3;


--- What is the Vaccinations Percentage accross the countries.

--- Here we are storing that data in the CTEs for process the data further, you can also do that by creating a Temperory table.

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
order by 2 desc;


-- or Using Temporary Table.

Drop table if exists #temp_table
Create Table #Temp_table
(
	Continents varchar(255),
	Countries varchar(255),
	DDate datetime,
	Population numeric,
	Newvaccination numeric,
	RollingVaccinations float	
)

insert into #Temp_table

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
sum(CV.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as Rolling_Vaccinations
from Portfolio_Project..CovidDeaths CD join Portfolio_Project..CovidVaccinations CV
on CD.location = CV.location and CD.date = CV.date
where cd.continent is not null and new_vaccinations is not null
order by 2,3;


Select Countries, Population,
round(max(RollingVaccinations/Population*100),4) as Vaccination_Percent
from #Temp_table
group by Countries, Population
order by 2 desc;
