/*This query identifies app with high ratings across both stores, including the content rating, category/genre, and cost to purchase the marketing rights
*/ 
-------------------------------------------------------------------------------------------
WITH app AS
(SELECT
	 name,avg(rating) as app_avg_rating,round(SUM(cast(review_count as int)),2) as app_total_reviews,round(avg(price),2) as app_avg_price
FROM app_store_apps
 GROUP BY name), 
 
play as
(SELECT
	name, category, genres,content_rating,avg(rating) as play_avg_rating,round(SUM(cast(review_count as int)),2) as play_total_reviews,avg(CAST(REPLACE(price,'$','')AS float)) as play_avg_price
FROM play_store_apps
 GROUP BY name,category, genres,content_rating), 

-----------Adding this review_diff CTE into the main query to retreive the difference in reviews between stores
review_diff AS 
(SELECT 
 	DISTINCT a.name, a.rating AS app_store_rating, p.rating AS play_store_rating, rating_difference
FROM 
 	--This standardizes the ratings columns to numeric and outputs the difference between stores
 	(SELECT a.name AS subname, CAST(a.rating as numeric) - CAST(p.rating as numeric) AS rating_difference
		FROM app_store_apps AS a
		INNER JOIN play_store_apps AS p
			ON a.name=p.name) AS sub
	--This allows us to add columns for the rating in each store, alongside the difference
 	INNER JOIN app_store_apps AS a
		ON a.name=sub.subname
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
	--This is that part that limits what we're looking at to apps with good reviews in both stores, where difference in ratings between stores is small
		WHERE a.rating >= 4
		AND p.rating >= 4
 		--Pulling from the 
		AND sub.rating_difference BETWEEN -.2 AND .2
ORDER BY rating_difference DESC, app_store_rating DESC)
----Final/overall output begins below		
SELECT DISTINCT a.name,r.rating_difference,p.genres,p.category,p.content_rating,round(a.app_avg_rating,2) as app_avg_rating ,round(p.play_avg_rating,2) as play_avg_rating,
trunc(a.app_total_reviews) as app_all_reviews,trunc(p.play_total_reviews) as play_all_reviews,TRUNC((app_total_reviews+play_total_reviews)/2) as all_total_reviews,
a.app_avg_price,p.play_avg_price,
	--How much does it cost AppTrader to purchase the marketing rights to the app?
	CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END AS App_trader_purchase_price,
	--Calculate the expected longevity of the app and its expected lifetime profit for AppTrader
	((round(CAST((a.app_avg_rating+p.play_avg_rating)AS float))/2)/0.5)+1 as year_longevity,
	(((round(CAST((a.app_avg_rating+p.play_avg_rating)AS float))/2)/0.5)+1)*48000-(CASE WHEN app_avg_price <= 1.00 THEN 10000
		WHEN app_avg_price >1.00 THEN app_avg_price*10000 END) AS end_of_longevity_profit
FROM app as a
INNER JOIN play as p
ON a.name = p.name
INNER JOIN review_diff AS r
ON a.name=r.name
--Choosing broad content rating to make marketing easier and less need to target age demographics
WHERE p.content_rating='Everyone'
ORDER BY app_avg_rating DESC,play_avg_rating DESC,all_total_reviews DESC,app_avg_price DESC
;

