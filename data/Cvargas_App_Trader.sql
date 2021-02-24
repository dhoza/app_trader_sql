--select * from app_store_apps--
Select name,price,rating
from app_store_apps
where price = 0 AND rating = '5'
ORDER BY rating DESC
LIMIT 10; 



Select * from play_store_apps;

Select name, rating, price
FROM play_store_apps
WHERE rating = '5' AND price = '0' 
ORDER BY rating DESC
LIMIT 10;

Select *
FROM app_store_apps
WHERE review_count > '100000';


Select DISTINCT(p.rating), a.rating, p.name, a.name, p.price, CAST(a.price as text), p.review_count, CAST(a.review_count AS integer) 
FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON p.name = a.name 
ORDER BY p.price
LIMIT 10;





