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


-- age consistency
select id , current_age , (Year(GETDATE()) - birth_year) as excpected_age
from users_data
where current_age <> (Year(GETDATE()) - birth_year)  -- show different rows 

-- demograghy ensurance
select * 
from users_data
where [latitude] not between -90 and 90 or 
  [longitude] not between -180 and 180 ;