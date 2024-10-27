-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    orders_details
        JOIN pizzas USING (pizza_id);


-- Identify the highest-priced pizza.

SELECT 
    name, price
FROM
    pizza_types
        JOIN pizzas USING (pizza_type_id)
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT 
    size, COUNT(quantity) AS order_count
FROM
    pizzas 
        JOIN orders_details USING (pizza_id)
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, SUM(quantity) AS quantity
FROM
    pizza_types
        JOIN pizzas USING (pizza_type_id)
        JOIN orders_details USING (pizza_id)
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) AS quantity
FROM
    orders_details
        JOIN pizzas USING (pizza_id)
        JOIN pizza_types USING (pizza_type_id)
GROUP BY category;


-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS "avg_pizzas/day"
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders
    JOIN orders_details USING (order_id)
    GROUP BY order_date) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    name, ROUND(SUM(quantity * price), 0) AS revenue
FROM
    orders_details
        JOIN pizzas USING (pizza_id)
        JOIN pizza_types USING (pizza_type_id)
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    category,
    round(sum(quantity*price)/ (SELECT 
        ROUND(SUM(orders_details.quantity * pizzas.price),2)
        AS total_sales
    FROM
        orders_details
            JOIN pizzas USING (pizza_id))*100,2) AS revenue
FROM 
    orders_details
        JOIN pizzas USING (pizza_id)
        JOIN pizza_types USING (pizza_type_id)
GROUP BY category
ORDER BY revenue DESC


-- Analyze the cumulative revenue generated over time.

SELECT 
    order_date, 
    round(sum(revenue) OVER (ORDER BY order_date),2) 
        AS cum_revenue
FROM
    (SELECT order_date, sum(quantity*price)AS revenue
        FROM 
            orders_details
JOIN pizzas USING (pizza_id)
JOIN orders USING (order_id)
GROUP BY order_date) AS sales
