/*apps that cost $0.00 - $1.00*/
SELECT a.name, a.price, CAST(subquery.price AS float)
FROM
	(SELECT RTRIM(LTRIM(price, '$')) AS price, name
	FROM play_store_apps) as subquery
INNER JOIN app_store_apps as a
ON subquery.name = a.name
/* apps with different prices in different stores that are 0 - 1 dollar in apple store*/
WHERE a.price >= 0 AND a.price <= 1.00 AND CAST(subquery.price AS float) != a.price;

/*apps that cost $0.00 - $1.00*/
SELECT a.name, a.price, CAST(subquery.price AS float)
FROM
	(SELECT RTRIM(LTRIM(price, '$')) AS price, name
	FROM play_store_apps) as subquery
INNER JOIN app_store_apps as a
ON subquery.name = a.name
/* apps with different prices in different stores that are 0 - 1 dollar in play store*/
WHERE CAST(subquery.price AS float) >= 0 AND CAST(subquery.price AS float) <= 1.00 AND a.price != CAST(subquery.price AS float);

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* find top 10 rating that exist in both app stores*/
SELECT a.name, MAX(a.rating), MAX(p.rating)
FROM app_store_apps AS a
JOIN play_store_apps AS p
ON a.name = p.name
GROUP BY a.name, a.rating, p.rating
ORDER BY a.rating DESC
LIMIT 10;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* count of genres in apple store and play store */
SELECT primary_genre, COUNT(primary_genre)
FROM app_store_apps
GROUP BY primary_genre
ORDER BY COUNT(primary_genre) DESC;

SELECT genres, COUNT(genres)
FROM play_store_apps
GROUP BY genres
ORDER BY COUNT(genres) DESC;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* difference in app store rating */
SELECT sub.name, sub.difference - CAST(p.rating AS float) AS difference
FROM
	(SELECT name, rating, CAST(rating AS float) AS difference
	FROM app_store_apps) as sub
JOIN play_store_apps as p
ON sub.name = p.name;

/*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/* highest review count and their rating */

SELECT name, review_count, rating
FROM play_store_apps
ORDER BY review_count DESC;

SELECT name, review_count, rating
FROM play_store_apps
ORDER BY review_count DESC;