show databases;
use sakila;
show tables;

-- 1. Get all customers whose first name starts with 'J' and who are active.
select * from customer;
select first_name, last_name, active from customer where first_name like 'J%' and active = 1;

-- 2. Find all films where the title contains the word 'ACTION' or the description contains 'WAR'.
select * from film;
select title, description from film where title like '%ACTION%' or description like '%WAR%';

-- 3. List all customers whose last name is not 'SMITH' and whose first name ends with 'a'.
select * from customer;
select first_name, last_name from customer where last_name != 'SMITH' and first_name like '%a';

-- 4. Get all films where the rental rate is greater than 3.0 and the replacement cost is not null.
select * from film;
select title, rental_rate, replacement_cost from film where rental_rate > 3.0 and replacement_cost is not null;

-- 5. Count how many customers exist in each store who have active status = 1.
select * from customer;
select store_id, count(*) as customer_active_count from customer where active = 1 group by store_id;

-- 6. Show distinct film ratings available in the film table.
select * from film;
select distinct rating from film;

-- 7. Find the number of films for each rental duration where the average length is more than 100 minutes.
select * from rental;
select * from film;
select count(*) as film_count, rental_duration, avg(length) as avg_length from film group by rental_duration having avg(length) > 100;

-- 8. List payment dates and total amount paid per date, but only include days where more than 100 payments were made.
select date(payment_date) as pay_date, count(*) as total_payments, sum(amount) as total_amount from payment
group by date(payment_date) having count(*) > 100;

-- 9. Find customers whose email address is null or ends with '.org'.
select * from customer;
select first_name, last_name, email from customer where email is null or email like '%.org';

-- 10. List all films with rating 'PG' or 'G', and order them by rental rate in descending order.
select * from film;
select title, rating, rental_rate from film where rating in ('PG', 'G') order by rental_rate desc;

-- 11. Count how many films exist for each length where the film title starts with 'T' and the count is more than 5.
select * from film;
select length, count(*) as film_count from film where title like 'T%' group by length having count(*) > 5 order by length;

-- 12. List all actors who have appeared in more than 10 films.
select * from film_actor;
select * from actor;
select a.actor_id, a.first_name, a.last_name, count(fa.film_id) as film_count from actor a 
join film_actor fa on a.actor_id = fa.actor_id group by actor_id, a.first_name, a.last_name 
having film_count > 10 order by film_count;

-- 13. Find the top 5 films with the highest rental rates and longest lengths combined, ordering by rental rate first and length second.
select * from film;
select title, rental_rate, length from film order by rental_rate desc, length desc limit 5;

-- 14. Show all customers along with the total number of rentals they have made, ordered from most to least rentals.
select * from customer;
select * from rental;
select c.customer_id, c.first_name, c.last_name, count(rental_id) as total_rentals from customer c left join rental r on c.customer_id = r.customer_id
group by c.customer_id, c.first_name, c.last_name order by count(rental_id) desc;

-- 15. List the film titles that have never been rented.
select * from film;
select * from inventory;
select f.title from film f 
left join inventory i on f.film_id = i.film_id 
left join rental r on i.inventory_id = r.inventory_id where r.rental_id is null;