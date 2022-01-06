SELECT location,
	   date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


SELECT location,
	   date,
	   total_cases,
	   total_deaths,
	   ((total_deaths::numeric(8,1)) / total_cases) * 100 AS death_pct
FROM covid_deaths
WHERE location ILIKE '%states%' 
	AND continent IS NOT NULL
ORDER BY 1,2;

SELECT location,
	   date,
	   total_cases,
	   Population,
	   ((total_cases::numeric(10,1)) / Population) * 100 AS pct_population_infected
FROM covid_deaths
WHERE location ILIKE '%states%' 
	AND continent IS NOT NULL
ORDER BY 1,2;


SELECT location,
	   Population,
	   max(total_cases) AS highest_infection_count,
	   max((total_cases::numeric(10,1)) / Population) * 100 AS pct_population_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY pct_population_infected;


SELECT location,
	   max(total_deaths) AS highest_total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING max(total_deaths) IS NOT NULL
ORDER BY max(total_deaths) DESC;

SELECT location,
	   max(total_deaths) AS highest_total_deaths
FROM covid_deaths
WHERE continent IS NULL
	AND (location <> 'Upper middle income' AND  
		 location <> 'High income' AND location <> 'Lower middle income' AND
		 location <> 'Low income')
GROUP BY location
ORDER BY max(total_deaths) DESC;

SELECT continent,
	   max(total_deaths::int) AS highest_total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_total_deaths DESC;


SELECT 
	   sum(new_cases) AS total_cases,
	   sum(new_deaths) AS total_deaths,
	   sum(new_deaths) / sum(New_cases) * 100 AS death_pct
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


SELECT * FROM covid_vaccination;

SELECT * 
FROM covid_deaths cd JOIN covid_vaccination cv
ON cd.location = cv.location
	AND cd.date = cv.date;
	

SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.Population,
	   cv.new_vaccinations
FROM covid_deaths cd JOIN covid_vaccination cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   sum(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM covid_deaths cd JOIN covid_vaccination cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3;


WITH 
	Pop_vs_Vac(Continent, Location, Date, Population, New_Vaccination, rolling_people_vaccinated)
	AS (
		SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		sum(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
		FROM covid_deaths cd JOIN covid_vaccination cv
		ON cd.location = cv.location
			AND cd.date = cv.date
		WHERE cd.continent IS NOT NULL
	)
SELECT *,
	   (rolling_people_vaccinated/Population) * 100 AS pct_of_rolled_people_vaccinated
FROM Pop_vs_Vac;


CREATE OR REPLACE VIEW Percent_Population_Vaccinated AS 
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	sum(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_People_Vaccinated
FROM covid_deaths cd JOIN covid_vaccination cv
ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL; 
	

SELECT * FROM Percent_Population_Vaccinated;


