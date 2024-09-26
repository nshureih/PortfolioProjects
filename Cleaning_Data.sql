SELECT *
FROM Nashville_Housing_Data.Housing_Data
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

--Formatting Dates
UPDATE Nashville_Housing_Data.Housing_Data1
SET SaleDateConverted = PARSE_DATE('%B %e, %Y', Housing_Data1.SaleDate)
WHERE TRUE;

--Adding Primary Key
--ALTER TABLE Nashville_Housing_Data.Housing_Data1 ADD PRIMARY KEY (UniqueID) NOT ENFORCED;

--Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing_Data.Housing_Data1 a
JOIN Nashville_Housing_Data.Housing_Data1 b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE Nashville_Housing_Data.Housing_Data1 a
   SET a.PropertyAddress = b.PropertyAddress
  FROM (
    SELECT ParcelID, MAX(PropertyAddress) PropertyAddress 
      FROM Nashville_Housing_Data.Housing_Data1
     GROUP BY 1
  ) b
 WHERE a.PropertyAddress IS NULL AND a.ParcelID = b.ParcelID;

--verifying no null values in property address
SELECT PropertyAddress, ParcelID
FROM Nashville_Housing_Data.Housing_Data1
WHERE PropertyAddress IS NULL;

--Breaking up property address into individual columns (address, city, state)

SELECT PropertyAddress
FROM Nashville_Housing_Data.Housing_Data1;

SELECT PropertyAddress, 
SPLIT(PropertyAddress, ',') [OFFSET(0)] AS Address,
SPLIT (PropertyAddress, ',')[OFFSET(1)] AS City
FROM Nashville_Housing_Data.Housing_Data1;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--ADD COLUMN StreetAddress String;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--RENAME COLUMN StreetAddress TO PropertyStreetAddress;

UPDATE Nashville_Housing_Data.Housing_Data1
SET PropertyStreetAddress = SPLIT(PropertyAddress, ',') [OFFSET(0)]
WHERE PropertyStreetAddress IS NULL;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--ADD COLUMN City String;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--RENAME COLUMN City TO PropertyCity;

UPDATE Nashville_Housing_Data.Housing_Data1
SET PropertyCity = SPLIT (PropertyAddress, ',')[OFFSET(1)]
WHERE PropertyCity IS NULL;

SELECT OwnerAddress
FROM Nashville_Housing_Data.Housing_Data1;

SELECT OwnerAddress,
SPLIT(OwnerAddress, ',') [OFFSET(0)] AS Street,
SPLIT(OwnerAddress, ',') [OFFSET(1)] AS City,
SPLIT(OwnerAddress, ',') [OFFSET(2)] AS State
FROM Nashville_Housing_Data.Housing_Data1;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--ADD COLUMN OwnerStreetAddress String;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--ADD COLUMN OwnerCity String;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--ADD COLUMN OwnerState String;

UPDATE Nashville_Housing_Data.Housing_Data1
SET OwnerStreetAddress = SPLIT(OwnerAddress, ',') [OFFSET(0)] 
WHERE OwnerStreetAddress IS NULL;

UPDATE Nashville_Housing_Data.Housing_Data1
SET OwnerCity = SPLIT(OwnerAddress, ',') [OFFSET(1)] 
WHERE OwnerCity IS NULL;

UPDATE Nashville_Housing_Data.Housing_Data1
SET OwnerState = SPLIT(OwnerAddress, ',') [OFFSET(2)] 
WHERE OwnerState IS NULL;

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
              PropertyAddress,
              SalePrice,
              SaleDate,
              LegalReference
              ORDER BY
                UniqueID
 )             row_num

FROM Nashville_Housing_Data.Housing_Data1)
--ORDER BY ParcelID

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

DELETE FROM Nashville_Housing_Data.Housing_Data1
WHERE STRUCT(ParcelID, UniqueID) NOT IN (
        SELECT AS STRUCT ParcelID, MAX(UniqueID) Uniqueid
        FROM Nashville_Housing_Data.Housing_Data1
        GROUP BY ParcelID);

-- Delete Unused Columns

Select * 
FROM Nashville_Housing_Data.Housing_Data1;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--DROP COLUMN OwnerAddress;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--DROP COLUMN TaxDistrict;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--DROP COLUMN PropertyAddress;

--ALTER TABLE Nashville_Housing_Data.Housing_Data1
--DROP COLUMN SaleDate;