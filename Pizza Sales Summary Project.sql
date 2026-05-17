create database pizza;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders
    
-- Calculate the total revenue generated from pizza sales.

 SELECT 
     ROUND(SUM(order_details.quantity * pizzas.price),
             2) AS total_revenue
 FROM
     order_details
         JOIN
     pizzas ON pizzas.pizza_id = order_details.pizza_id
     
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

 SELECT 
     pizzas.size,
     COUNT(order_details.order_details_id) AS order_count
 FROM
     pizzas
         JOIN
     order_details ON pizzas.pizza_id = order_details.pizza_id
 GROUP BY pizzas.size
 ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.

 SELECT 
     pizza_types.name, SUM(order_details.quantity) AS Sum
 FROM
     pizza_types
         JOIN
     pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
         JOIN
     order_details ON order_details.pizza_id = pizzas.pizza_id
 GROUP BY pizza_types.name
 ORDER BY Sum DESC;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category AS Categories,
    SUM(order_details.quantity) AS TotalOrders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY TotalOrders DESC


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour_of_the_day, COUNT(order_id)
FROM
    orders
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day ASC


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category


-- Group the orders by date and calculate the average number of pizzas ordered per day.

with Query1 as(SELECT 
    order_date, SUM(quantity) as Quantity
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY order_date
ORDER BY order_date ASC) 

select round(avg(Quantity)) from Query1


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue,
    SUM(pizzas.price * order_details.quantity) / (
        SELECT SUM(pizzas.price * order_details.quantity)
        FROM order_details
        JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    ) * 100 AS percentage_contribution
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, category, revenue
from (select category, name, revenue, rank() over (partition by category order by revenue desc) as rn
from (select pizza_types.name, pizza_types.category, sum(pizzas.price*order_details.quantity) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id

group by name, category) as a) as b 
where rn<=3


-- Analyze the cumulative revenue generated over time.

select order_date, 
sum(revenue_per_day) over (order by order_date) as Cumulative
from (select orders.order_date, round(sum(pizzas.price * order_details.quantity)) as revenue_per_day
from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id
join orders on orders.order_id = order_details.order_id

group by order_date
order by order_date) as a 





