CREATE SCHEMA IF NOT EXISTS ndap;
use ndap;

CREATE TABLE IF NOT EXISTS FarmersInsuranceData (
    rowID INT PRIMARY KEY,
    srcYear INT,
    srcStateName VARCHAR(255),
    srcDistrictName VARCHAR(255),
    InsuranceUnits INT,
    TotalFarmersCovered INT,
    ApplicationsLoaneeFarmers INT,
    ApplicationsNonLoaneeFarmers INT,
    InsuredLandArea FLOAT,
    FarmersPremiumAmount FLOAT,
    StatePremiumAmount FLOAT,
    GOVPremiumAmount FLOAT,
    GrossPremiumAmountToBePaid FLOAT,
    SumInsured FLOAT,
    PercentageMaleFarmersCovered FLOAT,
    PercentageFemaleFarmersCovered FLOAT,
    PercentageOthersCovered FLOAT,
    PercentageSCFarmersCovered FLOAT,
    PercentageSTFarmersCovered FLOAT,
    PercentageOBCFarmersCovered FLOAT,
    PercentageGeneralFarmersCovered FLOAT,
    PercentageMarginalFarmers FLOAT,
    PercentageSmallFarmers FLOAT,
    PercentageOtherFarmers FLOAT,
    YearCode INT,
    Year_ VARCHAR(255),
    Country VARCHAR(255),
    StateCode INT,
    DistrictCode INT,
    TotalPopulation INT,
    TotalPopulationUrban INT,
    TotalPopulationRural INT,
    TotalPopulationMale INT,
    TotalPopulationMaleUrban INT,
    TotalPopulationMaleRural INT,
    TotalPopulationFemale INT,
    TotalPopulationFemaleUrban INT,
    TotalPopulationFemaleRural INT,
    NumberOfHouseholds INT,
    NumberOfHouseholdsUrban INT,
    NumberOfHouseholdsRural INT,
    LandAreaUrban FLOAT,
    LandAreaRural FLOAT,
    LandArea FLOAT
);

SHOW TABLES;
SELECT * FROM FarmersInsuranceData;


LOAD DATA LOCAL INFILE '/Users/debojeetbasu/Downloads/cleaned_data.csv'
INTO TABLE FarmersInsuranceData
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW WARNINGS LIMIT 10;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

SELECT COUNT(*) FROM FarmersInsuranceData;

SELECT *
FROM FarmersInsuranceData
WHERE PercentageMaleFarmersCovered IS NULL
   OR PercentageFemaleFarmersCovered IS NULL;


-- ----------------------------------------------------------------------------------------------

-- 	Retrieve the names of all states (srcStateName) from the dataset.


SELECT DISTINCT srcStateName
FROM FarmersInsuranceData;


-- Retrieve the total number of farmers covered (TotalFarmersCovered) 
-- and the sum insured (SumInsured) for each state (srcStateName), ordered by TotalFarmersCovered in descending order.


SELECT 
srcStateName,
SUM(TotalFarmersCovered) AS TotalFarmersCovered,
SUM(SumInsured) AS TotalSumInsured
FROM 
FarmersInsuranceData
GROUP BY 
srcStateName
ORDER BY 
TotalFarmersCovered DESC;


-- Filtering Data 

-- Retrieve all records where Year is '2020'.


SELECT *
FROM FarmersInsuranceData
WHERE Year_ = '2020';


-- 	Retrieve all rows where the TotalPopulationRural is greater than 1 million and the srcStateName is 'HIMACHAL PRADESH'.


SELECT *
FROM FarmersInsuranceData
WHERE TotalPopulationRural > 1000000
AND srcStateName = 'HIMACHAL PRADESH';
  

-- Retrieve the srcStateName, srcDistrictName, and the sum of FarmersPremiumAmount for each district in the year 2018, 
-- and display the results ordered by FarmersPremiumAmount in ascending order.


SELECT 
srcStateName,
srcDistrictName,
SUM(FarmersPremiumAmount) AS TotalFarmersPremium
FROM 
FarmersInsuranceData
WHERE 
Year_ = '2018'
GROUP BY 
srcStateName, srcDistrictName
ORDER BY 
TotalFarmersPremium ASC;


-- Retrieve the total number of farmers covered (TotalFarmersCovered) and the sum of premiums (GrossPremiumAmountToBePaid) for each state (srcStateName) 
-- where the insured land area (InsuredLandArea) is greater than 5.0 and the Year is 2018.


SELECT 
srcStateName,
SUM(TotalFarmersCovered) AS TotalFarmersCovered,
SUM(GrossPremiumAmountToBePaid) AS TotalPremium
FROM 
FarmersInsuranceData
WHERE 
InsuredLandArea > 5.0
AND Year_ = '2018'
GROUP BY 
srcStateName;
	  

-- Aggregation

-- Calculate the average insured land area (InsuredLandArea) for each year (srcYear).


SELECT 
srcYear,
AVG(InsuredLandArea) AS AvgInsuredLand
FROM 
FarmersInsuranceData
GROUP BY 
srcYear;


