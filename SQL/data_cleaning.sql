/*
Cleaning Data in SQL for Amazon Sales
Skills used : CREATE, UPDATE, SELECT, CTE, JOINS, ORDER BY, GROUP BY
*/


/*Standardize Date Format*/


select `Sale Date` 
from amazon_sales_data;


select `Sale Date`, convert(`Sale Date`, date)
from amazon_sales_data;


update amazon_sales_data 
set `Sale Date`= convert(`Sale Date`, date);

--------------------------------------------------------------------------------------------------------------------------


/*Populate Product Name Data*/


select * 
from amazon_sales_data
where `Product Name` is null
order by `Product ID`;


select a.`Product ID` , b.`Product Name`, b.`Product ID`,
	ifnull(a.`Product Name`, b.`Product Name`) as `Name To Be Filled`
from amazon_sales_data a
join amazon_sales_data b
	on a.`Product ID` = b.`Product ID` 
where a.`Product Name` is null;


update a 
set a.`Product Name` = ifnull(a.`Product Name`, b.`Product Name`)
from amazon_sales_data a
join amazon_sales_data b
	on a.`Product ID` = b.`Product ID` 
where a.`Product Name` is null;

--------------------------------------------------------------------------------------------------------------------------


/*Breaking out Customer Address into Individual Columns (Address, City, State)*/


select `Customer Address` 
from amazon_sales_data;


alter table amazon_sales_data 
add `Customer Split Address` varchar(255);


update amazon_sales_data 
set `Customer Split Address` = substring(`Customer Address`, 1, locate(',', `Customer Address`) - 1);


alter table amazon_sales_data 
add `Customer City` varchar(255);


update amazon_sales_data 
set `Customer City` = substring(`Customer Address`, locate(',', `Customer Address`) + 1, length(`Customer Address`));


select `Customer Address`
from amazon_sales_data;

--------------------------------------------------------------------------------------------------------------------------


/*CREATING A SPLIT STRING FUNCTION TO SPLIT THE CUSTOMER ADDRESS*/


create function SPLIT_STR(
  x varchar(255),
  delim varchar(12),
  pos int
)
return varchar(255)
return replace(substring(substring_index(x, delim, pos),
       length(substring_index(x, delim, pos -1)) + 1),
       delim, '');


alter table amazon_sales_data 
add `Address` varchar(255);


update amazon_sales_data 
set `Address` = SPLIT_STR(`Customer Address`, ',', 1);


alter table amazon_sales_data 
add `City` varchar(255);


update amazon_sales_data 
set `City` = SPLIT_STR(`Customer Address`, ',', 2);


alter table amazon_sales_data 
add `State` varchar(255);


update amazon_sales_data 
set `State` = SPLIT_STR(`Customer Address`, ',', 3);

--------------------------------------------------------------------------------------------------------------------------


/*Change Y and N to Yes and No in `Gift Wrapped` */


select distinct (`Gift Wrapped`), count(`Gift Wrapped`) 
from amazon_sales_data 
group by `Gift Wrapped`
order by `Gift Wrapped`;


update amazon_sales_data 
set `Gift Wrapped`  = case 
	when `Gift Wrapped` = 'Y' then 'Yes'
	when `Gift Wrapped` = 'N' then 'No'
	end;

--------------------------------------------------------------------------------------------------------------------------	
	
	
/*Remove Duplicate Orders*/


with OrderNumCTE 
as 
(
select *, 
	row_number() OVER(
	partition by
				`Order ID`,
				`Product ID`,
				`Sale Price`, 
				`Sale Date`
				order by 
					OrderID
					) row_num
from amazon_sales_data  	
)
delete 
from OrderNumCTE
where row_num > 1;
	
--------------------------------------------------------------------------------------------------------------------------
	
	
/*Delete Unused Columns*/


alter table amazon_sales_data 
drop column `Customer Address`, `Gift Note`, `Shipping Date`;

--------------------------------------------------------------------------------------------------------------------------

