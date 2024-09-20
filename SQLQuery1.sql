create database pizzahut

select * from pizzas
select * from pizza_types
select * from orders
select * from order_details

--Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders

--Calculate the total revenue generated from pizza sales.
select round(sum(o.quantity*p. price),2 )as total_sales  from order_details o join pizzas p on o.pizza_id=p.pizza_id 
--Identify the highest-priced pizza.
select top 1 pi.name,p.price from pizzas p join pizza_types pi on p.pizza_type_id=pi.pizza_type_id order by p.price Desc 
--Identify the most common pizza size ordered.
select top 1 p.size,count(o.order_details_id)as order_count from pizzas p join order_details o on p.pizza_id=o.pizza_id group by p.size order by order_count desc
--List the top 5 most ordered pizza types along with their quantities.
select top 5 pi.name, sum(o.quantity)as count_pizzas from pizza_types pi join pizzas p on pi.pizza_type_id=p.pizza_type_id join order_details o on o.pizza_id=p.pizza_id group by pi.name order by count_pizzas desc
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pi.category,sum(o.quantity) from pizzas p join pizza_types pi on p.pizza_type_id=pi.pizza_type_id join order_details o on o.pizza_id=p.pizza_id group by pi.category 
--Determine the distribution of orders by hour of the day.
select datepart(hour,o.time) as Hours, count(o.order_id)as orders_c from orders o group by datepart(hour,o.time) 
--Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types group by category
--Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quan),0) from 
(select o.date,sum(od.quantity)as quan from orders o join order_details od on o.order_id=od.order_id group by o.date) as order_quantity
--Determine the top 3 most ordered pizza types based on revenue.
select top 3 pt.name,sum(o.quantity*p.price) as rev from pizza_types pt join pizzas p on pt.pizza_type_id=p.pizza_type_id  join order_details o on p.pizza_id=o.pizza_id group by pt.name order by rev desc
--Calculate the percentage contribution of each pizza type to total revenue.
select pt.category,(sum(o.quantity*p.price)/(select sum(o.quantity*p. price)as total_sales  from order_details o join pizzas p on o.pizza_id=p.pizza_id ))*100 as revenue from pizza_types pt  join pizzas p on pt.pizza_type_id=p.pizza_type_id join order_details o on o.pizza_id=p.pizza_id group by pt.category order by revenue
--Analyze the cumulative revenue generated over time.
select date,sum(rev) over(order by date) as cum_revenue from
(select o.date, sum(od.quantity*p.price) as rev from order_details od join pizzas p on od.pizza_id=p.pizza_id join orders o on o.order_id=od.order_id group by o.date)as sales
--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,rev from
(select category,name,rev,rank() over(partition by category order by rev desc) as rn from
(select pt.category,pt.name, sum(od.quantity*p.price) as rev from pizza_types pt join pizzas p on p. pizza_type_id =pt.pizza_type_id join order_details od on od.pizza_id=p.pizza_id group by pt.category,pt.name)as a)as b where rn<=3