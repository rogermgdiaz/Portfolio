/*

Cleaning Data in SQL Queries

*/


SELECT * 
FROM PortfolioProject.dbo.Nashville_housing;
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

--We wanted the date in this format 
SELECT SaleDate, CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.Nashville_housing;


--You probably think that just doing this it would work, BUT NO, 
--even if said if updated it isn't
UPDATE Nashville_housing
SET SaleDate= CONVERT(date,SaleDate);


-- If it doesn't Update properly, as i told you, you should use this
--Create a new column Sale_date, with the date values that we wanted
ALTER TABLE Nashville_housing
ADD Sale_date DATE;

UPDATE Nashville_housing
SET Sale_date = CONVERT(date,SaleDate);


ALTER TABLE PortfolioProject.dbo.Nashville_housing
DROP COLUMN SaleDate

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
--I found 29 NULL values
SELECT PropertyAddress
FROM PortfolioProject.dbo.Nashville_housing
WHERE PropertyAddress IS NULL

-- The NULL VALUES from property addres could be modify using parcelID
SELECT *
FROM PortfolioProject.dbo.Nashville_housing
WHERE PropertyAddress IS NULL

-- let's modify it

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Nashville_housing a 
JOIN PortfolioProject.dbo.Nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--RUN this to modify the NULL values the other select was exploratory
UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.Nashville_housing a 
JOIN PortfolioProject.dbo.Nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
--But first the exploratory SELECT to have a better look of the column

SELECT PropertyAddress
FROM PortfolioProject.dbo.Nashville_housing


--This is way get the strings 
SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS address
FROM PortfolioProject.dbo.Nashville_housing

--now let apply it
ALTER TABLE Nashville_housing
ADD property_address Nvarchar(255);

UPDATE Nashville_housing
SET property_address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE Nashville_housing
ADD property_city Nvarchar(255);

UPDATE Nashville_housing
SET property_city = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

--Let's see the changes
SELECT *
FROM PortfolioProject.dbo.Nashville_housing

--We need to do the same with OwnerAddress but let's explore 
--Another way to do it
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.Nashville_housing

ALTER TABLE Nashville_housing
ADD owner_address Nvarchar(255);

UPDATE Nashville_housing
SET owner_address =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_housing
ADD owner_city Nvarchar(255);

UPDATE Nashville_housing
SET owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_housing
ADD owner_state Nvarchar(255);

UPDATE Nashville_housing
SET owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Let's Explore the changes that we made
SELECT *
FROM PortfolioProject.dbo.Nashville_housing

--There are some NULL VALUES but it's easy to fix as 
--we observed fixing the address null values

--Where PropertyAddress is null
--order by ParcelID





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM PortfolioProject.dbo.Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject.dbo.Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

--remove the 'Y' y the 'N' from the SoldAsVacant
UPDATE Nashville_housing
SET SoldAsVacant= CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
	SELECT*,
		ROW_NUMBER()OVER(
		PARTITION BY ParcelID, 
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY 
						UniqueID) row_num

FROM PortfolioProject.dbo.Nashville_housing
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT*
FROM PortfolioProject.dbo.Nashville_housing

ALTER TABLE PortfolioProject.dbo.Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



--Let's explore a little deeper into the data

SELECT*
FROM PortfolioProject.dbo.Nashville_housing

--There are columns with sensitive information, so we drop 
--OwnerName, Acreage, LandValue, BuildingValue, TotalValue, 
--YearBuilt, Bedrooms, FullBath,HalfBath,owner_address,
--owner_city,owner_state
--Even if we want to use it, More than a half of the rows are NULL
--Values.

ALTER TABLE PortfolioProject.dbo.Nashville_housing
DROP COLUMN OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath,HalfBath,owner_address,owner_city,owner_state


-- analysis


--Order By most expensive properties

SELECT SalePrice, ParcelID, property_address
FROM PortfolioProject.dbo.Nashville_housing
ORDER BY 1 DESC

-- Let's Try with the Land Use

SELECT *
FROM PortfolioProject.dbo.Nashville_housing

-- the next are for the viz on tableu.
SELECT property_city, sum(SalePrice)AS total_value_properties, Count(SalePrice)AS Number_of_properties,(sum(SalePrice)/Count(SalePrice)) AS mean_housing
FROM PortfolioProject.dbo.Nashville_housing
GROUP BY property_city
ORDER BY 2 DESC









-----------------------------------------------------------------------------