/*
Assumptions about the project's objectives:
- longer potential lifespan of an app means more time to collect revenue from in-app ads and purchases
	- lifespan is directly tied to ratings
		- make sure rating is high in both stores?
- preference to work with apps in both stores
- probably want to spend less to get the rights (i.e. not necessarily 10,000 times the price of the app)

--------------------------
Things to include in query magic:
- review_counts > x
- DISTINCT names?
- difference in ratings between store is less or equal to X (ensure both versions of the app have staying power)
- price * 10,000 if app is not free, to determine cost
*/

--Starting with a UNION
Select p.genres, p.rating, p.name, p.price, p.review_count from play_store_apps as p
where p.rating IS NOT NULL 
and p.review_count>50 
UNION
Select a.primary_genre, a.rating, a.name, CAST(a.price as text), CAST(a.review_count AS integer) from app_store_apps as a
where a.rating IS NOT NULL 
ORDER BY rating DESC;

--Didn't like UNION, trying INNER JOIN
Select p.genres, a.primary_genre, p.rating, a.rating, p.name, a.name, p.price, CAST(a.price as text), 
		p.review_count, CAST(a.review_count AS integer) 
FROM play_store_apps as p
INNER JOIN
app_store_apps as a
ON p.name=a.name
where p.rating IS NOT NULL 
AND a.rating IS NOT NULL;

----------------------
/*Getting information about ratings and review counts from both tables*/
--Play Store
Select MIN(rating) from play_store_apps where rating IS NOT NULL;
--1
Select COUNT(rating) from play_store_apps where rating = 1;
--16

--App Store
Select MIN(rating) from app_store_apps where rating != 0;
--1
Select COUNT(rating) from app_store_apps where rating = 1;
--44

--How many reviews are in each store? (Could focus where there are the most reviews?)
Select SUM(review_count) from play_store_apps;
--4814617393
Select SUM(review_count::integer) from app_store_apps;
--92790253

/*How many apps are in each store? (Mostly just curious, as expected revenue is not dependent on store, 
but there might be gems in the Play store which has apps that are not also in the App store)*/
Select COUNT(name) from play_store_apps;
--10840
Select COUNT(name) from app_store_apps;
--7197

-------------------------------------
--Comparing prices between stores
SELECT a.name, a.price as app_store, LTRIM(p.price,'$') as play_store
from app_store_apps as a
INNER JOIN
play_store_apps as p
ON p.name=a.name
WHERE a.price > 0;

-------
--Comparing ratings between stores
SELECT a.name AS name, a.rating AS app_store_rating, p.rating AS play_store_rating, CAST(a.rating as float) - CAST(p.rating as float) AS difference
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name=p.name
WHERE a.rating > 4
AND p.rating > 4
GROUP BY a.name, a.rating, p.rating;

--Selecting names where difference between rating is less than or equal to .5
----Start by getting a differences in ratings as a query output:
/*SELECT a.name AS name, a.rating AS app_store_rating, p.rating AS play_story_rating, CAST(a.rating as float) - CAST(p.rating as float) AS difference
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
	ON a.name=p.name
	WHERE difference <= .2
	GROUP BY a.name, a.rating, p.rating;*/

----------------------------------------------------
--Apps with small difference in ratings between stores, where ratings in both stores are above or equal to 4.  We assume this ensures longesvity based on app quality.
SELECT DISTINCT a.name, a.rating AS app_store_rating, p.rating AS play_store_rating, CAST(sub.difference as float)
FROM (SELECT a.name AS subname, CAST(a.rating as float) - CAST(p.rating as float) AS difference
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
	ON a.name=p.name) as sub
INNER JOIN app_store_apps AS a
ON a.name=sub.subname
INNER JOIN play_store_apps as p
ON a.name=p.name
--Limit what we're looking at to apps with good reviews in both stores
WHERE a.rating >= 4
AND p.rating >= 4
AND sub.difference BETWEEN -.2 AND .2
ORDER BY p.rating DESC
--because Play store has more reviews and larger audience, order by play_store_rating
;

----------------------------------Calculating the price for AppTrader to buy marketing rights
--------App store
SELECT name, price, CASE
WHEN price = 0 THEN 10000
WHEN price > 0 THEN price*10000
ELSE 0 END AS calc_price
FROM app_store_apps
ORDER BY price ASC;

--------Play Store
/*doesn't cast as float, probably need to do the CASE somewhere else
SELECT name, CAST(REPLACE(price,'$','')AS float), CASE
WHEN price = 0 THEN 10000
WHEN price > 0 THEN price*10000
ELSE 0 END AS calc_price
FROM play_store_apps
ORDER BY price ASC; 
*/

/*
WITH play_store_price AS 
	(SELECT name, CAST(REPLACE(price,'$','')AS float) from play_store_apps)
--), app_store_price AS
--	(SELECT name, price) from app_store_apps
SELECT p.price, CASE
WHEN p.price = 0 THEN 10000
WHEN p.price > 0 THEN p.price*10000
ELSE 0 END AS calc_price
FROM play_store_price AS p
ORDER BY price ASC;
*/