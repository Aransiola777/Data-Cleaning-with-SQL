
--Cleaning data with SQL queries
USE PortfolioProject;

Select *
From PortfolioProject..NashvilleHousing


-- Standardize Date Format

Select SaleDate, Convert(Date,SaleDate) as SaleDate
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

--Another method of changing the date format by conversion

SELECT SaleDate, CAST(SaleDate AS DATE) AS SaleDate
FROM PortfolioProject..NashvilleHousing;

-- After updating it was still there, so you can alter the table and add the new column or alter both table and column and change the column directly.
Alter Table NashvilleHousing
Alter Column SaleDate Date;



-- Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID


Select a.ParcelID,a.PropertyAddress,a.[UniqueID ], b.ParcelID,b.PropertyAddress,b.[UniqueID ], ISNULL (b.PropertyAddress, a.PropertyAddress) as PropertyAddressB
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null

	Update b
	Set PropertyAddress = ISNULL (b.PropertyAddress, a.PropertyAddress)
	From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null




-- Breaking out Address into Individual Columns (Address, City, State)

Select 
Substring (PropertyAddress,1, charindex(',',PropertyAddress)-1) as Address,
Substring (PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing

--Let's ADD the newly updated column
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring (PropertyAddress, charindex(',', PropertyAddress)+1, Len(PropertyAddress))



Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From PortfolioProject..NashvilleHousing

--or the previously used method

Select
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1) as Address,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 12, LEN(OwnerAddress)) as Country,
REPLACE(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, LEN(OwnerAddress)), ', TN', '') as City
FROM PortfolioProject..NashvilleHousing;

--Update the changes implemented using multiple option of both substrings and parsename
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = REPLACE(SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, LEN(OwnerAddress)), ', TN', '')

ALTER TABLE NashvilleHousing
Add OwnerSplitCountry Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCountry = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant,
Count (SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant
,CASE when SoldAsVacant ='Y' THEN 'Yes'
      when SoldAsVacant ='N' THEN 'No'
	  Else SoldAsVacant
	  END as NewSoldAsVacant
	 From PortfolioProject..NashvilleHousing

	 --The NewSoldAsVacant will be updated into the database

	 ALTER TABLE NashvilleHousing
Add NewSoldAsVacant Nvarchar(255);

Update NashvilleHousing
SET NewSoldAsVacant = CASE when SoldAsVacant ='Y' THEN 'Yes'
      when SoldAsVacant ='N' THEN 'No'
	  Else SoldAsVacant
      End


-- Remove Duplicates

WITH RowNumCTE as (
Select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
                 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by
				 UniqueID) as Row_num
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
-- TO CONFIRM IF THERE ARE DOUBLE ROWS, REMOVE THE DELETE AND REPACE WITH SELECT ALL AND CHANGE THE 'ORDER BY PROPERTYADDRESS' TO A QUERY FROM STATEMENT
DELETE
FROM RowNumCTE
WHERE Row_num >1
--order by PropertyAddress;


-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress





