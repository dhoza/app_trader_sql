WITH review_diff AS 
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

SELECT DISTINCT(p.name), ROUND(review_diff.difference,1) AS store_ratings_diff, a.rating AS app_store_rating, p.rating AS play_store_rating
FROM play_store_apps AS p
FULL JOIN
review_diff
ON p.name=review_diff.name
INNER JOIN app_store_apps AS a
ON a.name=p.name
WHERE review_diff IS NOT NULL
ORDER BY app_store_rating DESC, store_ratings_diff DESC
--App store users are more discerning (based on percentage of apps with 1-2 star reviews per store), 
--so ordering by app_store_rating descending, and then difference between stores.
;