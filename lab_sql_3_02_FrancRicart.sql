/*
Lab | SQL Subqueries 3.03
In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.

Instructions
1. How many copies of the film Hunchback Impossible exist in the inventory system?
2. List all films whose length is longer than the average of all the films.
3. Use subqueries to display all actors who appear in the film Alone Trip.
4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.
5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
that will help you get the relevant information.
6. Which are films starred by the most prolific actor? 
Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
7. Films rented by most profitable customer. You can use the customer table and payment table 
to find the most profitable customer ie the customer that has made the largest sum of payments
8. Customers who spent more than the average payments.
*/

USE SAKILA;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(inventory_id) AS "Copies"
FROM inventory
WHERE film_id IN (
	SELECT film_id
	FROM (
		SELECT film_id, title FROM film
		WHERE title = "Hunchback Impossible"
	) AS sub
);

-- 2. List all films whose length is longer than the average of all the films.


SELECT title, length FROM film
WHERE length > (
	SELECT RONUND(AVG(length),2) AS AVG_Length FROM film
)
ORDER BY length DESC;


--  Why this doesn't work?? 
-- SELECT film_id, title, ROUND(AVG(length),2) as "average" 
-- FROM film
-- WHERE length > average
-- GROUP BY film_id; 

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

select * from film
where title = "Alone Trip"; -- here we know that the film_id of "Alone Trip" is 17

SELECT actor_id
FROM film_actor
WHERE film_id = 17; -- here we get the names of the actors

SELECT actor_id, first_name, last_name FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
    WHERE film_id IN (
		SELECT film_id FROM film
        WHERE title = "Alone Trip"
	)
);

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

-- category (category_id, name)
-- film_category (category_id, film_id)
-- film (film_id, title)

SELECT film_id, title FROM film
WHERE film_id IN
	(SELECT film_id FROM film_category
    WHERE category_id = 8
);


SELECT film_id, title FROM film
WHERE film_id IN
	(SELECT film_id FROM film_category
    WHERE category_id in
		(SELECT category_id FROM category
        WHERE name = "Family"
        )
);
    

-- Also possible to make it with joins
SELECT f.film_id, f.title, fc. category_id, c.name
FROM film AS f
JOIN film_category AS fc
ON f.film_id = fc.film_id
JOIN category as c
ON fc.category_id = c.category_id
WHERE c.name = "family";


-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.

-- customer (first_name, last_name, email, customer_id, address_id)
-- address (address_id, city_id)
-- city (city_id, country_id
-- country (country, country_id)

SELECT customer_id, first_name, last_name, email from customer
WHERE address_id IN (
	SELECT address_id FROM address 
	WHERE city_id IN (
		SELECT city_id FROM city
		WHERE country_id IN (
			SELECT country_id FROM country
			WHERE country = "Canada"
		)
	)
);


-- 6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films.


-- actor (actor_id, first_name, last_name)
-- film (film_id, title)
-- film_actor (actor_id, film_id)

-- MOST PROLIFIC ACTOR: actor who appears in most films (or) Max(Count) in how many films appears each actor, then sort MAX


	
SELECT film_id, title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_actor
	WHERE actor_id IN (
		SELECT actor_id
		FROM (
			SELECT actor_id, films, ROW_NUMBER() OVER() AS "Ranking"
			FROM (
				SELECT actor_id, COUNT(film_id) AS films FROM film_actor 
				GROUP BY actor_id
				ORDER BY Films DESC
			) AS subq1
		) AS subq2
		WHERE ranking = 1
	)
);

--  7. Films rented by most profitable customer. You can use the customer table and payment table 

-- film (film_id, title)

-- inventory (inventory_id, film_id)
-- rental (inventory_id, customer_id)
-- payment (customer_id, amount)

SELECT film_id, title FROM film
WHERE film_id IN (
	SELECT film_id FROM inventory
	WHERE inventory_id IN (
		SELECT inventory_id FROM rental
		WHERE customer_id IN (
			SELECT customer_id
			FROM (
				SELECT customer_id, ROW_NUMBER() OVER() AS "Ranking"
				FROM (
					SELECT customer_id, SUM(amount) AS total FROM payment
					GROUP BY customer_id
					ORDER BY total DESC
				) AS subq1
			) AS subq2
			WHERE Ranking = 1
		)
	)
);

-- 8. Customers who spent more than the average payments.

-- customer (customer_id, first_name, last_name)
-- payment (amount, customer_id)


SELECT customer_id, first_name, last_name FROM customer
WHERE customer_id IN (
	SELECT customer_id, SUM(amount) AS payments FROM payment
	GROUP BY customer_id
	HAVING Payments > (
		SELECT ROUND(AVG(payments),2)
		FROM (
			SELECT SUM(amount) AS payments FROM payment
			GROUP BY customer_id
		) AS subq1
	)
	ORDER BY payments DESC
);

-- I DO NOT UNDERSTAND THIS ERROR
