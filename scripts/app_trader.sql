SELECT DISTINCT(a.name), p.name, a.price, p.price, a.primary_genre,
p.genres, a.content_rating, p.content_rating, a.rating, p.rating,
a.review_count, p.review_count
FROM app_store_apps AS a 
FULL OUTER JOIN play_store_apps AS p
ON a.name = p.name
WHERE a.name IS NOT null
AND p.name IS NOT null
AND CAST(a.review_count AS int) > 10000
AND p.review_count > 10000;
