/*This query identifies app with high ratings across both stores, including the content rating, category/genre, and cost to purchase the marketing rights
*/ 
WITH app AS
(SELECT
	name,avg(rating) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name
), play as
(SELECT
	name, category, genres,content_rating,avg(rating) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
FROM play_store_apps
 GROUP BY name,category, genres,content_rating
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
		
SELECT DISTINCT(a.name),r.difference,p.genres,p.category,p.content_rating,round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,
trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,
a.app_avg_price,p.play_avg_price,
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price
FROM app as a
INNER JOIN play as p
ON a.name = p.name
INNER JOIN review_diff AS r
ON a.name=r.name
WHERE p.content_rating='Everyone'
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC
LIMIT 100;