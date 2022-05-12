--Cleaning Data in SQL Queries

Select *
FROM [Data Cleaning].[dbo].[Nashville Housing Data]

-- Standardize Date Format

Select saleDate, CONVERT(DATE, SaleDate)
FROM [Data Cleaning].[dbo].[Nashville Housing Data]

Update [Nashville Housing Data]
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE [Nashville Housing Data]
Add SaleDateConverted Date;

Update [Nashville Housing Data]
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
  FROM [Data Cleaning].[dbo].[Nashville Housing Data]
  --Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
 FROM [Data Cleaning].[dbo].[Nashville Housing Data] a
Join [Data Cleaning].[dbo].[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Data Cleaning].[dbo].[Nashville Housing Data] a
Join [Data Cleaning].[dbo].[Nashville Housing Data] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
---------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Data Cleaning].[dbo].[Nashville Housing Data]
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [Data Cleaning].[dbo].[Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Nashville Housing Data]
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing Data]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
FROM [Data Cleaning].[dbo].[Nashville Housing Data]

Select OwnerAddress
FFROM [Data Cleaning].[dbo].[Nashville Housing Data]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM [Data Cleaning].[dbo].[Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing Data]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Nashville Housing Data]
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing Data]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Nashville Housing Data]
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing Data]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From [Data Cleaning].[dbo].[Nashville Housing Data]

----------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Data Cleaning].[dbo].[Nashville Housing Data]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Data Cleaning].[dbo].[Nashville Housing Data]


Update [Nashville Housing Data]
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

From [Data Cleaning].[dbo].[Nashville Housing Data]
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From [Data Cleaning].[dbo].[Nashville Housing Data]
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Data Cleaning].[dbo].[Nashville Housing Data]

ALTER TABLE [Data Cleaning].[dbo].[Nashville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate