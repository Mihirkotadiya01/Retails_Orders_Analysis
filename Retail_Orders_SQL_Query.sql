select * from df_order


	
--top 10 highest revenue genrating product
SELECT product_id, SUM(sale_price) AS sales
FROM df_order
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;





--top 5 highest selling products in each region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_order
    GROUP BY region, product_id
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;






--month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH cte AS (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_order
    GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY order_month
ORDER BY order_month;






--for each category which month had highest sales 
WITH cte AS (
    SELECT category,
           TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
           SUM(sale_price) AS sales
    FROM df_order
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
)
SELECT category, order_year_month, sales
FROM (
    SELECT category, order_year_month, sales,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY sales DESC) AS rn
    FROM cte
) AS subquery
WHERE rn = 1;





--which sub category had highest growth by profit in 2023 compare to 2022
WITH cte AS (
    SELECT sub_category,
           EXTRACT(YEAR FROM order_date) AS order_year,
           SUM(sale_price) AS sales
    FROM df_order
    GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
),
cte2 AS (
    SELECT sub_category,
           SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
           SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
    FROM cte
    GROUP BY sub_category
)
SELECT sub_category, sales_2022, sales_2023, (sales_2023 - sales_2022) AS profit_growth
FROM cte2
ORDER BY profit_growth DESC
LIMIT 1;




