select * from app_store_apps
order by name desc


SELECT * FROM PLAY_STORE_APPS
order by name desc; 

---FINAL EVALUATION USING CTEs--getting extra column of price app trader will pay for app=purchase price * 10K, ordered by importance to app trader----
WITH app AS
(SELECT
	name,round(avg(cast(rating as int)),2) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name
), play as 
(SELECT
	name,genres,content_rating,round(avg(cast(rating as int)),2) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
FROM play_store_apps
 GROUP BY name,genres,content_rating
)
SELECT a.name,p.genres,p.content_rating,a.app_avg_rating ,p.play_avg_rating,trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price
FROM app as a
INNER JOIN play as p 
ON a.name = p.name
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC;
	 

-- DO NOT USEgetting names in common for both tables and reviews in each #499
SELECT
	 a.name,p.rating AS play_rating,
	p.review_count AS play_review, 
	p.price as play_price,
	CAST(a.review_count as int) as app_review,
	a.rating as app_rating,
	p.price as play_price
FROM play_store_apps as p
INNER JOIN app_store_apps as a

ON a.name = p.name
order by a.name


--getting highest avg rating + lowest price + apps in both + highest avg review count
SELECT
	 distinct p.name, ((a.rating+p.rating)/2) as avg_rating, (cast(a.review_count as int)+cast(p.review_count as int)/2) as avg_review_count,genres,a.price as app_store_price,p.price as play_store_price
FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON a.name = p.name
WHERE a.price <= 1.00 and cast(replace(p.price,'$','')AS FLOAT) <= 1.00
order by avg_rating DESC,avg_review_count desc

--*******CTE-ultimately getting rid of duplicates by avg 2 tables separately
--app store -getting app_store_apps stats, average of duplicates CTE !!328 rows
WITH app AS
(SELECT
	name,round(avg(cast(rating as int)),2) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name
), play as 
(SELECT
	name,round(avg(cast(rating as int)),2) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
FROM play_store_apps
 GROUP BY name
)
select a.name,a.app_avg_rating ,p.play_avg_rating,a.app_total_reviews,p.play_total_reviews,a.app_avg_price,p.play_avg_price
from app as a inner join play as p 
     on a.name = p.name;
---GETTING PRICE app traders will pay for app
SELECT a.name,a.price as app_store_price,p.price as play_price,
case when a.price <= 1.00 then 10000
when a.price > 1.00 then 10000*a.price  end as app_purchase_price,
case when cast(REPLACE(p.price,'$','')AS FLOAT) <= 1.00 then 10000
when cast(REPLACE(p.price,'$','')AS FLOAT) > 1.00 then 10000* CAST(REPLACE(p.price,'$','')AS FLOAT)  end as play_purchase_price
from app_store_apps as a
INNER JOIN play_store_apps as p
ON p.name = a.name
ORDER BY app_purchase_price,play_purchase_price
------------------------------------
 --CTE play store-getting play_store_apps stats and avg of duplicates
SELECT
	p.name
	round(avg(cast(rating as int)),2) as avg_rating,
	round(SUM(cast(review_count as int)),2) as avg_review_count,
	avg(CAST(REPLACE(price,'$','')AS float)) as avg_price
FROM play_store_apps as p
 inner join app 
 on app.name = p.name
GROUP BY p.name
ORDER BY p.name 

FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON a.name = p.name
Order by p.name







