CREATE DATABASE HumanResource;
GO
USE HumanResource;

--checking datatype
EXEC sp_help hrdb;

--add age column
ALTER TABLE hrdb
ADD age INT;

UPDATE hrdb
SET age = DATEDIFF(YEAR, birthdate, GETDATE());

--check youngest and oldest employee
SELECT MIN(age) AS 'Youngest Employee', 
	MAX(age) AS 'Oldest Employee'
FROM dbo.hrdb

--change termdate datatype
ALTER TABLE dbo.hrdb
ALTER COLUMN termdate varchar(255);

BEGIN TRAN
UPDATE dbo.hrdb
SET termdate = left(termdate,len(termdate)-4);

ALTER TABLE dbo.hrdb
ALTER COLUMN termdate SMALLDATETIME;

ROLLBACK;
COMMIT;

--ANALYSIS
--1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY gender;

--2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY race
ORDER BY 2 DESC;

--3. What is the age distribution of employees in the company?
SELECT
	CASE 
		WHEN age >= 18 AND age <=24 THEN '18-24'
		WHEN age >= 25 AND age <=34 THEN '25-34'
		WHEN age >= 35 AND age <=44 THEN '35-44'
		WHEN age >= 45 AND age <=54 THEN '45-54'
		WHEN age >= 55 AND age <=64 THEN '55-64'
		ELSE '65+'
	END AS age_group,
	COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY 
	CASE 
		WHEN age >= 18 AND age <=24 THEN '18-24'
		WHEN age >= 25 AND age <=34 THEN '25-34'
		WHEN age >= 35 AND age <=44 THEN '35-44'
		WHEN age >= 45 AND age <=54 THEN '45-54'
		WHEN age >= 55 AND age <=64 THEN '55-64'
		ELSE '65+'
	END
ORDER BY 1;

SELECT
	CASE 
		WHEN age >= 18 AND age <=24 THEN '18-24'
		WHEN age >= 25 AND age <=34 THEN '25-34'
		WHEN age >= 35 AND age <=44 THEN '35-44'
		WHEN age >= 45 AND age <=54 THEN '45-54'
		WHEN age >= 55 AND age <=64 THEN '55-64'
		ELSE '65+'
	END AS age_group,
	gender,
	COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY 
	CASE 
		WHEN age >= 18 AND age <=24 THEN '18-24'
		WHEN age >= 25 AND age <=34 THEN '25-34'
		WHEN age >= 35 AND age <=44 THEN '35-44'
		WHEN age >= 45 AND age <=54 THEN '45-54'
		WHEN age >= 55 AND age <=64 THEN '55-64'
		ELSE '65+'
	END,
	gender
ORDER BY 1,2;

--4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY location;

--5. What is the average length of employment for employees who have been terminated?
SELECT 
	ROUND(AVG(CAST(DATEDIFF(YEAR,hire_date, termdate) AS FLOAT)), 2) AS avg_employment_length
FROM dbo.hrdb
WHERE termdate <= GETDATE() AND termdate IS NOT NULL;

--6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY gender, department
ORDER BY 1, 2;

--7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY jobtitle
ORDER BY 1;

--8. Which department has the highest turnover rate?
SELECT 
	department, 
	hired_count,
	terminated_count,
	ROUND(CAST(terminated_count AS FLOAT) / CAST(hired_count AS FLOAT),4) AS termination_rate
FROM (
	SELECT 
		department, 
		COUNT(*) AS hired_count,
		SUM(
			CASE 
				WHEN  termdate <= GETDATE() AND termdate IS NOT NULL THEN 1
				ELSE 0
			END
		) AS terminated_count
	FROM dbo.hrdb
	GROUP BY department
) AS termination_in_deparment
ORDER BY 4 DESC;

--9. What is the distribution of employees across locations by state?
SELECT location_state, COUNT(*) AS employee
FROM dbo.hrdb
WHERE termdate >= GETDATE() OR termdate IS NULL
GROUP BY location_state
ORDER BY 2 DESC;

--10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
	[year], 
	total_hire,
	total_termination,
	total_hire - total_termination AS change,
	ROUND(CAST(total_hire - total_termination AS FLOAT)/CAST(total_hire AS FLOAT) * 100, 2) as percentage_change
FROM (
	SELECT
		YEAR(hire_date) AS [year],
		COUNT(*) AS total_hire,
		SUM(
			CASE 
				WHEN  termdate <= GETDATE() AND termdate IS NOT NULL THEN 1
				ELSE 0
			END
		) AS total_termination
	FROM dbo.hrdb
	GROUP BY YEAR(hire_date)
) AS total_hire_per_year
ORDER BY 1 DESC;

--11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(CAST(DATEDIFF(YEAR, hire_date, termdate) AS FLOAT)),2) AS avg_year
FROM dbo.hrdb
WHERE termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department
ORDER BY 2 DESC;

-- total employee per department
SELECT department, COUNT(*) AS Employee
FROM dbo.hrdb
WHERE termdate IS NOT NULL AND termdate <= GETDATE()
GROUP BY department
ORDER BY 2 DESC;
