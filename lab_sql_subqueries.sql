use sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(distinct inventory_id) as count_copies
from inventory i
join film f
on i.film_id = f.film_id
where title = "Hunchback Impossible";

-- 2. List all films whose length is longer than the average of all the films.
select title, length 
from film
where length > (select avg(length) from film)
order by length desc;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor
where actor_id in (
    select actor_id from film_actor
    where film_id in (
        select film_id from film
        where title like 'Alone Trip'));
        
-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select title from film
where film_id in (
    select film_id from film_category
	where category_id in (
            select category_id from category
            where name REGEXP 'Family'));
            
-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. 
-- Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
-- that will help you get the relevant information.
select first_name, last_name, email from customer
where address_id in (
    select address_id from address
    where city_id in (
        select city_id from city
        where country_id = (
			select country_id from country
            where country = 'Canada')));
            
select cu.first_name, cu.last_name, cu.email
from customer cu 
join address ad on cu.address_id = ad.address_id
join city ci on ad.city_id = ci.city_id
join country co on ci.country_id = co.country_id
where co.country  = 'Canada';
        
-- 6. Which are films starred by the most prolific actor? 
-- Most prolific actor is defined as the actor that has acted in the most number of films. 
-- First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

select film_id, title from film 
where film_id in(
    select film_id from film_actor
    where actor_id = (
        select actor_id from(
            select actor_id, count(film_id) from film_actor
		    group by actor_id
		    order by count(film_id) DESC
            LIMIT 1) as popular_actor_table ));
            
-- 7. Films rented by most profitable customer.
-- You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

select film_id, title from film
where film_id in (
    select film_id from inventory
    where inventory_id in (
        select inventory_id from rental
        where customer_id in (
            select customer_id from (
                select customer_id, sum(amount) from payment
                group by customer_id
                order by sum(amount) DESC
                Limit 1) as profitable_customer_table)));
    
-- 8. Customers who spent more than the average payments.
select cu.customer_id, cu.first_name, cu.last_name, sum(amount) as spend from payment pa
join customer cu
on pa.customer_id = cu.customer_id
group by cu.customer_id
having spend > (
    select AVG(amount) as avg_payment from payment)
order by spend DESC;