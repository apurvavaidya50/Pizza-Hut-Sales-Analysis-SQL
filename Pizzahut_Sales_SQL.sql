create database pizzahut;

CREATE TABLE Orders (
    order_id INT NOT NULL PRIMARY KEY,
    date DATE,
    time TIME
);

CREATE TABLE Orders_details (
    order_details_id INT NOT NULL PRIMARY KEY,
    order_id int not null,
    pizza_id text not null,
    quantity int not null
    )
    
# Retrieve the total number of orders placed.

Select count(order_id) as Total_no_of_orders from orders ;
    
# Calculate the total revenue generated from pizza sales.

    Select Round(sum(orders_details.quantity * pizzas.price),2) as total_revenue 
    from orders_details Inner join pizzas 
    on orders_details.pizza_id = pizzas.pizza_id;
    
# Identify the highest-priced pizza.

Select price, name 
from pizza_types inner join pizzas on 
pizza_types.pizza_type_id = pizzas.pizza_type_id
Order by price desc limit 1;

# Identify the most common pizza size ordered.
Select size, count(order_details_id) as Total_Orders
from orders_details
join pizzas on orders_details.pizza_id = pizzas.pizza_id
Group by size
Order by Total_Orders Desc;

# List the top 5 most ordered pizza types along with their quantities.

Select Sum(quantity) as Total_Quantity_Ordered,name
from pizzas inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join orders_details 
on orders_details.pizza_id = pizzas.pizza_id
group by name
Order by Total_Quantity_Ordered desc limit 5;

# Join the necessary tables to find the total quantity of each pizza category ordered

Select sum(quantity) as Total_Orders, category from
pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id 
join orders_details on orders_details.pizza_id = pizzas.pizza_id
group by category
order by Total_Orders desc;

# Determine the distribution of orders by hour of the day.

Select hour(time) as Hour, count(order_id) as Total_Orders 
from orders
Group by hour
Order by Total_Orders Desc ;

# Join relevant tables to find the category-wise distribution of pizzas.

Select category, count(name) as Total_Pizzas from pizza_types
Group by category;

# Group the orders by date and calculate the average number of pizzas ordered per day.

Select Round(Avg(Pizza_Quantity),0) as Avg_Pizza_Orders from

(Select sum(quantity) as Pizza_Quantity,date 
from orders inner join orders_details 
on orders.order_id = orders_details.order_id
group by date) as Quantity;

# Determine the top 3 most ordered pizza types based on revenue.
Select name, sum(quantity*price) as Revenue 
from pizzas join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
Join orders_details 
on pizzas.pizza_id = orders_details.pizza_id
Group by name
Order by Revenue Desc limit 3;

# Calculate the percentage contribution of each pizza type to total revenue.

Select Category,round(sum(orders_details.quantity * pizzas.price) / (Select 
Round(sum(orders_details.quantity * pizzas.price),2) as total_sales
    from orders_details Inner join pizzas 
    on orders_details.pizza_id = pizzas.pizza_id) *100,2) as Revenue_Percent

from pizzas join pizza_types 
on pizzas.pizza_type_id = pizza_types.pizza_type_id 
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
Group by category
order by Revenue_Percent Desc ;

# Analyse the cumulative revenue generated over time.
    
    Select date, sum(Revenue) over (order by date) as Cumulative_Revenue
    from
	(Select date, sum(quantity*price) as Revenue
    from orders join orders_details 
    on orders.order_id = orders_details.order_id 
    join pizzas 
    on pizzas.pizza_id = orders_details.pizza_id
    Group by date) as Sales_Per_Day;
    
    # Determine the top 3 most ordered pizza types based on revenue for each pizza category.
   
  Select name, category,Revenue,Rn from
  (select name, category,Revenue, 
   rank() over (partition by category order by Revenue desc) as Rn
   from
   (Select name,category, sum(quantity*price) as Revenue 
    from pizzas join pizza_types 
	on pizzas.pizza_type_id = pizza_types.pizza_type_id 
	join orders_details
	on orders_details.pizza_id = pizzas.pizza_id
	Group by name,category) as a) as b
    where Rn<=3;
    
    