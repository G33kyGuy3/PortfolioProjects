/*
Cleansing Data
*/

SELECT *
FROM PortfolioProject..NashvilleHousing;
--------------------------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

---------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE a.PropertyAddress is null

Update A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing A
JOIN PortfolioProject..NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------------


--Breaking out Address into Individual Columns (Address, City, State)

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelI

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress));



Select
PARSENAME(replace (OwnerAddress,',','.'),3)
,PARSENAME(replace (OwnerAddress,',','.'),2)
,PARSENAME(replace (OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace (OwnerAddress,',','.'),3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace (OwnerAddress,',','.'),2);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace (OwnerAddress,',','.'),1);


-------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
from PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
----------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS (
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
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1

------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

SELECT * 
FROM PortfolioProject..NashvilleHousing



