--select * from app_store_apps--
Select name,price,rating,content_rating
from app_store_apps
where price = 0 AND rating = '5'
ORDER BY rating DESC
LIMIT 10; 



--Select * from play_store_apps;--

Select name, rating, price
FROM play_store_apps
WHERE rating = '5' AND price = '0' 
ORDER BY rating DESC
LIMIT 10;



Select DISTINCT(p.rating), a.rating, p.name, a.name, p.price, CAST(a.price as text), p.review_count, CAST(a.review_count AS integer) 
FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON p.name = a.name 
ORDER BY p.price
LIMIT 10;

 -- TOP 10 apps in both stores-- 
 
SELECT rating,name,price,
REPLACE(price,'$','') AS trim_price, CAST(REPLACE(price,'$','')AS float) AS float_price
FROM play_store_apps
WHERE CAST(REPLACE(price,'$','')AS float) > 3.99
AND rating IS NOT NULL
ORDER BY rating DESC;
 
 --Coverted price to float_price//by rating desc order--
 
SELECT a.name,p.name,a.price, p.price
FROM app_store_apps as a
INNER JOIN play_store_apps as p
on a.name = p.name
ORDER BY p.price, a.price DESC

--Comparing prices between both stores--

WITH app AS
(SELECT
	name,avg(rating) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name
), play as
(SELECT
	name,genres,content_rating,avg(rating) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
FROM play_store_apps
 GROUP BY name,genres,content_rating
)
SELECT a.name,p.genres,p.content_rating,round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price
FROM app as a
INNER JOIN play as p
ON a.name = p.name
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC;

--Debbie's Query--

Select a.name, p.name, a.content_rating, p.content_rating
FROM app_store_apps as a
INNER JOIN play_store_apps as p
ON a.content_rating = p.content_rating
ORDER BY a.content_rating,p.content_rating desc

--------




