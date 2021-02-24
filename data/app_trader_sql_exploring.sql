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
SELECT a.price as app_store, LTRIM(p.price,'$') as play_store
from app_store_apps as a
INNER JOIN
play_store_apps as p
ON p.name=a.name
WHERE a.price > 0
--AND CAST(p.price as float) > 0;  --Note that this CAST does not work