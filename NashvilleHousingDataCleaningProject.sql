/*

Cleaning data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------
-- Standardize Date Format

-- Converting datetime to date format
Select SaleDateConverted, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

-----------------------------------------------------------------------------------------------------
--Populate property address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
Order By 2

Select l.UniqueID,l.ParcelID, l.PropertyAddress,l.UniqueID, r.ParcelID, r.PropertyAddress,ISNULL(l.PropertyAddress, r.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing l
JOIN PortfolioProject.dbo.NashvilleHousing r
	ON l.ParcelID = r.ParcelID
	AND l.UniqueID <> r.UniqueID
where l.PropertyAddress is NULL;

UPDATE l
SET PropertyAddress = ISNULL(l.PropertyAddress, r.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing l
JOIN PortfolioProject.dbo.NashvilleHousing r
	ON l.ParcelID = r.ParcelID
	AND l.UniqueID <> r.UniqueID
where l.PropertyAddress is NULL;


-----------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns(Address,City,State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City

from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *

from PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' field
--REPLACE(SoldAsVacant,'Y','Yes'),
--REPLACE(SoldAsVacant,'N','No')

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	
from PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
Select DISTINCT SoldAsVacant
from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------
--Remove Duplicates

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
from RowNumCTE
where row_num > 1

-----------------------------------------------------------------------------------------------------
-- Delete unused columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress,
	 OwnerAddress,
	 TaxDistrict,
	 SaleDate


