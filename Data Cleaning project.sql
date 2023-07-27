/*

Cleaning Data in SQL Queries

*/

Select * 
From NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data Format

Select SaleDate, CONVERT(date, SaleDate) as NewDate
From NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted 
From NashvilleHousing



-------------------------------------------------------------------------------------------------------------------------------

-- Property Address Data

Select *
From NashvilleHousing
where PropertyAddress is  null
order by ParcelID

Select ParcelID,PropertyAddress, LandUse,OwnerAddress
From NashvilleHousing
--where PropertyAddress is  null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual Column (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress ) +1,LEN(PropertyAddress)) as Address,
PropertyAddress
From NashvilleHousing


Alter Table NashvilleHousing
Add PropertySpliitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySpliitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress ) -1)


Alter Table NashvilleHousing
Add PropertySpliitCity nvarchar(255);

Update NashvilleHousing
Set PropertySpliitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress ) +1,LEN(PropertyAddress))



/*

-- Breaking out Address into individual Column (Address, City, State)
	-- spliting Number from Address

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress ) -1) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitNumber float;


Update NashvilleHousing
CONVERT(INT, PropertySplitNumber) As number; 
Set number = SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress )-1)

Alter Table NashvilleHousing
drop column PropertySplitNumber;

*/

-------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Owner Address into individual Column (Address, City, State)


Select OwnerAddress 
from NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


-------------------------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in Sold Vacant


Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
from NashvilleHousing

update NashvilleHousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

Select SoldAsVacant 
from NashvilleHousing


-------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	Partition by ParcelID,PropertyAddress, SalePrice, SaleDate, LegalReference
	Order By UniqueID) row_num
From NashvilleHousing
-- Order by ParcelID
)
 
Select * 
from RowNumCTE
where row_num >1


-------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Column



Alter Table NashvilleHousing
drop column TaxDistrict, PropertySplitNumber,OwnerAddress, PropertyAddress

Alter Table NashvilleHousing
drop column SaleDate

Select * 
from NashvilleHousing