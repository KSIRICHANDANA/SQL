use sakila;
show tables;

drop table if exists sakila.employee_natural;

create table sakila.employee_natural (ssn char(11) primary key, name varchar(100), department varchar(50));

insert into sakila.employee_natural (ssn, name, department) values
('123-45-6789', 'Alice', 'Finance'),
('123-56-7890', 'Alice', 'IT'),
('345-67-8901', 'Carol', 'HR');

select * from sakila.employee_natural;

insert into sakila.employee_natural (ssn, name, department) values ('123-45-6789', 'Eve', 'Marketing');

drop table if exists sakila.employee_surrogate;

create table sakila.employee_surrogate (emp_id INT AUTO_INCREMENT PRIMARY KEY, ssn char(11), name varchar(100), department varchar(50));

insert into sakila.employee_surrogate (ssn, name, department) values
('123-45-6789', 'Alice', 'Finance'),
('123-56-7890', 'Alice', 'IT'),
('345-67-8901', 'Carol', 'HR');

select * from sakila.employee_surrogate;

insert into sakila.employee_surrogate (ssn, name, department) values ('123-45-6789', 'Eve', 'Marketing');


-- Film table
use sakila;

-- NATURAL KEY (title)
drop table if exists sakila.film_natural;

create table sakila.film_natural (
    title varchar(100) primary key,
    rental_rate decimal(4,2),
    length int
);

insert into sakila.film_natural (title, rental_rate, length) values
('ACADEMY DINOSAUR', 2.99, 86),
('ACE GOLDFINGER', 3.99, 90),
('ADAPTATION HOLES', 2.99, 50);

select * from sakila.film_natural;

-- duplicate title (will FAIL)
insert into sakila.film_natural values
('ACADEMY DINOSAUR', 4.99, 100);


-- SURROGATE KEY
drop table if exists sakila.film_surrogate;

create table sakila.film_surrogate (
    film_id int auto_increment primary key,
    title varchar(100),
    rental_rate decimal(4,2),
    length int
);

insert into sakila.film_surrogate (title, rental_rate, length) values
('ACADEMY DINOSAUR', 2.99, 86),
('ACE GOLDFINGER', 3.99, 90),
('ADAPTATION HOLES', 2.99, 50);

select * from sakila.film_surrogate;

-- duplicate title (ALLOWED)
insert into sakila.film_surrogate (title, rental_rate, length) values
('ACADEMY DINOSAUR', 4.99, 100);


-- Orders table
-- NATURAL KEY (order_code)
drop table if exists sakila.orders_natural;

create table sakila.orders_natural (
    order_code varchar(20) primary key,
    customer_name varchar(50),
    status varchar(10)
);

insert into sakila.orders_natural values
('ORD001', 'Alice', 'A'),
('ORD002', 'Bob', 'B');

select * from sakila.orders_natural;

-- duplicate order_code (FAIL)
insert into sakila.orders_natural values
('ORD001', 'Eve', 'C');


-- SURROGATE KEY
drop table if exists sakila.orders_surrogate;

create table sakila.orders_surrogate (
    order_id int auto_increment primary key,
    order_code varchar(20),
    customer_name varchar(50),
    status varchar(10)
);

insert into sakila.orders_surrogate (order_code, customer_name, status) values
('ORD001', 'Alice', 'A'),
('ORD002', 'Bob', 'B');

select * from sakila.orders_surrogate;

-- duplicate order_code (ALLOWED)
insert into sakila.orders_surrogate (order_code, customer_name, status) values
('ORD001', 'Eve', 'C');


-- Query fine-tuning/optimization examples
use sakila;

-- 1 use only necessary columns do not use select all
-- inefficient
select * from customer;
-- optimized
select customer_id, first_name, last_name from customer;

-- 2 use where before group by and having
-- inefficient filters after grouping
select customer_id, count(*) as rental_count
from rental
group by customer_id
having customer_id = 5;
-- optimized filters before grouping
select customer_id, count(*) as rental_count
from rental
where customer_id = 5
group by customer_id;

-- 3 use joins instead of subquery
-- subquery version
select first_name, last_name
from customer
where customer_id in (
    select customer_id from rental where rental_date > '2005-05-01'
);
-- join version
select distinct c.first_name, c.last_name
from customer c
join rental r on c.customer_id = r.customer_id
where r.rental_date > '2005-05-01';

-- 4 avoid functions on indexed columns
-- inefficient function on column
select * from rental where year(rental_date) = 2005;
-- optimized range condition
select * from rental
where rental_date between '2005-01-01' and '2005-12-31';

-- 5 use limit effectively
-- inefficient returns all rows
select * from payment;
-- optimized limit rows
select * from payment limit 10;

-- 6 use cte for readability
-- without cte
select c.customer_id, c.first_name, sum(p.amount) as total_spent
from customer c
join payment p on c.customer_id = p.customer_id
group by c.customer_id, c.first_name
having sum(p.amount) > 100;
-- with cte
with customer_totals as (
    select customer_id, sum(amount) as total_spent
    from payment
    group by customer_id
)
select c.customer_id, c.first_name, ct.total_spent
from customer c
join customer_totals ct on c.customer_id = ct.customer_id
where ct.total_spent > 100;

-- 7 use explain to understand query
explain select * from customer where customer_id = 5;
explain select * from rental where rental_date between '2005-01-01' and '2005-12-31';

-- 8 maintenance commands
analyze table sakila.customer;
optimize table sakila.rental;

-- 9 avoid large offsets in pagination
-- inefficient large offset
select * from sakila.payment limit 1000, 10;
-- optimized using index condition
select * from sakila.payment
where payment_id > 1000
limit 10;