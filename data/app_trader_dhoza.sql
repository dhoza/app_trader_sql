gitselect * from app_store_apps
SELECT * FROM PLAY_STORE_APPS;

-- getting names in common for both tables and reviews in each #499
SELECT
	DISTINCT a.name,p.rating AS play_rating,
	p.review_count AS play_review, 
	CAST(a.review_count as int) as app_review,
	a.rating as app_rating
FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON a.name = p.name
order by a.name


--getting highest avg rating
SELECT
	DISTINCT p.name, AVG(rating) as avg_rating
FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON a.name = p.name
group by p.name
order by avg_rating desc

--getting highest priced

SELECT DISTINCT(p.name),





SELECT
	 p.name,p.price
FROM play_store_apps as p
INNER JOIN app_store_apps as a
ON a.name = p.name
Order by p.name







