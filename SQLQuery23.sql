select * 
from [Nashville Housing Data for Data Cleaning]



--Populate Property Address data

Select * 
From PortfolioProject..[Nashville Housing Data for Data Cleaning]
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[Nashville Housing Data for Data Cleaning] a
join PortfolioProject..[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a 
SET PropertyAddress=ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[Nashville Housing Data for Data Cleaning] a
join PortfolioProject..[Nashville Housing Data for Data Cleaning] b
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null




--Breaking out Address into Individual Columns (address, city, state)

select PropertyAddress 
from PortfolioProject..[Nashville Housing Data for Data Cleaning]


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject..[Nashville Housing Data for Data Cleaning]


ALTER TABLE PortfolioProject..[Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE PortfolioProject..[Nashville Housing Data for Data Cleaning]
Add PropertySplitCity nvarchar(255);


Update [Nashville Housing Data for Data Cleaning]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))






--Owner address

Select
Parsename(Replace(OwnerAddress, ',', '.'),3),
Parsename(Replace(OwnerAddress, ',', '.'),2),
Parsename(Replace(OwnerAddress, ',', '.'),1)
from PortfolioProject..[Nashville Housing Data for Data Cleaning]



ALTER TABLE PortfolioProject..[Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'),3)



ALTER TABLE PortfolioProject..[Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'),2)




ALTER TABLE PortfolioProject..[Nashville Housing Data for Data Cleaning]
Add OwnerSplitState nvarchar(255);

Update [Nashville Housing Data for Data Cleaning]
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'),1)



--Remove duplicates

WITH RowNumCTE as(
Select *, 
ROW_NUMBER() OVER(
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID ) row_num

from PortfolioProject..[Nashville Housing Data for Data Cleaning])

Delete
from RowNumCTE
where row_num>1




--Delete Unused Columns


Alter table PortfolioProject..[Nashville Housing Data for Data Cleaning]
Drop column OwnerAddress, TaxDistrict, PropertyAddress






