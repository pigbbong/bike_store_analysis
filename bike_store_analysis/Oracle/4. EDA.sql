---------------------------------------
-- EDA1: 브랜드별 매출 분포
---------------------------------------

SELECT  b.brand_name, 
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT (SUM(oi.quantity * oi.list_price * (1 - oi.discount))) OVER () * 100, 2) AS pct_of_revenue
FROM    brands b
JOIN    products p
ON      b.brand_id = p.brand_id
JOIN    order_items oi
ON      p.product_id = oi.product_id
GROUP BY b.brand_name
ORDER BY 3 DESC, 2 DESC;

-- 확인 결과, Trek 브랜드가 전체 매출의 60%나 차지하는 것이 보인다.
-- 그 다음으로 Electra, Surly가 각각 16%, 12%를 차지하는 것을 보여주며,
-- 그 외 나머지 브랜드가 총 12% 지분을 보여줌.



---------------------------------------
-- EDA2: 가격대 구간별 매출
---------------------------------------

WITH brand_price AS (
    SELECT p.brand_id,
           AVG(p.list_price) AS avg_price
    FROM products p
    GROUP BY p.brand_id
), brand_revenue AS (
    SELECT  p.brand_id,
            ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue
    FROM    order_items oi
    JOIN    products p 
    ON      oi.product_id = p.product_id
    GROUP BY p.brand_id
), price_percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_price) AS p25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_price) AS p75
    FROM brand_price
)
SELECT  b.brand_name,
        ROUND(bp.avg_price, 2) AS avg_price,
        br.revenue,
        CASE
            WHEN bp.avg_price < (SELECT p25 FROM price_percentiles) THEN 'Low'
            WHEN bp.avg_price <= (SELECT p75 FROM price_percentiles) THEN 'Mid'
            ELSE 'High'
        END AS price_tier
FROM    brand_price bp
JOIN    brand_revenue br 
ON      bp.brand_id = br.brand_id
JOIN    brands b 
ON      bp.brand_id = b.brand_id
ORDER BY 3 DESC, 2;

-- High Tier (고가)
-- Trek: 평균가 최고(2500) + 매출도 압도적 1위 (460만)
-- Heller: 고가(2173)지만 매출은 중간 수준.

-- Mid Tier (중가)
-- Electra, Surly, Sun Bicycles, Haro, Ritchey → 비교적 고르게 분포함.

-- Low Tier (저가)
-- Strider: 평균가 최저(209)인데 매출은 꼴찌 수준 (4320).
-- Pure Cycles: 저가(442)지만 매출은 Strider보다 훨씬 높음 (149k).


---------------------------------------
-- EDA3: 브랜드별 월별 매출 추이
---------------------------------------

WITH order_season AS (
    SELECT  order_id,
            '20' || SUBSTR(order_date, 1, 2) AS year,
            SUBSTR(order_date, 4, 2) AS month,
            CASE 
                WHEN SUBSTR(order_date, 4, 2) IN ('01','02','03') THEN 1
                WHEN SUBSTR(order_date, 4, 2) IN ('04','05','06') THEN 2
                WHEN SUBSTR(order_date, 4, 2) IN ('07','08','09') THEN 3
                ELSE 4
            END AS season
    FROM    orders
)
SELECT  b.brand_name, 
        os.year, 
        os.season,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT (SUM(oi.quantity * oi.list_price * (1 - oi.discount)))  
            OVER (PARTITION BY b.brand_name) * 100, 2) 
        AS pct_of_revenue
FROM    order_season os
JOIN    order_items oi
ON      (os.order_id = oi.order_id)
JOIN    products p
ON      (oi.product_id = p.product_id)
JOIN    brands b
ON      (p.brand_id = b.brand_id)
GROUP BY b.brand_name, os.year, os.season
ORDER BY 1, 2, 3;


-- Trek은 연중 안정적 매출 유지, 2017~2018 상승세 뚜렷.

-- Electra·Surly는 특정 분기 반짝 매출, 이후 급락.

-- Sun Bicycles는 2017년 Q3에 최고 매출, 이후 급감.



----------------------------------------------------------------
-- EDA4: 한 번만 구매한 고객 vs 재구매한 고객의 매출 기여도 차이
----------------------------------------------------------------

WITH customer_purchase_count AS (
    SELECT  order_id,
            customer_id,
            CASE
                WHEN MAX(rn) OVER (PARTITION BY customer_id) = 1 THEN 'one'
                ELSE 'repeat'
            END AS customer_type
    FROM    (
        SELECT  order_id,
                customer_id,
                ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
        FROM    orders
    )
)
SELECT  cpc.customer_type, 
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT (SUM(oi.quantity * oi.list_price * (1 - oi.discount))) OVER (), 2) AS pct_of_revenue
FROM    customer_purchase_count cpc
JOIN    order_items oi
ON      cpc.order_id = oi.order_id
GROUP BY cpc.customer_type;

-- 신규 고객들로부터의 수익 비중이 재구매 고객보다 훨씬 높음을 알 수 있음.


---------------------------------------------
-- EDA5: 브랜드 매장별 같은 위치에 사는 고객 비율
---------------------------------------------

