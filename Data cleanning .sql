# Cleaning data in SQL queries
select *
from housing.table;
# Checking null values 
select PropertyAddress
    FROM housing.table
   WHERE PropertyAddress IS NULL;

SELECT a1.ParcelID,
a1.PropertyAddress,
a2.ParcelID,
a2.PropertyAddress,
    CASE 
    WHEN a1.PropertyAddress IS NULL THEN a2.PropertyAddress ELSE a1.PropertyAddress END
    FROM housing.table AS a1
LEFT JOIN
   housing.table AS a2
   ON a1.ParcelID=a2.ParcelID
 AND a1.UniqueID<>a2.UniqueID
 WHERE a1.PropertyAddress IS NULL ;
 
  SELECT a1.ParcelID,
   a1.PropertyAddress,
   a2.ParcelID,
   coalesce(a1.PropertyAddress,a2.PropertyAddress)
FROM housing.table AS a1
  JOIN
   housing.table AS a2
 ON a1.ParcelID=a2.ParcelID
  AND a1.UniqueID<>a2.UniqueID
WHERE a1.PropertyAddress IS NULL;
   -- updating the property address
SET SQL_SAFE_UPDATES = 0;
UPDATE  housing.table AS a1  
JOIN   housing.table AS a2  
ON a1.ParcelID=a2.ParcelID  AND a1.UniqueID<>a2.UniqueID    
SET    a1.PropertyAddress =coalesce(a1.PropertyAddress,a2.PropertyAddress)  
 WHERE a1.PropertyAddress IS NULL;
 
 SELECT PropertyAddress
 FROM housing.table;
 
# WHERE PROPERTY ADDRESS IS NULL, order by ParcelID
 SELECT substring(PropertyAddress,1,locate(',',PropertyAddress)-1) AS Address,
substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress)) AS Address
 FROM housing.table;
 
ALTER TABLE housing.table
ADD PropertysplitAddress VARCHAR(255);
 
 UPDATE housing.table
 SET PropertysplitAddress=substring(PropertyAddress,1,locate(',',PropertyAddress)-1);
 
 Alter TABLE housing.table
 ADD Propertysplitcity VARCHAR(255);
 
 UPDATE housing.table
 SET Propertysplitcity =substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress));

SELECT *
FROM housing.table;

# Breaking out owner address into  (address,city and state)

SELECT OwnerAddress
FROM housing.table;

SELECT 
substring_index(OwnerAddress,',',1),
substring_index(substring_index(OwnerAddress,',',2),',','-1'),
substring_index(OwnerAddress,',',-1)
FROM housing.table;

ALTER TABLE housing.table
ADD OwnersplitAddress VARCHAR(255);

UPDATE housing.table
SET OwnersplitAddress=substring_index(OwnerAddress,',',1);

ALTER TABLE housing.table
ADD OwnersplitCity VARCHAR(255);

UPDATE housing.table
SET OwnersplitCity=substring_index(substring_index(OwnerAddress,',',2),',','-1');

Alter TABLE housing.table
ADD OwnersplitState VARCHAR(255);

UPDATE housing.table
SET OwnersplitState=substring_index(OwnerAddress,',',-1);

SELECT *
FROM housing.table;

# Change Y and N to Yes and No in the SoldAsVacant field

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant ='Y' THEN 'Yes' 
WHEN SoldAsVacant='N' THEN 'NO'
ELSE SoldAsVacant 
END
FROM housing.table;

UPDATE  housing.table
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes' 
WHEN SoldAsVacant='N' THEN 'NO'
ELSE SoldAsVacant 
END;

-- identifying duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) AS row_num
FROM housing.table;


 -- delete unused columns
 
 SELECT *
 FROM housing.table;
 
 ALTER TABLE housing.table
 DROP COLUMN OwnerAddress;
 ALTER TABLE housing.table
 DROP COLUMN PropertyAddress;
  ALTER TABLE housing.table
 DROP COLUMN TaxDistrict;
ALTER TABLE housing.table
 DROP COLUMN SaleDate;
 
 -- final table
 SELECT *
 FROM housing.table
