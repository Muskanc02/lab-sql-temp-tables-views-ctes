
# **Creating a Customer Summary Report**

#In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, 
#including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View

-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, 
-- email address, and total number of rentals (rental_count).
create view rental_info as
select customer_id , first_name ,email ,
(select count(distinct rental_id) 
from rental r
where r.customer_id=c.customer_id ) as rental_count
from customer c;

select * from rental_info;
-- Step 2: Create a Temporary Table

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.

create temporary table amount_info_new
select  ri.customer_id , ri.first_name , ri.email , ri.rental_count,
sum(p.amount) as total_paid
from payment p
join 
rental_info ri
on ri.customer_id=p.customer_id 
group by p.customer_id ;

select * from amount_info_new;
-- Step 3: Create a CTE and the Customer Summary Report

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table 
-- created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 
with  Cust_Summary as
(
select i.customer_id , i.first_name , i.email , r.rental_count, i.total_paid
from amount_info_new i
join
rental_info r
on i.customer_id =r.customer_id
)
select * from Cust_Summary;
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid 
-- and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
with  Cust_Summary as
(
select i.customer_id , i.first_name , i.email , r.rental_count, i.total_paid
from amount_info_new i
join
rental_info r
on i.customer_id =r.customer_id
)
select customer_id , first_name , email , rental_count, total_paid ,
ROUND((total_paid/rental_count),2) as average_payment_per_rental
from Cust_Summary;