-- Calculate the total number of farmers covered (TotalFarmersCovered) for each district (srcDistrictName) where Insurance units is greater than 0.


SELECT 
srcDistrictName,
SUM(TotalFarmersCovered) AS TotalFarmersCovered
FROM 
FarmersInsuranceData
WHERE 
InsuranceUnits > 0
GROUP BY 
srcDistrictName;


-- For each state (srcStateName), calculate the total premium amounts (FarmersPremiumAmount, StatePremiumAmount, GOVPremiumAmount) 
-- and the total number of farmers covered (TotalFarmersCovered). Only include records where the sum insured (SumInsured) is greater than 500,000 (remember to check for scaling).



SELECT 
srcStateName,
SUM(FarmersPremiumAmount) AS TotalFarmersPremium,
SUM(StatePremiumAmount) AS TotalStatePremium,
SUM(GOVPremiumAmount) AS TotalGovPremium,
SUM(TotalFarmersCovered) AS TotalFarmersCovered
FROM 
FarmersInsuranceData
WHERE 
SumInsured > 500000
GROUP BY 
srcStateName;


-- Sorting Data

-- Retrieve the top 5 districts (srcDistrictName) with the highest TotalPopulation in the year 2020.


SELECT 
srcDistrictName,
TotalPopulation
FROM 
FarmersInsuranceData
WHERE 
Year_ = '2020'
ORDER BY 
TotalPopulation DESC
LIMIT 5;


-- Retrieve the srcStateName, srcDistrictName, and SumInsured for the 10 districts with the lowest non-zero FarmersPremiumAmount, 
-- ordered by insured sum and then the FarmersPremiumAmount.


SELECT 
srcStateName,
srcDistrictName,
SumInsured,
FarmersPremiumAmount
FROM 
FarmersInsuranceData
WHERE 
FarmersPremiumAmount > 0
ORDER BY 
SumInsured ASC,
FarmersPremiumAmount ASC
LIMIT 10;


-- Retrieve the top 3 states (srcStateName) along with the year (srcYear) where the ratio of insured farmers (TotalFarmersCovered) to the total population (TotalPopulation) is highest. 
-- Sort the results by the ratio in descending order.

SELECT 
srcStateName,
srcYear,
ROUND(SUM(TotalFarmersCovered) * 1.0 / SUM(TotalPopulation), 4) AS CoverageRatio
FROM 
FarmersInsuranceData
WHERE 
TotalPopulation > 0
GROUP BY 
srcStateName, srcYear
ORDER BY 
CoverageRatio DESC
LIMIT 3;

-- String Functions 

-- Create StateShortName by retrieving the first 3 characters of the srcStateName for each unique state.


SELECT 
DISTINCT srcStateName,
LEFT(srcStateName, 3) AS StateShortName
FROM 
FarmersInsuranceData
ORDER BY 
srcStateName;
    

-- Retrieve the srcDistrictName where the district name starts with 'B'.


SELECT 
DISTINCT srcDistrictName
FROM 
FarmersInsuranceData
WHERE 
srcDistrictName LIKE 'B%';


-- Retrieve the srcStateName and srcDistrictName where the district name contains the word 'pur' at the end.


SELECT 
srcStateName, 
srcDistrictName
FROM 
FarmersInsuranceData
WHERE 
srcDistrictName LIKE '%pur';


-- Joins 

-- Perform an INNER JOIN between the srcStateName and srcDistrictName columns to retrieve the aggregated FarmersPremiumAmount for districts where the district’s Insurance units for an individual year are greater than 10.


SELECT 
A.srcStateName,
A.srcDistrictName,
SUM(A.FarmersPremiumAmount) AS TotalPremium
FROM 
FarmersInsuranceData AS A
INNER JOIN 
(
SELECT srcStateName, srcDistrictName, srcYear
FROM FarmersInsuranceData
WHERE InsuranceUnits > 10
GROUP BY srcStateName, srcDistrictName, srcYear
) AS B
ON 
A.srcStateName = B.srcStateName
AND A.srcDistrictName = B.srcDistrictName
AND A.srcYear = B.srcYear
GROUP BY 
A.srcStateName, A.srcDistrictName
ORDER BY 
TotalPremium DESC;


-- Write a query that retrieves srcStateName, srcDistrictName, Year, TotalPopulation for each district and the the highest recorded FarmersPremiumAmount for that district over all available years
-- 	Return only those districts where the highest FarmersPremiumAmount exceeds 20 crores.


SELECT 
srcStateName,
srcDistrictName,
srcYear,
TotalPopulation,
FarmersPremiumAmount
FROM 
FarmersInsuranceData
WHERE 
(srcStateName, srcDistrictName, FarmersPremiumAmount) IN (
	SELECT 
	srcStateName,
	srcDistrictName,
	MAX(FarmersPremiumAmount) AS MaxPremium
	FROM 
	FarmersInsuranceData
	GROUP BY 
	srcStateName, srcDistrictName
	HAVING 
	MAX(FarmersPremiumAmount) > 200000000
    );


