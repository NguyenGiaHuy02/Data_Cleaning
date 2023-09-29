SET SQL_SAFE_UPDATES=0;
Select * from nashvillehousingdata

-- Standardize Date Format
Select SaleDateConverted , Convert(SaleDate , Date) as NewSaleDate
from nashvillehousingdata

Alter table nashvillehousingdata
Add SaleDateConverted Date			

Update nashvillehousingdata
Set SaleDateConverted = Convert(SaleDate , Date)	

-- Populate Property Address Data
Select *
from nashvillehousingdata
where PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress , b.PropertyAddress)
from nashvillehousingdata a
join nashvillehousingdata b
	on a.ParcelID = b.ParcelID 
    And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-- Update ProperyAddress 
Update nashvillehousingdata a
join nashvillehousingdata b
	on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
Set a.PropertyAddress = IFNULL(a.PropertyAddress , b.PropertyAddress)
Where a.PropertyAddress is null

-- Breaking ProperyAddress to Individual Columns ( Address, City, State)
Select PropertyAddress
from nashvillehousingdata

Select Substring_Index (PropertyAddress, ',', 1) as Address , 
		Substring_Index (PropertyAddress, ',', -1) as City
from nashvillehousingdata

Alter table nashvillehousingdata
Add PropertySplitAddress nvarchar(255)

Update nashvillehousingdata
Set PropertySplitAddress = Substring_Index (PropertyAddress, ',', 1) 

Alter table nashvillehousingdata
Add PropertySplitCity nvarchar(255)

Update nashvillehousingdata
Set PropertySplitCity = Substring_Index (PropertyAddress, ',', -1) 

-- Breaking down Owner Address (Address, City, State)
Select OwnerAddress
from nashvillehousingdata

Select Substring_Index(Substring_index(OwnerAddress, ',' , 2), ',' , -1) as City,
		Substring_Index(OwnerAddress, ',',1) as Address,
        Substring_Index(OwnerAddress, ',', -1) as State
from nashvillehousingdata

Alter table nashvillehousingdata
Add OwnerSplitAddress nvarchar(255)

Update nashvillehousingdata
Set OwnerSplitAddress = Substring_Index(OwnerAddress, ',',1) 

Alter table nashvillehousingdata
Add OwnerSplitCity nvarchar(255)

Update nashvillehousingdata
Set OwnerSplitCity = Substring_Index(Substring_index(OwnerAddress, ',' , 2), ',' , -1) 

Alter table nashvillehousingdata
Add OwnerSplitState nvarchar(255)

Update nashvillehousingdata
Set OwnerSplitState = Substring_Index(OwnerAddress, ',', -1) 

Select * from nashvillehousingdata

-- Change Y and N to Yes and No in "SoldAsVacant" field
select SoldAsVacant 
from nashvillehousingdata
group by SoldAsVacant

Select SoldAsVacant , 
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
from nashvillehousingdata;

Update nashvillehousingdata
Set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End

-- Remove Duplicates
Select * from nashvillehousingdata

With RowNumCTE as (
Select *, ROW_Number() Over ( Partition by ParcelID,
											PropertyAddress,
                                            SalePrice,
                                            SaleDate,
                                            LegalReference
                                            Order by 
                                            UniqueID ) row_num
from nashvillehousingdata
)
Delete
from nashvillehousingdata using nashvillehousingdata join RowNumCTE on nashvillehousingdata.UniqueID = RowNumCTE.UniqueID
Where RowNumCTE.row_num > 1

With RowNumCTE as (
Select *, ROW_Number() Over ( Partition by ParcelID,
											PropertyAddress,
                                            SalePrice,
                                            SaleDate,
                                            LegalReference
                                            Order by 
                                            UniqueID ) row_num
from nashvillehousingdata
)
Select *
from RowNumCTE
Where row_num > 1

-- Delete Unused Collumns
Select * from nashvillehousingdata

Alter table nashvillehousingdata
Drop OwnerAddress, 
Drop TaxDistrict,
Drop PropertyAddress
