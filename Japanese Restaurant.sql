-- Question 1; How much has each customers spent at the resturant?
SELECT customer_id, sum(price) AS Total_amount
FROM sales
JOIN menu
USING (product_id)
GROUP BY customer_id;

-- Customer A spent the highest of 76, Cuatomer B 74, and customer C with the least amount of 36

-- Question 2; How many days has each customer ordered from the resturant?
SELECT customer_id, COUNT(DISTINCT(orderdate)) AS no_of_days
FROM sales
GROUP BY customer_id;
-- Customer A is the highest visiting customer while customer C is the least

-- Question 3; What is the first item purchased by each customer
SELECT s.customer_id, m.product_name
FROM (
		SELECT customer_id, min(orderdate) AS first_order_date
        FROM sales sa
        GROUP BY customer_id) first_purchase
JOIN sales s ON first_purchase.customer_id = s.customer_id
			 AND first_order_date = orderdate
JOIN menu m ON m.product_id = s.product_id
ORDER BY m.product_name, s.customer_id
LIMIT 3;
-- Custumer A purchased both curry and suchi as the first item but it was limited to one each, B and C purchasing curry and ramen respectively. 
-- Customer A purchsed to different item on the first day while C purchased ramen on two occasions on the first day, with B purchasing only
-- curry on the first day.

-- Question 4 What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT product_name, SUM(no_sold) AS Total_no_sold
        FROM(
			SELECT count(product_name) as no_sold, product_name, customer_id
			FROM sales s
			JOIN menu m
			ON s.product_id = m.product_id
			GROUP BY customer_id, m.product_id, product_name) purchased_items
GROUP BY product_name
ORDER BY total_no_sold DESC;

-- The most Purchased item is ramen which was purchased 8 times

-- Question 5; Which item was the most popular for each customer?
SELECT *
	FROM (
			SELECT customer_id, count(product_name) as No_bought, product_name
			FROM sales s
			JOIN menu m
			ON s.product_id = m.product_id
			GROUP BY customer_id, product_name) Popular_item
 ORDER BY no_bought DESC, customer_id DESC
LIMIT 3;

-- Ramen is the most bought item for customer C and A. For customer B, all the items were gotten the same numner of times but has been limited to 1



-- Question 6 Which item was purchased first by the customer after they became a member?

SELECT min(orderdate) AS first_day, product_name, customer_id
FROM(
		SELECT customer_id,orderdate,product_id
		FROM sales
		JOIN members
		USING (customer_id)
		WHERE orderdate > '2021-01-09') after_join
JOIN menu m
USING (product_id)
GROUP BY customer_id, product_name
ORDER BY customer_id ASC, first_day ASC 
LIMIT 2;

-- Customer A and B are the only customers that have joined the loyalty plan. A purchased ramen as the first product after joining while B purchased suchi


-- Question 7 Which item was purchased just before the customer became a member?
SELECT max(orderdate) AS last_day, customer_id, product_name
FROM(
		SELECT customer_id,orderdate,product_id
		FROM sales
		JOIN members
		USING (customer_id)
		WHERE orderdate < '2021-01-07' OR '2021-01-09')after_join
JOIN menu m
USING (product_id)
GROUP BY customer_id,product_name
ORDER BY last_day DESC, customer_id ASC
LIMIT 2;

-- Both customers got ramen just before they joined the loyalty program


-- Question 8 What is the total items and amount spent for each member before they became a member?
SELECT customer_id, sum(price) as Total_amount_spent, COUNT(product_name) as Total_items_bought
FROM sales s
JOIN menu m
USING (product_id)
WHERE orderdate < '2021-01-07' AND '2021-01-09'
GROUP BY customer_id
LIMIT 2;

-- Customer A spent a total of 25 and bought 2 items before they became a member and B spent a total of 40, and got 3 items. C on the other hand
-- isn't a memeber


-- Question 9; If $1 spent equates to 10 points, and sushi has a 2x multiplier, how many points will each customer have?
SELECT customer_id, 
		SUM(CASE WHEN product_name = 'suchi' THEN price*20 ELSE price * 10 END ) AS total_points
FROM sales
JOIN menu
USING (product_id)
GROUP BY customer_id;

-- Customer A has the highest point of 760, B and C has points 740 and 360 respectively


-- Question 10; In the first week after a customer joins the program (including their join date)
-- they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT main.customer_id, IFNULL(Total_points, 0) + IFNULL(Total_points2,0) AS Total_points_combined
FROM(
		SELECT customer_id, SUM(price*20) as Total_points
		FROM sales
		JOIN menu USING (product_id)
		JOIN members USING (customer_id)
		WHERE orderdate BETWEEN '2021-01-07' AND '2021-01-14' 
				OR orderdate BETWEEN '2021-01-09' AND '2021-01-16'
		GROUP BY customer_id
		ORDER BY customer_id
        ) main
LEFT JOIN (
		SELECT customer_id, SUM(price*10) as Total_points2
		FROM sales
		JOIN menu USING (product_id)
		JOIN members USING (customer_id)
		WHERE orderdate BETWEEN '2021-01-14' AND '2021-01-31'
				OR orderdate BETWEEN '2021-01-16' AND '2021-01-31'
		GROUP BY customer_id
		ORDER BY customer_id
        ) sub
ON main.customer_id = sub.customer_id;

-- Customer A has 1020 points while customer B has 560