WITH customer_store_match AS (
    SELECT  o.order_id,
            o.customer_id,
            s.store_id,
            s.city   AS store_city,
            s.state  AS store_state,
            c.city   AS cust_city,
            c.state  AS cust_state,
            CASE 
                WHEN s.city = c.city AND s.state = c.state THEN 1 
                ELSE 0 
            END AS same_location
    FROM    orders o
    JOIN    customers c 
    ON      o.customer_id = c.customer_id
    JOIN    stores s    
    ON      o.store_id = s.store_id
),

brand_customer_location AS (
    SELECT  b.brand_name,
            cs.same_location
    FROM    customer_store_match cs
    JOIN    order_items oi 
    ON      cs.order_id = oi.order_id
    JOIN    products p     
    ON      oi.product_id = p.product_id
    JOIN    brands b       
    ON      p.brand_id = b.brand_id
)

SELECT  brand_name,
        COUNT(*) AS total_orders,
        SUM(same_location) AS same_location_orders,
        ROUND(SUM(same_location) * 100.0 / COUNT(*), 2) AS pct_same_location
FROM    brand_customer_location
GROUP BY brand_name
ORDER BY pct_same_location DESC;

-- 브랜드별 매출은 매장-고객의 물리적 위치와 큰 상관성이 없음.


---------------------------------------------
-- EDA6: 브랜드별 평균 할인 비율
---------------------------------------------

SELECT  b.brand_name, 
        ROUND(AVG(oi.discount), 2) AS avg_discount_rate
FROM    order_items oi
JOIN    products p
ON      oi.product_id = p.product_id
JOIN    brands b
ON      p.brand_id = b.brand_id
GROUP BY b.brand_name;

-- 각 브랜드별 할인 비율은 거의 차이가 없음을 보여줌.



---------------------------------------------
-- EDA7: 카테고리별 매출 집중도
---------------------------------------------

SELECT  c.category_name,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT (SUM(oi.quantity * oi.list_price * (1 - oi.discount)))  
            OVER () * 100, 2) 
        AS pct_of_revenue
FROM    order_items oi
JOIN    products p
ON      oi.product_id = p.product_id
JOIN    categories c
ON      p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY 3 DESC;

-- 전체 매출은 Mountain Bikes(35%)와 Road Bikes(22%)가 절반 이상을 차지하며, 나머지 카테고리들은 Cruisers·Electric(각각 ~12%) 이하 수준에 분포함.



---------------------------------------------
-- EDA8: 분기별 카테고리별 매출 추이
---------------------------------------------

WITH order_season AS (
    SELECT  o.order_id,
            '20' || SUBSTR(o.order_date, 1, 2) AS year,
            CASE 
                WHEN SUBSTR(o.order_date, 4, 2) IN ('01','02','03') THEN 1
                WHEN SUBSTR(o.order_date, 4, 2) IN ('04','05','06') THEN 2
                WHEN SUBSTR(o.order_date, 4, 2) IN ('07','08','09') THEN 3
                ELSE 4
            END AS season
    FROM    orders o
)
SELECT  c.category_name,
        os.year,
        os.season,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT(SUM(oi.quantity * oi.list_price * (1 - oi.discount)))
              OVER (PARTITION BY c.category_name) * 100, 2) AS pct_revenue
FROM    order_items oi
JOIN    products p ON oi.product_id = p.product_id
JOIN    categories c ON p.category_id = c.category_id
JOIN    order_season os ON oi.order_id = os.order_id
GROUP BY c.category_name, os.year, os.season
ORDER BY 1, 2, 3;

-- Mountain Bikes / Road Bikes: 전체 매출을 압도적으로 견인하는 주력 카테고리, 시즌별로 등락은 있으나 꾸준히 상위권 유지.

-- Electric Bikes: 2017~2018년 들어 매출이 빠르게 성장하면서 새로운 성장동력으로 작용.

-- Cyclocross Bicycles: 특정 시즌(Q2, Q4)에만 매출이 튀는 형태 -> 전형적인 시즌성 제품.

-- Children / Comfort Bicycles: 상대적으로 안정적이지만 매출 규모는 작은 편.



---------------------------------------------
-- EDA9: 고객 지역(주/도시)별 매출 분포
---------------------------------------------

SELECT  c.state,
        c.city,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue,
        ROUND(RATIO_TO_REPORT(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) 
              OVER (PARTITION BY c.state) * 100, 2) AS pct_in_state
FROM    customers c
JOIN    orders o 
ON      c.customer_id = o.customer_id
JOIN    order_items oi
ON      o.order_id = oi.order_id
GROUP BY c.state, c.city
ORDER BY 1, 4 DESC;

-- CA는 매출이 여러 도시에 고르게 분산 되어 있고,
-- NY는 전체적으로 소규모 기여가 많음.
-- TX는 소수의 특정 도시(특히 San Angelo, Houston)가 매출 대부분을 견인하는 집중도가 높은 구조로 되어 있음.


---------------------------------------------
-- EDA10: 고객별 평균 구매 단가/장바구니 크기
---------------------------------------------

SELECT  c.customer_id, 
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(AVG(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS avg_order_value,
        ROUND(AVG(oi.quantity)) AS avg_cart_size
FROM    order_items oi
JOIN    orders o
ON      oi.order_id = o.order_id
JOIN    customers c
ON      o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY 1;

-- 고객별 평균 장바구니 크기(cart size)는 비교적 작고, 주문 단가가 고가 브랜드 유무에 따라 분포 차이를 보임.
