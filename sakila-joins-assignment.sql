show databases;
use sakila;
show tables;

-- 1. List all customers along with the films they have rented.
select * from customer;
select * from rental;
select * from inventory;
select * from film;
-- One customer might have rented multiple films and vice-versa i.e, one film might be rented by multiple customers
-- many to many relationship
-- We have 2 bridge tables (connecting two tables that have a many to many relationship) 
-- rental(primary) and inventory(secondary)
select c.first_name, c.last_name, f.title, r.rental_date from customer c 
join rental r on c.customer_id = r.customer_id 
join inventory i on r.inventory_id = i.inventory_id 
join film f on i.film_id = f.film_id;

-- 2. List all customers and show their rental count, including those who haven't rented any films.
-- left join here, why? cause if we use normal join it will exculde the customers who have 0 rentals
select c.customer_id, c.first_name, c.last_name, count(rental_id) as rental_count from customer c 
left join rental r on c.customer_id = r.customer_id 
group by customer_id, c.first_name, c.last_name 
order by rental_count asc;

-- Using sub-query
select c.customer_id, c.first_name, c.last_name, 
(select count(*) from rental r where r.customer_id = c.customer_id) as rental_count 
from customer c order by rental_count asc;

-- 3. Show all films along with their category. Include films that don't have a category assigned.
-- LEFT JOIN film_category here, why? --> Cause if we use normal (INNER) JOIN, it will exclude films that don’t have any category assigned.  
-- LEFT JOIN category here, why? --> Cause if we use normal (INNER) JOIN, it will exclude films where the category_id in film_category is missing or doesn’t match any category.  
select * from film;
select * from film_category;
select * from category;
select f.title, c.name as category from film f 
left join film_category fc on f.film_id = fc.film_id 
left join category c on fc.category_id = c.category_id;

-- 4. Show all customers and staff emails from both customer and staff tables using a full outer join (simulate using LEFT + RIGHT + UNION).
select * from customer;
select * from staff;
select c.email as customer_email, s.email as staff_email from customer c
left join staff s on c.email = s.email
union
select c.email as customer_email, s.email as staff_email from customer c
right join staff s on c.email = s.email;

-- 5. Find all actors who acted in the film "ACADEMY DINOSAUR".
select * from actor;
select * from film_actor;
select * from film;
select a.first_name, a.last_name, f.title from actor a
join film_actor fa on a.actor_id = fa.actor_id 
join film f on fa.film_id = f.film_id where f.title = 'ACADEMY DINOSAUR';

-- Using sub-query
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id = (
    SELECT f.film_id
    FROM film f
    WHERE f.title = 'ACADEMY DINOSAUR'
);

-- 6. List all stores and the total number of staff members working in each store, even if a store has no staff.
select * from store;
select * from staff;
select s.store_id, count(st.staff_id) as staff_count from store s 
left join staff st on s.store_id = st.store_id 
group by s.store_id order by s.store_id;

-- Using sub-query
select s.store_id, (select count(*) from staff st 
where st.store_id = s.store_id) as staff_count from store s order by s.store_id;

-- 7. List the customers who have rented films more than 5 times. Include their name and total rental count.
select c.first_name, c.last_name, count(r.rental_id) as rental_count from customer c 
join rental r on c.customer_id = r.customer_id 
group by c.customer_id, c.first_name, c.last_name having count(rental_id) > 5
order by rental_count asc;

-- Using sub-query
select c.first_name, c.last_name,
(select count(*) from rental r where r.customer_id = c.customer_id) as rental_count
from customer c
where (select count(*) from rental r where r.customer_id = c.customer_id) > 5
order by rental_count asc;