-- Perform a LEFT JOIN to combine the total population statistics with the farmers’ data (TotalFarmersCovered, SumInsured) for each district and state. 
-- Return the total premium amount (FarmersPremiumAmount) and the average population count for each district aggregated over the years, where the total FarmersPremiumAmount is greater than 100 crores.
-- Sort the results by total farmers' premium amount, highest first.


SELECT
srcStateName,
srcDistrictName,
SUM(FarmersPremiumAmount) AS TotalFarmersPremium,
AVG(TotalPopulation) AS AvgPopulation,
SUM(TotalFarmersCovered) AS TotalFarmersCovered,
SUM(SumInsured) AS TotalSumInsured
FROM
FarmersInsuranceData
GROUP BY
srcStateName, srcDistrictName
HAVING
TotalFarmersPremium > 1000000000
ORDER BY
TotalFarmersPremium DESC;


-- Subqueries

-- Write a query to find the districts (srcDistrictName) where the TotalFarmersCovered is greater than the average TotalFarmersCovered across all records.


SELECT 
srcDistrictName
FROM 
FarmersInsuranceData
WHERE 
TotalFarmersCovered > (
	SELECT 
	AVG(TotalFarmersCovered)
	FROM 
	FarmersInsuranceData
    );


-- Write a query to find the srcStateName where the SumInsured is higher than the SumInsured of the district with the highest FarmersPremiumAmount.


SELECT 
srcStateName
FROM 
FarmersInsuranceData
WHERE 
SumInsured > (
	SELECT 
	MAX(SumInsured)
	FROM 
	FarmersInsuranceData
	WHERE 
	FarmersPremiumAmount = (
		SELECT 
		MAX(FarmersPremiumAmount)
		FROM 
		FarmersInsuranceData
		)
);


-- Write a query to find the srcDistrictName where the FarmersPremiumAmount is higher than the average FarmersPremiumAmount of the state that has the highest TotalPopulation.


SELECT
srcDistrictName,
FarmersPremiumAmount
FROM
FarmersInsuranceData
WHERE
FarmersPremiumAmount > (
        SELECT
		AVG(FarmersPremiumAmount)
        FROM
		FarmersInsuranceData
        WHERE
		srcStateName = (
                SELECT
				srcStateName
                FROM
				FarmersInsuranceData
                GROUP BY
				srcStateName
                ORDER BY
				SUM(TotalPopulation) DESC
                LIMIT 1
			    )
    );



-- Advanced SQL Functions (Window Functions) 

-- Use the ROW_NUMBER() function to assign a row number to each record in the dataset ordered by total farmers covered in descending order.


SELECT
srcStateName,
srcDistrictName,
TotalFarmersCovered,
ROW_NUMBER() OVER (
ORDER BY TotalFarmersCovered DESC
) AS RowNum
FROM
FarmersInsuranceData;


-- Using the RANK() function to rank the districts (srcDistrictName) based on the SumInsured (descending) and partition by alphabetical srcStateName.


SELECT
srcStateName,
srcDistrictName,
SumInsured,
RANK() OVER (
PARTITION BY srcStateName
ORDER BY SumInsured DESC
) AS RankBySumInsured
FROM
FarmersInsuranceData;


-- Using the SUM() window function to calculate a cumulative sum of FarmersPremiumAmount for each district (srcDistrictName), ordered ascending by the srcYear, partitioned by srcStateName.


SELECT
srcStateName,
srcDistrictName,
srcYear,
FarmersPremiumAmount,
SUM(FarmersPremiumAmount) OVER (
PARTITION BY srcStateName, srcDistrictName
ORDER BY srcYear ASC
) AS CumulativePremium
FROM
FarmersInsuranceData;



-- Data Integrity (Constraints, Foreign Keys)

-- Create a table 'districts' with DistrictCode as the primary key and columns for DistrictName and StateCode. 
-- Create another table 'states' with StateCode as primary key and column for StateName.


CREATE TABLE states (
StateCode INT PRIMARY KEY,
StateName VARCHAR(255)
);

CREATE TABLE districts (
DistrictCode INT PRIMARY KEY,
DistrictName VARCHAR(255),
StateCode INT,
FOREIGN KEY (StateCode) REFERENCES states(StateCode)
);

-- Add a foreign key constraint to the districts table that references the StateCode column from a states table.


ALTER TABLE districts
ADD CONSTRAINT fk_statecode
FOREIGN KEY (StateCode) REFERENCES states(StateCode);


-- UPDATE and DELETE 

-- Update the FarmersPremiumAmount to 500.0 for the record where rowID is 1.


UPDATE FarmersInsuranceData
SET FarmersPremiumAmount = 500.0
WHERE rowID = 1;


-- Update the Year to '2021' for all records where srcStateName is 'HIMACHAL PRADESH'.


SET SQL_SAFE_UPDATES = 0;

UPDATE FarmersInsuranceData
SET srcYear = 2021
WHERE srcStateName = 'HIMACHAL PRADESH';

-- Delete all records where the TotalFarmersCovered is less than 10000 and Year is 2020.


DELETE FROM FarmersInsuranceData
WHERE TotalFarmersCovered < 10000
AND srcYear = 2020;

