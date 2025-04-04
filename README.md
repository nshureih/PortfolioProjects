# SQL Portfolio Projects

## Project 1: COVID-19 Data Analysis
**Technologies**: BigQuery, SQL  
**Dataset**: Our World in Data COVID-19 dataset (public)  

**Key Skills**:  
- Complex joins between vaccination/death tables  
- Window functions (`OVER PARTITION BY`) for rolling calculations  
- Temporary tables and CTEs  
- Continent-level aggregation  

**Code Highlight**:  
```sql
-- Rolling vaccination percentage by country
WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (
      PARTITION BY dea.location 
      ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, 
  (RollingPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopvsVac;
```

## Project 2: Nashville Housing Data Cleaning
**Technologies:** BigQuery, SQL
**Dataset:** Public Nashville housing records

**Key Skills:**
- Address parsing with SPLIT()
- NULL handling with self-joins
- Duplicate removal using ROW_NUMBER()
- Schema modifications (ADD/DROP COLUMN)
- Code Highlight:

**Code Highlight**:  
```sql
-- Normalize property addresses into street/city
UPDATE Housing_Data
SET 
  PropertyStreetAddress = SPLIT(PropertyAddress, ',')[OFFSET(0)], 
  PropertyCity = SPLIT(PropertyAddress, ',')[OFFSET(1)]
WHERE PropertyAddress IS NOT NULL;
```
