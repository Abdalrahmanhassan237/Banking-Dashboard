-- null values 
select count(*) 
from users_data as u
where birth_year is null
or birth_month is null 
or current_age is null 

-- duplicate values
select id , count(id)
from users_data
group by id
having count(id) > 1 ; -- show only repeated values 



-- demograghy ensurance
select * 
from users_data
where [latitude] not between -90 and 90 or 
  [longitude] not between -180 and 180 ;


-- quick review about data before deep cleaning (NULL / EMPTY)

select count(*) as total_rows , 
sum(case when gender is null or LTRIM(RTRIM(gender)) = '' then 1 else 0 end) as null_gender ,
sum(case when users.address  is null or ltrim(rtrim(address)) = '' then 1 else 0 end) as null_address , 
sum(case when [credit_score] is null then 1 else 0 end) as null_credit_score ,

--(2) financial column 

sum(case when per_capita_income is null or ltrim(rtrim(cast(per_capita_income as nvarchar(50)))) = '' then 1 else 0 end) as _null_per_capita_income , 
sum(case when total_debt is null or ltrim(rtrim(cast(total_debt as nvarchar(50)))) = '' then 1 else 0 end) as null_total_debt , 
sum(case when yearly_income is null or ltrim(rtrim(cast(yearly_income as nvarchar(50)))) = '' then 1 else 0 end) as null_yearly_income , 

--(3) current_age column
sum(case when current_age  is null  then 1 else 0 end) as null_current_age ,
sum(case when current_age  < 0 or current_age > 120  then 1 else 0 end) as bad_current_age , 
sum(case when current_age  > 100  then 1 else 0 end) as over_100_age ,


--(4) birht_year column 
sum(case when birth_year is null or birth_year < 1900 or birth_year > year(GETDATE()) then 1 else 0 end) as bad_birth_year,
sum(case when birth_month is null or birth_month < 1 or birth_month > 12 then 1 else 0 end) as bad_birth_month ,

--5) retirement_age

sum(case when retirement_age is null then 1 else 0 end ) as null_retirement_age , 
sum(case when retirement_age is not null and (retirement_age < 40 or retirement_age > 75) then 1 else 0 end ) as bad_retirement_range , 
sum(case when retirement_age is not null and current_age is not null  and (retirement_age <= current_age) then 1 else 0 end ) as ret_le_cuurent 



from [dbo].[users_data] as users ;


--6) Age consistency with month consideration

select 
	id , current_age ,
	-- calculated_age

	datediff( year , cast( cast(birth_year as varchar) + '-' + right('00' + cast(birth_month as varchar),2) + '-01' as date) , getdate() )
		- case when (month(getdate()) < birth_month) then 1 else 0 end as calculated_age , 

	-- difference age in year
	abs(current_age - (datediff( year , cast( cast(birth_year as varchar) + '-' + right('00' + cast(birth_month as varchar),2) + '-01' as date) , getdate() )
		- case when (month(getdate()) < birth_month) then 1 else 0 end)) as age_difference

from users_data
where current_age <> (datediff( year , cast( cast(birth_year as varchar) + '-' + right('00' + cast(birth_month as varchar),2) + '-01' as date) , getdate() )
		- case when (month(getdate()) < birth_month) then 1 else 0 end)   -- show different rows 