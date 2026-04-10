use sakila;
show tables;

-- using sub-query
-- 1. display all customer details who have made more than 5 payments.
select * from customer;
select * from payment;
-- using in
select * from customer where customer_id in (select customer_id from payment group by customer_id having count(payment_id)>5);
-- using exists
select * from customer c where exists (select 1 from payment p where p.customer_id = c.customer_id);

-- 2. Find the names of actors who have acted in more than 10 films.
select * from actor;
select * from film;
select * from film_actor;
-- using in
select first_name, last_name from actor where actor_id in (select actor_id from film_actor group by actor_id having count(film_id)>10);
-- using exists
select first_name, last_name from actor a where exists (select 1 from film_actor fa where fa.actor_id = a.actor_id group by actor_id having count(film_id)>10);

-- 3. Find the names of customers who never made a payment.
select * from customer;
select * from payment;
-- using not in (sometimes will be a problem if the subquery return null values)
select first_name, last_name from customer where customer_id not in (select customer_id from payment);
-- using not exists works fine with null values
select first_name, last_name from customer c where not exists (select 1 from payment p where p.customer_id = c.customer_id);

-- 4. List all films whose rental rate is higher than the average rental rate of all films.
select * from film;
select title, rental_rate from film where rental_rate > (select avg(rental_rate) from film);

-- 5. List the titles of films that were never rented.
select * from rental;
-- using not in (sometimes will be a problem if the subquery return null values)
select f.title from film f where f.film_id not in (select i.film_id from inventory i join rental r on i.inventory_id = r.inventory_id where i.film_id is not null);
-- using not exists works fine with null values
select f.title from film f where not exists (select 1 from inventory i join rental r on i.inventory_id = r.inventory_id where i.film_id = f.film_id);

-- CTEs
-- 6. Display the customers who rented films in the same month as customer with ID 5.
with customer5_month as (select distinct month(rental_date) as month_value from rental where customer_id = 5)
select distinct c.first_name, c.last_name from customer c join rental r on c.customer_id = r.customer_id where month(r.rental_date) in (select month_value from customer5_month);

-- 7. Find all staff members who handled a payment greater than the average payment amount.
select * from payment;
select * from staff;
with avg_payment as (select distinct staff_id from payment where amount > (select avg(amount) from payment))
select * from staff where staff_id in (select staff_id from avg_payment);

-- 8. Show the title and rental duration of films whose rental duration is greater than the average.
select * from film;
with avg_value as (select avg(rental_duration) as avg_duration from film)
select title, rental_duration from film where rental_duration > (select avg_duration from avg_value);

-- temp table
-- 9. Find all customers who have the same address as customer with ID 1.
create temporary table cust1_address as select address_id from customer where customer_id = 1;
select c.first_name, c.last_name from customer c join cust1_address a on c.address_id = a.address_id;

-- view
-- 10. List all payments that are greater than the average of all payments.
-- create view
create view high_payment as select * from payment where amount > (select avg(amount) from payment);
-- use view like a table
select * from high_payment;
