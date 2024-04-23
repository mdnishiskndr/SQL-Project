/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing


-- Standardize Date Format

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)



-- Populate Property Address data

select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a --Note: cannot use the table real name when updating join table
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) --Note: isnull function will return an alternative value when the value in the column it searches has null
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into individual Columns (Address, City, State)

select *
from PortfolioProject.dbo.NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySpiltAddress nvarchar(255)

update NashvilleHousing
set PropertySpiltAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress)-1)


alter table NashvilleHousing
add PropertySpiltCity nvarchar(255)

update NashvilleHousing
set PropertySpiltCity = substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))








select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
parsename(replace(OwnerAddress, ',','.'),3), --Note: use replace function because parsename function can only read & find '.' not ','
parsename(replace(OwnerAddress, ',','.'),2),
parsename(replace(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.NashvilleHousing --Note: the numbering need to be backwards as if not then it will split the address in backwards order

alter table NashvilleHousing
add OwnerSpiltAddress nvarchar(255)

update NashvilleHousing
set OwnerSpiltAddress = parsename(replace(OwnerAddress, ',','.'),3)


alter table NashvilleHousing
add OwnerSpiltCity nvarchar(255)

update NashvilleHousing
set OwnerSpiltCity = parsename(replace(OwnerAddress, ',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'),1)

select *
from PortfolioProject.dbo.NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing



update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 end



-- Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by uniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num>1



-- Delete Unused Columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate