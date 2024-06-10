-- Query for DVD rental project

-- Calculate the total revenue
SELECT SUM(amount) AS TotalRevenue FROM payment;

-- Average Payment Value
SELECT ROUND( ( SUM(amount) / COUNT(payment_id) ), 2) AS AvergaePaymentValue FROM payment;

--Total dvd given for rental
SELECT COUNT(rental_id) AS TotalRentals from payment;

-- Total Order count
SELECT COUNT(payment_id) AS TotalOrders FROM payment;

-- Average dvds rented per customer in total
SELECT ROUND ((SUM(rentalcount) / COUNT (customer_id)), 2) AS Avgdvdcust
FROM (
	SELECT customer_id, COUNT(rental_id) AS RentalCount FROM payment
	GROUP BY customer_id) AS data1;

-- Avevrage dvd replacement cost
SELECT rating, ROUND(AVG(replacement_cost), 2) AS avgcost FROM film
GROUP BY rating
ORDER BY avgcost DESC;

-- Yearly, Monthly, Daily dvd rental trend
SELECT year, month, to_char(renteddate, 'Month') AS monthname, renteddate, numberofdvds FROM (
SELECT EXTRACT(YEAR FROM rental_date) AS year, EXTRACT(MONTH FROM rental_date) AS month, DATE(rental_date) AS renteddate, COUNT(rental_id) AS Numberofdvds FROM rental
GROUP BY EXTRACT(YEAR FROM rental_date), EXTRACT(MONTH FROM rental_date), DATE(rental_date)
ORDER BY renteddate DESC
) AS trenddata;

-- Day of the week trend
/*
SELECT EXTRACT(DOW FROM rental_date) AS daynum, TO_CHAR(rental_date, 'Day') AS dayofweek
FROM rental;
*/
SELECT EXTRACT(DOW FROM rental_date) AS daynum, TO_CHAR(rental_date, 'Day') AS dayofweek, COUNT(rental_id) AS Numberofdvds FROM rental
GROUP BY TO_CHAR(rental_date, 'Day'), EXTRACT(DOW FROM rental_date)
ORDER BY daynum ASC;

-- Hour of the day trend
-- to_char(rental_date, 'MI') for minutes
SELECT rental_date, DATE(rental_date) AS rentdate, to_char(rental_date, 'HH24') AS Hourofday, COUNT(rental_id) FROM rental
GROUP BY rental_date, DATE(rental_date), to_char(rental_date, 'HH24')
ORDER BY rentdate DESC;

-- Film Details master table
WITH cte_1 AS (
	SELECT film_id, fc.category_id, c.name FROM film_category fc
	LEFT OUTER JOIN category c
	ON fc.category_id = c.category_id
),
cte_2 AS (
	SELECT f.film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, cf.category_id, cf.name AS category FROM cte_1 cf
	LEFT OUTER JOIN film f
	ON cf.film_id = f.film_id
),
cte_3 AS (
	SELECT film_id, title, description, release_year, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, category_id, category, l.language_id, l.name AS Lang FROM cte_2 c2
	LEFT OUTER JOIN language l
	ON c2.language_id = l.language_id
)
SELECT * FROM cte_3;

-- Customer Data master details
WITH customer_1 AS (
	SELECT customer_id, store_id, concat(first_name, ' ', last_name) AS FullName, email, activebool, create_date, active, c.address_id, address, a.address2, a.district, a.city_id, a.postal_code, a.phone FROM customer c
	LEFT OUTER JOIN address a
	ON c.address_id = a.address_id
),
customer_2 AS (
	SELECT * FROM customer_1 c1
	LEFT OUTER JOIN city
	ON c1.city_id = city.city_id
),
customer_3 AS (
	SELECT customer_id, store_id, fullname, email, activebool, create_date, active, customer_2.address_id, concat(address, ' ', address2) AS fulladdress, district, postal_code, phone, city, country.country FROM customer_2
	LEFT OUTER JOIN country
	ON customer_2.country_id = country.country_id
)
SELECT * FROM customer_3;

-- Store master table
SELECT store_id, manager_staff_id, concat(address.address, ' ', address.address2) AS fulladdress, district, city.city, postal_code, phone, country_id FROM store
LEFT OUTER JOIN address
ON store.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id;

-- Staff master table
SELECT staff_id, concat(first_name, ' ', last_name) AS fullname, email, store_id, active, concat(address, ' ', address2) AS fulladdress, district, city, postal_code, phone, country_id FROM staff
LEFT OUTER JOIN address
ON staff.address_id = address.address_id
INNER JOIN city
ON address.city_id = city.city_id;

-- Most rented films
SELECT rental_id, COUNT(payment_id) AS Numberofpayments FROM payment
GROUP BY rental_id
ORDER BY Numberofpayments DESC;

-- Most rented film
SELECT rental_id FROM (
	SELECT rental_id, COUNT(payment_id) AS Numberofpayments FROM payment
	GROUP BY rental_id
	ORDER BY Numberofpayments DESC
) AS data1
LIMIT 1;

-- Most rented categories
WITH mostrented_cat AS (
	WITH cte_1 AS (
		SELECT film_id, fc.category_id, c.name FROM film_category fc
		LEFT OUTER JOIN category c
		ON fc.category_id = c.category_id
	),
	cte_2 AS (
		SELECT f.film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, cf.category_id, cf.name AS category FROM cte_1 cf
		LEFT OUTER JOIN film f
		ON cf.film_id = f.film_id
	),
	cte_3 AS (
		SELECT film_id, title, description, release_year, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, category_id, category, l.language_id, l.name AS Lang FROM cte_2 c2
		LEFT OUTER JOIN language l
		ON c2.language_id = l.language_id
	),
	cte_4 AS (
		SELECT cte_3.film_id, title, category, inventory.inventory_id, rental.rental_id FROM cte_3
		INNER JOIN inventory
		ON cte_3.film_id = inventory.film_id
		INNER JOIN rental
		ON inventory.inventory_id = rental.inventory_id
	)
	SELECT * FROM payment
	LEFT OUTER JOIN cte_4
	ON payment.rental_id = cte_4.rental_id
)
SELECT category, COUNT(payment_id) AS numberofpayments FROM mostrented_cat
GROUP BY category
ORDER BY numberofpayments DESC;

-- Top 10 most rented films
WITH mostrented_film AS (
	WITH cte_1 AS (
		SELECT film_id, fc.category_id, c.name FROM film_category fc
		LEFT OUTER JOIN category c
		ON fc.category_id = c.category_id
	),
	cte_2 AS (
		SELECT f.film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, cf.category_id, cf.name AS category FROM cte_1 cf
		LEFT OUTER JOIN film f
		ON cf.film_id = f.film_id
	),
	cte_3 AS (
		SELECT film_id, title, description, release_year, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, category_id, category, l.language_id, l.name AS Lang FROM cte_2 c2
		LEFT OUTER JOIN language l
		ON c2.language_id = l.language_id
	),
	cte_4 AS (
		SELECT cte_3.film_id, title, category, inventory.inventory_id, rental.rental_id FROM cte_3
		INNER JOIN inventory
		ON cte_3.film_id = inventory.film_id
		INNER JOIN rental
		ON inventory.inventory_id = rental.inventory_id
	)
	SELECT * FROM payment
	LEFT OUTER JOIN cte_4
	ON payment.rental_id = cte_4.rental_id
)
SELECT title, COUNT(payment_id) AS numberofpayments FROM mostrented_film
GROUP BY title
ORDER BY numberofpayments DESC
LIMIT 10;

-- 10 least rented films
WITH mostrented_film AS (
	WITH cte_1 AS (
		SELECT film_id, fc.category_id, c.name FROM film_category fc
		LEFT OUTER JOIN category c
		ON fc.category_id = c.category_id
	),
	cte_2 AS (
		SELECT f.film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, cf.category_id, cf.name AS category FROM cte_1 cf
		LEFT OUTER JOIN film f
		ON cf.film_id = f.film_id
	),
	cte_3 AS (
		SELECT film_id, title, description, release_year, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, category_id, category, l.language_id, l.name AS Lang FROM cte_2 c2
		LEFT OUTER JOIN language l
		ON c2.language_id = l.language_id
	),
	cte_4 AS (
		SELECT cte_3.film_id, title, category, inventory.inventory_id, rental.rental_id FROM cte_3
		INNER JOIN inventory
		ON cte_3.film_id = inventory.film_id
		INNER JOIN rental
		ON inventory.inventory_id = rental.inventory_id
	)
	SELECT * FROM payment
	LEFT OUTER JOIN cte_4
	ON payment.rental_id = cte_4.rental_id
	ORDER BY film_id
)
SELECT title, COUNT(payment_id) AS numberofpayments FROM mostrented_film
GROUP BY title
ORDER BY numberofpayments ASC
LIMIT 10;

-- Most rented films based on rating
WITH mostrented_rating AS (
	WITH data_tab1 AS (
		SELECT f.film_id, title, rating, i.inventory_id, r.rental_id FROM film f
		LEFT OUTER JOIN inventory i
		ON f.film_id = i.film_id
		LEFT OUTER JOIN rental r
		ON i.inventory_id = r.inventory_id
	)
	SELECT payment_id, film_id, title, rating FROM payment
	LEFT OUTER JOIN data_tab1
	ON payment.rental_id = data_tab1.rental_id
)
SELECT rating, title, COUNT(payment_id) AS Numberofpayments FROM mostrented_rating
GROUP BY rating, title
ORDER BY Numberofpayments DESC;

-- Distribution of films based on film length
SELECT film_duration, COUNT(film_id) AS Numberoffilms FROM (
	SELECT film_id, title, length,
	CASE
		WHEN length < 60 THEN 'Less than an hour'
		WHEN length BETWEEN 60 AND 120 THEN '1 to 2 hours'
		WHEN length BETWEEN 121 AND 180 THEN '2 to 3 hours'
		ELSE '3 + hours'
	END AS film_duration
	FROM film
) AS dattab
GROUP BY film_duration
ORDER BY Numberoffilms DESC;

-- Distribution of films based on language
SELECT language.name, count(film_id) AS numberoffilms FROM film
LEFT OUTER JOIN language
ON film.language_id = language.language_id
GROUP BY language.name
ORDER BY numberoffilms DESC;

-- Top 10 customers based on total, district, city, country
WITH top10cust
AS (
	WITH customer_1 AS (
		SELECT customer_id, store_id, concat(first_name, ' ', last_name) AS FullName, email, activebool, create_date, active, c.address_id, address, a.address2, a.district, a.city_id, a.postal_code, a.phone FROM customer c
		LEFT OUTER JOIN address a
		ON c.address_id = a.address_id
	),
	customer_2 AS (
		SELECT * FROM customer_1 c1
		LEFT OUTER JOIN city
		ON c1.city_id = city.city_id
	),
	customer_3 AS (
		SELECT customer_id, store_id, fullname, email, activebool, create_date, active, customer_2.address_id, concat(address, ' ', address2) AS fulladdress, district, postal_code, phone, city, country.country FROM customer_2
		LEFT OUTER JOIN country
		ON customer_2.country_id = country.country_id
	)
	SELECT c3.country, c3.city, c3.district, c3.fullname, amount FROM payment p
	LEFT OUTER JOIN customer_3 c3
	ON p.customer_id = c3.customer_id
)
SELECT country, city, fullname, SUM(amount) AS totalamount FROM top10cust
GROUP BY country, city, fullname
ORDER BY totalamount DESC
LIMIT 10;

-- Bottom 10 customers based on total, district, city, country
WITH top10cust
AS (
	WITH customer_1 AS (
		SELECT customer_id, store_id, concat(first_name, ' ', last_name) AS FullName, email, activebool, create_date, active, c.address_id, address, a.address2, a.district, a.city_id, a.postal_code, a.phone FROM customer c
		LEFT OUTER JOIN address a
		ON c.address_id = a.address_id
	),
	customer_2 AS (
		SELECT * FROM customer_1 c1
		LEFT OUTER JOIN city
		ON c1.city_id = city.city_id
	),
	customer_3 AS (
		SELECT customer_id, store_id, fullname, email, activebool, create_date, active, customer_2.address_id, concat(address, ' ', address2) AS fulladdress, district, postal_code, phone, city, country.country FROM customer_2
		LEFT OUTER JOIN country
		ON customer_2.country_id = country.country_id
	)
	SELECT c3.country, c3.city, c3.district, c3.fullname, amount FROM payment p
	LEFT OUTER JOIN customer_3 c3
	ON p.customer_id = c3.customer_id
)
SELECT country, city, fullname, SUM(amount) AS totalamount FROM top10cust
GROUP BY country, city, fullname
ORDER BY totalamount ASC
LIMIT 10;

-- Staff performance
SELECT concat(first_name, ' ', last_name) AS fullname, COUNT(payment_id) AS Numberofpayments, SUM(amount) AS TotalAmount FROM payment p
LEFT OUTER JOIN staff s
ON p.staff_id = s.staff_id
GROUP BY concat(first_name, ' ', last_name)
ORDER BY TotalAmount DESC;

-- Store performance
SELECT store_master.city, COUNT(payment_id) AS Numberofpayments, SUM(amount) AS TotalAmount FROM payment p
LEFT OUTER JOIN (
	SELECT store_id, manager_staff_id, concat(address.address, ' ', address.address2) AS fulladdress, district, city.city, postal_code, phone, country_id FROM store
	LEFT OUTER JOIN address
	ON store.address_id = address.address_id
	INNER JOIN city
	ON address.city_id = city.city_id )
AS store_master
ON p.staff_id = store_master.manager_staff_id
GROUP BY store_master.city
ORDER BY TotalAmount DESC;

-- Average number of days a film is rented, group by rating, duration, language, category
WITH cte_1
AS (
	SELECT rental_id, inventory_id, rental1.customer_id, return_date,staff_id, rental1.last_update, numberofdaysrented, concat(first_name, ' ', last_name) AS fullname
	FROM(
		SELECT *, 
		CASE
			WHEN return_date IS NULL THEN DATE(last_update) - DATE(rental_date)
			ELSE DATE(return_date) - DATE(rental_date)
		END AS NumberofDaysRented
		FROM rental
	) AS rental1
	LEFT OUTER JOIN customer c
	ON rental1.customer_id = c.customer_id
),
cte_2 AS (
	SELECT rental_id, cte_1.inventory_id, customer_id, return_date,staff_id, cte_1.last_update, numberofdaysrented, fullname, title, length, rating, category, lang FROM cte_1
	LEFT OUTER JOIN inventory
	ON cte_1.inventory_id = inventory.inventory_id
	LEFT OUTER JOIN (
		WITH fcte_1 AS (
			SELECT film_id, fc.category_id, c.name FROM film_category fc
			LEFT OUTER JOIN category c
			ON fc.category_id = c.category_id
		),
		fcte_2 AS (
			SELECT f.film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, cf.category_id, cf.name AS category FROM fcte_1 cf
			LEFT OUTER JOIN film f
			ON cf.film_id = f.film_id
		),
		fcte_3 AS (
			SELECT film_id, title, description, release_year, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, category_id, category, l.language_id, l.name AS Lang FROM fcte_2 c2
			LEFT OUTER JOIN language l
			ON c2.language_id = l.language_id
		)
		SELECT film_id, title, length, rating, category, lang FROM fcte_3
	) AS film_master
	ON inventory.film_id = film_master.film_id
)
--Change the group by field to the one needed
SELECT category, ROUND(AVG (numberofdaysrented), 2) AS averagedays
FROM (
	SELECT *,
	CASE
		WHEN length <= 90 THEN 'Less than 1.5 hours'
		WHEN length BETWEEN 91 AND 180 THEN '1.5 to 3 hours'
		ELSE '3+ hours'
	END AS duration,
	CASE
		WHEN return_date IS NULL THEN 'Not Returned'
		ELSE 'Returned'
	END AS rental_status
	FROM cte_2
) AS cte_3
GROUP BY category
ORDER BY averagedays DESC;

-- Top 10 performers with most films
SELECT fullname, COUNT(film_id) AS NumberofFilms FROM film_actor fa
LEFT OUTER JOIN (
	SELECT actor_id, concat (first_name, ' ', last_name) AS fullname
	FROM actor) AS actor1
ON fa.actor_id = actor1.actor_id
GROUP BY fullname
ORDER BY NumberofFilms DESC
LIMIT 10;

-- Special Features vs number of films
WITH cte_1 AS (
	SELECT film_id, fc.category_id, c.name FROM film_category fc
	LEFT OUTER JOIN category c
	ON fc.category_id = c.category_id
),
cte_2 AS (
	SELECT f.film_id, title, description, release_year, language_id, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, cf.category_id, cf.name AS category FROM cte_1 cf
	LEFT OUTER JOIN film f
	ON cf.film_id = f.film_id
),
cte_3 AS (
	SELECT film_id, title, description, release_year, rental_duration, rental_rate, length, replacement_cost, rating, special_features, fulltext, category_id, category, l.language_id, l.name AS Lang FROM cte_2 c2
	LEFT OUTER JOIN language l
	ON c2.language_id = l.language_id
)
SELECT special_features, COUNT(film_id) AS NumberofFilms FROM cte_3
GROUP BY special_features
ORDER BY NumberofFilms ASC;