

--- Data Cleansing Using Sql Queries.


--- Populate Property Address where it is NULL 

/* Because there are some address which is null and there are duplicate ParcelID has the Property address that we will be populating. So,
no property address will left Null. */

Select * from Portfolio_Project..NashvilleHousing   --- we found it by sort using parcelID that the same parcel Id has address and other is NULL.
order By ParcelID;

/* Now, we will do self Join so we can populate the same parcel ID that has address into other Parcel ID that do not have the address. */

Select a.uniqueID,a.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress,B.PropertyAddress) from Portfolio_Project..NashvilleHousing a
join Portfolio_Project..NashvilleHousing b
on a.ParcelID = B.ParcelID
where a.UniqueID <> B.UniqueID and a.PropertyAddress is null 

--- Now, we will update it
Update a  --- we will call the table using alias.
set A.PropertyAddress = ISNULL(a.PropertyAddress,B.PropertyAddress) --check where there is a null value in a. property address then insert b. property address in that.
from Portfolio_Project..NashvilleHousing a
join Portfolio_Project..NashvilleHousing b
on a.ParcelID = B.ParcelID
where a.UniqueID <> B.UniqueID and a.PropertyAddress is null 


--- Breaking Proerty Address into individual column (Address, Property_City)


/*  in column we have addres before coma. So, we searched till coma and we got the address, but after coma we have the city that we need into a different column,
did the same thing but the starting string should be from coma position upto the lenght of the string same way we did  -1 added +1 here so it will move one letter upward
*/

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Property_City
from Portfolio_Project..NashvilleHousing;


/*Alter Table Portfolio_Project..NashvilleHousing    -- Created the column and so we can store the address and city
Add Address Varchar(50), Owner_City Varchar(50); */


Update Portfolio_Project..NashvilleHousing
Set Address =  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1), City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress));


--- Extract State from Owners Address

/* We can also use above function but it would be a little complex. We can use parsename(). that works only with periods(.). So we replace the (,) with (.) and then using parsename we can extract
But it reads from the right to left. So, Last word index would be 1st in that case.
*/

Select OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),1) State
from Portfolio_Project..NashvilleHousing;

Alter table Portfolio_Project..NashvilleHousing  --- Added state column
Add Owner_Address varchar(50);

Update Portfolio_Project..NashvilleHousing		--- Updated with the data
Set Owner_State =  PARSENAME(REPLACE(OwnerAddress,',','.'),1);


--- Update N to No and Y To Yes in SoldasVacant Column

--- You can also use Case query for this

update Portfolio_Project..NashvilleHousing
Set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y';



--- Removing Duplicate rows
--- Using Row_Number() function which assign same values to the uniques rows and to the duplicate rows it assign the next number to duplicates say 2. after we store the result in CTE.
--- And Delete the duplicate from there becuase you can not filter actual table using the alias Row_Num that you have created.

With Duplicate as(
Select *, ROW_NUMBER() Over (Partition By ParcelID,SaleDate,SalePrice,LegalReference Order BY UniqueID) as Row_Num from Portfolio_Project..NashvilleHousing
)
Select * from Duplicate
where Row_Num >1;


---- Deleting Unused Column	

Alter table Portfolio_Project..NashvilleHousing
Drop Column PropertyAddress,OwnerAddress,TaxDistrict;

Select * from Portfolio_Project..NashvilleHousing;





