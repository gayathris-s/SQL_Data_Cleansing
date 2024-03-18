/*

Cleaning Data in SQL Queries

*/

SELECT * FROM 
SQL_ETL.dbo.Nashville_Housing;


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDate, CONVERT(Date,SaleDate)
From SQL_ETL.dbo.Nashville_Housing


Update Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)

Select saleDate
From SQL_ETL.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------
 
-- Populate Property Address data
SELECT PropertyAddress FROM 
SQL_ETL.dbo.Nashville_Housing
WHERE PropertyAddress IS NULL;

-- Totally 29 Null Rows 
-- OBSERVATION: If the parcelID is sam, the peoperty address is same is most cases. Let's implement that using SELF JOIN. 
-- So if the parcelID are same and PropertyAddress is NULL, NULL will be replaced by PropertyAddress.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQL_ETL.dbo.Nashville_Housing a
JOIN SQL_ETL.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--UPDATE the PropertyAddress column with Non NULL Values

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From SQL_ETL.dbo.Nashville_Housing a
JOIN SQL_ETL.dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress FROM 
SQL_ETL.dbo.Nashville_Housing;

-- Seperate address into ADDRESS AND CITY using the delimiter ','

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)- 1) AS ADDRESS
FROM SQL_ETL.dbo.Nashville_Housing;

SELECT SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) AS CITY
FROM SQL_ETL.dbo.Nashville_Housing;

--Create New Columns

ALTER TABLE Nashville_Housing
ADD propertysplitaddress VARCHAR(255)

ALTER TABLE Nashville_Housing
ADD propertycity VARCHAR(255)

--Update New columns

Update Nashville_Housing
SET propertysplitaddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)- 1)

Update Nashville_Housing
SET propertycity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))

SELECT propertysplitaddress, propertycity FROM SQL_ETL.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------
--Change OwnderAddress into segments - Address, City and State

Select OwnerAddress
From SQL_ETL.dbo.Nashville_Housing

-- [arseName looks for period and segregates but BACKWARDS

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQL_ETL.dbo.Nashville_Housing


ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville_Housing
Add OwnerCity Nvarchar(255);

Update Nashville_Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville_Housing
Add OwnerState Nvarchar(255);

Update Nashville_Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT * FROM 
SQL_ETL.dbo.Nashville_Housing;


--------------------------------------------------------------------------------------------------------------------------



-- Change 1 and 0 to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant FROM 
SQL_ETL.dbo.Nashville_Housing;

Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From SQL_ETL.dbo.Nashville_Housing
)


Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From SQL_ETL.dbo.Nashville_Housing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE SQL_ETL.dbo.Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Select *
From SQL_ETL.dbo.Nashville_Housing

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
















