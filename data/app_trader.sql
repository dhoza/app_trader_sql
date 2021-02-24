/*apps that cost $0.00 - $1.00*/

SELECT a.name, a.price, LTRIM(p.price,'$')
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
ON a.name = p.name
/* apps with different prices in different stores */
WHERE a.price >= 0 AND a.price <= 1.00 AND CAST(p.price AS float) != '0';


SELECT a.name, a.price, CAST(subquery.price AS float)
FROM
	(SELECT RTRIM(LTRIM(price, '$')) AS price, name
	FROM play_store_apps) as subquery
INNER JOIN app_store_apps as a
ON subquery.name = a.name
WHERE CAST(subquery.price AS float) != 0;

