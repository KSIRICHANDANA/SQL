use sakila;
show tables;

-- stored procedures
drop procedure if exists sakila.getcustomerpayments;
delimiter //

create procedure sakila.getcustomerpayments(in cid int)
begin
    select payment_id, amount, payment_date
    from sakila.payment
    where customer_id = cid;
end;
//

delimiter ;

call sakila.getcustomerpayments(5);

drop procedure if exists sakila.totalpaid;
delimiter //

create procedure sakila.totalpaid(in cid int, out total decimal(10,2))
begin
    select sum(amount) into total
    from sakila.payment
    where customer_id = cid;
end;
//

delimiter ;

call sakila.totalpaid(6, @total);
select @total;

drop procedure if exists sakila.dynamicquery;
delimiter //

create procedure sakila.dynamicquery(in tbl_name varchar(64))
begin
    set @s = concat('select count(*) as total_rows from ', tbl_name);
    prepare stmt from @s;
    execute stmt;
    deallocate prepare stmt;
end;
//

delimiter ;

call sakila.dynamicquery('sakila.actor');

delimiter //
create procedure print_all_tables()
begin
    declare done int default 0;
    declare tbl_name varchar(64);
    -- cursor to iterate all table names in sakila
    declare tbl_cursor cursor for 
        select table_name 
        from information_schema.tables 
        where table_schema = 'sakila';
    declare continue handler for not found set done = 1;
    open tbl_cursor;
    read_loop: loop
        fetch tbl_cursor into tbl_name;
        if done then
            leave read_loop;
        end if;
        -- prepare dynamic sql
        set @s = concat('select * from sakila.', tbl_name, ';');
        -- execute dynamic sql
        prepare stmt from @s;
        execute stmt;
        deallocate prepare stmt;
    end loop;
    close tbl_cursor;
end;
//
delimiter ;


-- Indexing
-- customer table
-- search by last_name (no index yet)
explain select * from customer where last_name = 'SMITH';
-- primary key customer_id is clustered
explain select * from customer where customer_id = 15;
-- create non-clustered index on last_name
create index idx_customer_lastname on customer(last_name);
-- query again
explain select * from customer where last_name = 'SMITH';

-- rental table
-- find rentals for a specific customer
explain select * from rental where customer_id = 5;
-- rental_id is PK → clustered
explain select * from rental where rental_id = 50;
-- rental_id is PK → clustered
explain select * from rental where rental_id = 50;

-- payment table
-- total payments of a customer
explain select * from payment where customer_id = 3;
-- payment_id is PK → clustered
explain select * from payment where payment_id = 100;
-- create index on customer_id
create index idx_payment_customer on payment(customer_id);
-- query again
explain select * from payment where customer_id = 3;

-- inventory table
-- search for a specific film_id
explain select * from inventory where film_id = 50;
-- inventory_id PK → clustered
explain select * from inventory where inventory_id = 200;
-- index on film_id
create index idx_inventory_film on inventory(film_id);
-- query again
explain select * from inventory where film_id = 50;