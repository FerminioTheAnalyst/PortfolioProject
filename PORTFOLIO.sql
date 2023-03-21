SELECT *
FROM PortfolioProject..CovidDeaths 
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations 
--ORDER BY 3,4

--SELECT DATA TO BE USED 

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths 
ORDER BY 1,2 

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (TRY_CAST(total_deaths AS decimal)/ total_cases) *100 as DeathPercentaga
FROM PortfolioProject..CovidDeaths 
where location like '%NIGERIA%'
ORDER BY 1,2 


-- LOOKING AT THE TOTAL CASES VS THE POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population, total_cases,  (total_cases/population) *100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
--where location like '%NIGERIA%'
ORDER BY 1,2 


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION


SELECT location, population, MAX(total_cases) AS HighestInfectioCount,  MAX((total_cases/population)) *100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- SHOWING THE COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC 


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SuM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
----where location like '%NIGERIA% 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 



SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
    CASE WHEN SUM(new_cases) = 0 THEN NULL ELSE SUM(cast(new_deaths as int))/SuM(new_cases)*100 END as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
--(CummulativeVaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3



--- USING CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, CummulativeVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
--(CummulativeVaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
Select *, (CummulativeVaccinations/Population)*100
From PopvsVac


--- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
cummulativeVaccinations numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
--(CummulativeVaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3
Select *, (CummulativeVaccinations/Population)*100
From #PercentPopulationVaccinated



--- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinations
--(CummulativeVaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date =  vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3


Select *
From PercentPopulationVaccinated