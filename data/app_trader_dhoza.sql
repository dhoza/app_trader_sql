
---------FINAL EVALUATION USING CTEs-329 rows--getting extra column of price app trader will pay for app=purchase price * 10K, ordered by importance to app trader----
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
),
 review_diff AS 
	(SELECT DISTINCT a.name, a.rating AS app_store_rating, p.rating AS play_store_rating, CAST(sub.difference as numeric)
	FROM (SELECT a.name AS subname, CAST(a.rating as numeric) - CAST(p.rating as numeric) AS difference
		FROM app_store_apps AS a
		INNER JOIN play_store_apps AS p
		ON a.name=p.name) as sub
	INNER JOIN app_store_apps AS a
	ON a.name=sub.subname
	INNER JOIN play_store_apps as p
	ON a.name=p.name
	--Limit what we're looking at to apps with good reviews in both stores, where difference in ratings between stores is small
		WHERE a.rating >= 4
		AND p.rating >= 4
		AND sub.difference BETWEEN -.2 AND .2)
SELECT a.name,p.genres,p.content_rating,round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price
FROM app as a
INNER JOIN play as p 
ON a.name = p.name
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC;
---------------------------------------------------------------------------------------------------------------	 
-----Megan's query integrated with mne__________________________________________
   
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
), review_diff AS 
	(SELECT DISTINCT a.name, a.rating AS app_store_rating, p.rating AS play_store_rating, CAST(sub.difference as numeric)
	FROM (SELECT a.name AS subname, CAST(a.rating as numeric) - CAST(p.rating as numeric) AS difference
		FROM app_store_apps AS a
		INNER JOIN play_store_apps AS p
		ON a.name=p.name) as sub
	INNER JOIN app_store_apps AS a
	ON a.name=sub.subname
	INNER JOIN play_store_apps as p
	ON a.name=p.name
	--Limit what we're looking at to apps with good reviews in both stores, where difference in ratings between stores is small
		WHERE a.rating >= 4
		AND p.rating >= 4
		AND sub.difference BETWEEN -.2 AND .2)
		
SELECT DISTINCT(a.name),r.difference,p.genres,p.content_rating,round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,
trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,
a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price
FROM app as a
INNER JOIN play as p
ON a.name = p.name
INNER JOIN review_diff AS r
ON a.name=r.name
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC
LIMIT 40;
--*******CTE-ultimately getting rid of duplicates by avg 2 tables separately
--app store -getting app_store_apps stats, average of duplicates CTE !!328 rows
WITH app AS
(SELECT
	name,avg(rating) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name
), play as 
(SELECT
	name,avg(rating) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
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

---getting top genre
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
SELECT p.genres,p.content_rating,a.app_avg_rating ,p.play_avg_rating,trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews
FROM app as a
INNER JOIN play as p 
ON a.name = p.name
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC;

----GETTING NUMBERS ON TOP 10
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
SELECT a.name,
p.genres,p.content_rating,
round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC(app_total_reviews+play_total_reviews) as all_total_reviews,a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price,
		(round(p.play_avg_rating,2)/0.5) as year_longevity,
		(round(p.play_avg_rating,2)/0.5)*48000-(CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END) as year_profit
FROM app as a
INNER JOIN play as p 
ON a.name = p.name
--where A.NAME ilike 'PewDiePie%' OR a.name ILIKE 'Domino%' or a.name ilike 'Egg%' or a.name ilike 'Cytus' or a.name ilike 'ASOS'
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC;


-----pulling only profit numbers for slide
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
SELECT a.name,
--p.genres,p.content_rating,
--round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,
--trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,
--TRUNC(app_total_reviews+play_total_reviews) as all_total_reviews,
a.app_avg_price,p.play_avg_price,
	trunc(CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END) AS App_trader_purchase_price,
		cast((round(p.play_avg_rating,2)/0.5)as float) as year_longevity,
		trunc((round(p.play_avg_rating,2)/0.5)*48000-(CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END)) as year_profit
FROM app as a
INNER JOIN play as p 
ON a.name = p.name
--where A.NAME ilike 'PewDiePie%' OR a.name ILIKE 'Domino%' or a.name ilike 'Egg%' or a.name ilike 'Cytus' or a.name ilike 'ASOS'
ORDER BY app_avg_rating DESC,play_avg_rating DESC
--all_total_reviews DESC;
--app_avg_price DESC;









