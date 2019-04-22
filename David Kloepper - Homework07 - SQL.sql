# David Kloepper
# Data Visualization Bootcamp, Cohort 3
# April 22, 2019

-- Denotes original instructions
# Denotes comment from David Kloepper


USE sakila;


-- 1a. Display the first and last names of all actors from the table actor.

SELECT 
    first_name, last_name
FROM
    actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 

SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM
    actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information? 

# David Kloepper: Added BINARY keyword to enforce a case-sensitive search
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE BINARY
    first_name = 'JOE';


-- 2b. Find all actors whose last name contain the letters GEN 

SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China

SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB
AFTER last_name;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;


-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT 
    last_name, COUNT(last_name) AS actor_count
FROM
    actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT 
    last_name, COUNT(last_name) AS actor_count
FROM
    actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';
   
   
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 

# David Kloepper: This query will not update using only first_name unless MySQL safe update mode is disabled (commented out). 
#	It will work under safe mode if both the first and last name are used (ensures single row update), so that version is included here
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
#    first_name = 'HARPO';
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? -- 

SHOW CREATE TABLE address;
# David Kloepper: CREATE TABLE query is commented out to prevent error when running entire SQL script, due to table already existing
#CREATE TABLE `address` (
#   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
#   `address` varchar(50) NOT NULL,
#   `address2` varchar(50) DEFAULT NULL,
#   `district` varchar(20) NOT NULL,
#   `city_id` smallint(5) unsigned NOT NULL,
#   `postal_code` varchar(10) DEFAULT NULL,
#   `phone` varchar(20) NOT NULL,
#   `location` geometry NOT NULL,
#   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#   PRIMARY KEY (`address_id`),
#   KEY `idx_fk_city_id` (`city_id`),
#   SPATIAL KEY `idx_location` (`location`),
#   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
# ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
 
 SELECT s.first_name, s.last_name, a.address FROM
    staff AS s
        INNER JOIN
    address AS a ON s.address_id = a.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT 
    CONCAT(s.first_name, ' ', s.last_name) AS staff_name,
    SUM(p.amount) AS total_amount
FROM
    staff AS s
        INNER JOIN
    payment AS p ON s.staff_id = p.staff_id
WHERE
    YEAR(p.payment_date) = 2005
        AND MONTH(p.payment_date) = 8
GROUP BY s.last_name , s.first_name;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT 
    f.title, COUNT(fa.actor_id) AS actor_count
FROM
    film AS f
        INNER JOIN
    film_actor AS fa ON f.film_id = fa.film_id
GROUP BY f.title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT 
    f.title, COUNT(i.inventory_id) AS copy_count
FROM
    film AS f
        INNER JOIN
    inventory AS i ON f.film_id = i.film_id
GROUP BY f.title
HAVING f.title = 'Hunchback Impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    SUM(p.amount) AS total_payments
FROM
    customer AS c
        LEFT JOIN
    payment AS p ON c.customer_id = p.customer_id
GROUP BY c.first_name , c.last_name
ORDER BY c.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT 
    f.title
FROM
    film AS f
WHERE
    (f.title LIKE 'K%' OR f.title LIKE 'Q%')
        AND f.language_id = (SELECT 
            l.language_id
        FROM
            language AS l
        WHERE
            l.name = 'English');


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name
FROM
    actor AS a
WHERE
    a.actor_id IN (SELECT 
            fa.actor_id
        FROM
            film_actor AS fa
                INNER JOIN
            film AS f ON fa.film_id = f.film_id
        WHERE
            f.title = 'Alone Trip');


-- 7c. You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS email_address
FROM
    customer AS c
        INNER JOIN
    address AS a ON c.address_id = a.address_id
        INNER JOIN
    city AS ci ON a.city_id = ci.city_id
        INNER JOIN
    country AS co ON ci.country_id = co.country_id
WHERE
    co.country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT 
    f.title
FROM
    film AS f
        INNER JOIN
    film_category AS fc ON f.film_id = fc.film_id
        INNER JOIN
    category AS c ON fc.category_id = c.category_id
WHERE
    c.name = 'Family';


-- 7e. Display the most frequently rented movies in descending order.

SELECT 
    f.title AS film_title,
    COUNT(r.rental_id) AS number_of_rentals
FROM
    rental AS r
        INNER JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
        INNER JOIN
    film AS f ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in. -- 

#David Kloepper: This is probably the correct query, however there are 5 records in the payment table that have no rental id, 
#	so this query returns $5.95 less than summed total in the payment table  
SELECT 
    s.store_id, SUM(p.amount) AS total_business
FROM
    payment AS p
        LEFT JOIN
	rental AS r ON p.rental_id = r.rental_id
		INNER JOIN
	inventory AS i ON i.inventory_id = r.inventory_id
        INNER JOIN
    store AS s ON i.store_id = s.store_id
GROUP BY s.store_id;

#David Kloepper: This query returns the full total of payments, supported by the current data model that allows only one store id per staff, 
#	and all payments having a staff id
SELECT 
    s.store_id, SUM(p.amount) AS total_business
FROM
    payment AS p
        LEFT JOIN
	staff AS st ON p.staff_id = st.staff_id
        INNER JOIN
    store AS s ON st.store_id = s.store_id
GROUP BY s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT 
    s.store_id, ci.city, co.country
FROM
    store AS s
        INNER JOIN
    address AS a ON s.address_id = a.address_id
        INNER JOIN
    city AS ci ON a.city_id = ci.city_id
        INNER JOIN
    country AS co ON ci.country_id = co.country_id;


-- 7h. List the top five genres in gross revenue in descending order. --
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT 
    c.name AS category_name, SUM(p.amount) AS gross_revenue
FROM
    category AS c
        INNER JOIN
    film_category AS fc ON c.category_id = fc.category_id
        INNER JOIN
    inventory AS i ON fc.film_id = i.film_id
        INNER JOIN
    rental AS r ON i.inventory_id = r.inventory_id
        INNER JOIN
    payment AS p ON r.rental_id = p.rental_id
GROUP BY c.name
ORDER BY SUM(p.amount) DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE OR REPLACE VIEW top_categories AS
    SELECT 
        c.name AS category_name, SUM(p.amount) AS gross_revenue
    FROM
        category AS c
            INNER JOIN
        film_category AS fc ON c.category_id = fc.category_id
            INNER JOIN
        inventory AS i ON fc.film_id = i.film_id
            INNER JOIN
        rental AS r ON i.inventory_id = r.inventory_id
            INNER JOIN
        payment AS p ON r.rental_id = p.rental_id
    GROUP BY c.name
    ORDER BY SUM(p.amount) DESC
    LIMIT 5;


-- 8b. How would you display the view that you created in 8a?

SELECT 
    category_name, gross_revenue
FROM
    top_categories;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW IF EXISTS top_categories;