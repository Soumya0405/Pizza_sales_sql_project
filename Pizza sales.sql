
-- Q1 Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders_placed
FROM
    orders;
    
--  Q2  Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(Q.quantity * p.price), 0) AS revenue
FROM
    order_details Q
        JOIN
    pizzas p ON Q.pizza_id = p.pizza_id;

-- Q3 Identify the highest-priced pizza.

SELECT 
    pt.name, p.price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Q4 Identify the most common pizza size ordered.

SELECT 
    p.size,
    COUNT(order_details_id) AS ordered,
    SUM(Q.quantity) AS quantity_ordered
FROM
    pizzas p
        JOIN
    order_details Q ON p.pizza_id = Q.pizza_id
GROUP BY p.size
ORDER BY quantity_ordered DESC;

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name,
    COUNT(order_details_id) AS ordered,
    SUM(Q.quantity) AS quantity_ordered
FROM
    pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details Q ON p.pizza_id = Q.pizza_id
GROUP BY pt.name
ORDER BY quantity_ordered DESC
limit 5;


-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category,
    SUM(Q.quantity) AS quantity_ordered
FROM
pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details Q ON p.pizza_id = Q.pizza_id
    
GROUP BY pt.category
ORDER BY quantity_ordered DESC;

-- Q7 Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) from orders group by hour ;


-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

select pt.category , count(order_id) from
pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details Q ON p.pizza_id = Q.pizza_id
    group by pt.category ;
    
-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        o.order_date AS od, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS s;
    
-- Q10 Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(qd.quantity * p.price) as rev
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details qd ON qd.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY rev DESC
LIMIT 3;

-- q11 Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category, concat(round(((SUM(qd.quantity * p.price)) / (SELECT 
    ROUND(SUM(Q.quantity * p.price), 0) AS revenue
FROM
    order_details Q
        JOIN
    pizzas p ON Q.pizza_id = p.pizza_id) * 100 ),2),'%') as 'rev_%'
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details qd ON qd.pizza_id = p.pizza_id
GROUP BY pt.category ;


-- Q12 Analyze the cumulative revenue generated over time.

select date, sum(rev) over (order by date)
from (select sum(Q.quantity * p.price) as rev , o.order_date as date from orders o
    JOIN order_details Q ON o.order_id = Q.order_id join  pizzas p ON Q.pizza_id = p.pizza_id
    group by date) as s;


-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name,rev ,rn from (select category,name, rev ,
rank() over (partition by category order by rev desc) as rn from
	(select 
sum(Q.quantity * p.price) as rev , pt.name ,pt.category
from 
pizza_types pt 
join pizzas p on p.pizza_type_id = pt.pizza_type_id join order_details q on p.pizza_id = q.pizza_id
group by pt.category , pt.name)as s
) as p
where rn <= 3;



















