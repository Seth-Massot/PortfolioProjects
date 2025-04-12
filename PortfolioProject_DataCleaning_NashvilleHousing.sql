
---------------------------------------------------------------------

-- Cleaning Data in SQL Queries


Select *
From NashvilleHousing_DataCleaning.dbo.[NashvilleHousing]

---------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing_DataCleaning.dbo.[NashvilleHousing]


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


/* If table is not updating */

--ALTER TABLE NashvilleHousing
--Add SaleDateConverted Date;

--Update [Nashville Housing]
--SET SaleDate = CONVERT(Date,SaleDate)


---------------------------------------------------------------------

-- Populate Property Address Data


Select *
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing
Where PropertyAddress is NULL
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing AS a
JOIN NashvilleHousing_DataCleaning.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing AS a
JOIN NashvilleHousing_DataCleaning.dbo.NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL


---------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Adress	/* using CHARINDEX in substring to search for value and where to look. -1 moves back one character and excludes value */
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City	/* type of use of CHARINDEX but now look after value to return remainder of address field */

From NashvilleHousing_DataCleaning.dbo.NashvilleHousing

/* Altering and updating table */

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select * 
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing

---------------------------------------------------------------------

-- Breaking out Address continued


Select * 
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing


Select OwnerAddress
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)	/* Parsename only looks for '.' therefore replaced ',' within the function */
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)	/* Parsename moves opposite to what may be expected and 1 will yield everything after the last '.' */
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing




ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' Field


Select * 
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = '1' THEN 'Yes'
	WHEN SoldAsVacant = '0' THEN 'No'
	ELSE NULL
	END
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD SoldAsVacantYesNo Nvarchar(5)


UPDATE NashvilleHousing
SET SoldAsVacantYesNo = CASE When SoldAsVacant = '1' THEN 'Yes'
	WHEN SoldAsVacant = '0' THEN 'No'
	ELSE NULL
	END
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing



Select Distinct(SoldAsVacantYesNo)
FROM NashvilleHousing



---------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) AS row_num
					
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress

--Select *
--From RowNumCTE
--Where row_num > 1
--ORDER BY PropertyAddress


Select *
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing


---------------------------------------------------------------------

-- Delete Unused Columns

Select *
From NashvilleHousing_DataCleaning.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing_DataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing_DataCleaning.dbo.NashvilleHousing
DROP COLUMN SoldAsVacant