# 🌾 Farmers Insurance Analysis — India (SQL Project)

A complete end-to-end SQL data analysis project using the **NDAP Farmers Insurance Dataset**, exploring crop insurance coverage, premiums, and farmer demographics across **27 Indian states** from **2018 to 2021**.

---

## 📊 Project Overview

This project analyses India's **Pradhan Mantri Fasal Bima Yojana (PMFBY)** data to uncover patterns in crop insurance adoption, premium distribution, and regional disparities. All analysis is done in **MySQL** using a single main table with 1,870 district-level records.

| Attribute | Detail |
|-----------|--------|
| **Database** | MySQL (`ndap` schema) |
| **Dataset Source** | [NDAP — National Data & Analytics Platform](https://ndap.niti.gov.in/) |
| **Records** | 1,870 district-year observations |
| **States** | 27 |
| **Years** | 2018, 2019, 2020, 2021 |
| **Main Table** | `FarmersInsuranceData` |

---

## 🗂️ Repository Structure

```
farmers-insurance-sql/
│
├── SQL_Farmers_Insurance_Analysis.sql   # Main analysis file (all queries)
├── data/
│   ├── data.csv                         # Raw dataset (1,870 rows)
│   └── column_description.csv           # Data dictionary / column metadata
├── README.md                            # This file
└── presentation/
    └── Farmers_Insurance_Analysis.pptx  # Project presentation (10 slides)
```

---

## 🗄️ Schema Design

### Main Table — `FarmersInsuranceData`

| Column | Type | Description |
|--------|------|-------------|
| `rowID` | INT PK | Unique row identifier |
| `srcYear` | INT | Year of record |
| `srcStateName` | VARCHAR | State name |
| `srcDistrictName` | VARCHAR | District name |
| `InsuranceUnits` | INT | Number of insurance units |
| `TotalFarmersCovered` | INT | Total enrolled farmers |
| `ApplicationsLoaneeFarmers` | INT | Loanee farmer applications |
| `ApplicationsNonLoaneeFarmers` | INT | Non-loanee applications |
| `InsuredLandArea` | FLOAT | Land area insured (hectares) |
| `FarmersPremiumAmount` | FLOAT | Premium paid by farmers (₹) |
| `StatePremiumAmount` | FLOAT | State government premium share (₹) |
| `GOVPremiumAmount` | FLOAT | Central government premium share (₹) |
| `GrossPremiumAmountToBePaid` | FLOAT | Total gross premium (₹) |
| `SumInsured` | FLOAT | Total sum insured (₹) |
| `PercentageMaleFarmersCovered` | FLOAT | % male farmers |
| `PercentageFemaleFarmersCovered` | FLOAT | % female farmers |
| `TotalPopulation` | INT | District total population |
| `TotalPopulationRural` | INT | Rural population |
| `LandArea` | FLOAT | Total district land area |

### Supporting Tables

```sql
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
```

---

## 🔍 SQL Techniques Demonstrated

| Category | Techniques |
|----------|-----------|
| **DDL** | `CREATE TABLE`, `ALTER TABLE`, Foreign Keys, Primary Keys |
| **DML** | `INSERT`, `UPDATE`, `DELETE`, safe update toggling |
| **Filtering** | `WHERE`, `BETWEEN`, `LIKE`, `IN`, `IS NULL` |
| **Aggregation** | `SUM`, `AVG`, `COUNT`, `MIN`, `MAX` with `GROUP BY` / `HAVING` |
| **Sorting** | `ORDER BY`, `LIMIT` for top-N queries |
| **Joins** | `INNER JOIN`, `LEFT JOIN`, self-join |
| **Subqueries** | Correlated and non-correlated, nested 3 levels deep |
| **Window Functions** | `ROW_NUMBER()`, `RANK()`, `SUM() OVER` with `PARTITION BY` |
| **String Functions** | `LEFT()`, `LIKE` with `%` wildcards |
| **CTEs** | `WITH` clause for readable multi-step queries |

---

## 📝 Key Analysis Questions Answered

1. Which states had the highest total farmers covered?
2. How does premium contribution (farmer / state / GOV) vary by state?
3. Which districts have the lowest non-zero `FarmersPremiumAmount`?
4. Which state-year combinations show the highest insured-farmer-to-population ratio?
5. How does average insured land area trend across years per state?
6. Which districts exceed the national average `TotalFarmersCovered`?
7. What is the cumulative premium per district ordered by year?
8. How to rank districts by `SumInsured` within each state?
9. Which production houses exceed 100 crore total premium (HAVING filter)?
10. How to classify districts by premium bucket using CASE expressions?

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0+ (window functions require MySQL 8+)
- MySQL Workbench or any SQL client

### Steps

**1. Create the database and table**
```sql
CREATE SCHEMA IF NOT EXISTS ndap;
USE ndap;
-- Then run the CREATE TABLE block from the .sql file
```

**2. Load the data**
```sql
LOAD DATA LOCAL INFILE '/path/to/data.csv'
INTO TABLE FarmersInsuranceData
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

> Make sure `local_infile` is enabled:
> ```sql
> SET GLOBAL local_infile = 1;
> ```

**3. Run the analysis queries**

Open `SQL_Farmers_Insurance_Analysis.sql` in MySQL Workbench and execute section by section, or run the whole file.

---

## 💡 Notable Query Highlights

### Weighted Coverage Ratio (Top States)
```sql
SELECT 
    srcStateName,
    srcYear,
    ROUND(SUM(TotalFarmersCovered) * 1.0 / SUM(TotalPopulation), 4) AS CoverageRatio
FROM FarmersInsuranceData
WHERE TotalPopulation > 0
GROUP BY srcStateName, srcYear
ORDER BY CoverageRatio DESC
LIMIT 3;
```

### Cumulative Premium (Window Function)
```sql
SELECT
    srcStateName,
    srcDistrictName,
    srcYear,
    FarmersPremiumAmount,
    SUM(FarmersPremiumAmount) OVER (
        PARTITION BY srcStateName, srcDistrictName
        ORDER BY srcYear ASC
    ) AS CumulativePremium
FROM FarmersInsuranceData;
```

### Multi-level Subquery
```sql
SELECT srcDistrictName, FarmersPremiumAmount
FROM FarmersInsuranceData
WHERE FarmersPremiumAmount > (
    SELECT AVG(FarmersPremiumAmount)
    FROM FarmersInsuranceData
    WHERE srcStateName = (
        SELECT srcStateName
        FROM FarmersInsuranceData
        GROUP BY srcStateName
        ORDER BY SUM(TotalPopulation) DESC
        LIMIT 1
    )
);
```

---

## ⚠️ Data Notes

- `FarmersPremiumAmount`, `SumInsured`, and premium columns are in **absolute INR** (not crores). The NDAP metadata lists scaling factor = 0 for all columns.
- NULL values exist in premium and percentage demographic columns — filtered appropriately in each query.
- The `worlwide_gross_income` typo in the IMDB project is unrelated to this dataset.
- `POSITION(',' IN languages)` is used as a proxy for multilingual detection where applicable.

---

## 📁 Data Source

- **Dataset**: NDAP (National Data & Analytics Platform), Government of India
- **Scheme**: Pradhan Mantri Fasal Bima Yojana (PMFBY)
- **Link**: https://ndap.niti.gov.in/

---

## 👤 Author

**Debojyoti**  
SQL Data Analysis | MySQL | Agricultural Data  

