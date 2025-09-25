-- 가설1:
-- 고가 브랜드는 연중 꾸준히 매출을 유지하지만, 
-- 중가 브랜드는 특정 시즌에 집중적으로 매출이 발생하며, 
-- 이 시즌에서의 매출 상승 폭은 신규 고객보다는 기존 고객이 더 크게 기여한다.

WITH brand_price AS (
    SELECT p.brand_id,
           AVG(p.list_price) AS avg_price
    FROM products p
    GROUP BY p.brand_id
), price_percentiles AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_price) AS p25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_price) AS p75
    FROM brand_price
), brand_tier AS (
    SELECT bp.brand_id,
           CASE 
             WHEN bp.avg_price < (SELECT p25 FROM price_percentiles) THEN 'Low'
             WHEN bp.avg_price <= (SELECT p75 FROM price_percentiles) THEN 'Mid'
             ELSE 'High'
           END AS tier
    FROM brand_price bp
), first_orders AS (
    SELECT customer_id,
           MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
), customer_orders AS (
    SELECT o.order_id,
           o.customer_id,
           o.order_date,
           CASE WHEN o.order_date = f.first_order_date 
                THEN 'New'
                ELSE 'Existing'
           END AS customer_type
    FROM orders o
    JOIN first_orders f 
    ON   o.customer_id = f.customer_id
), order_season AS (
    SELECT  order_id,
            CASE 
                WHEN SUBSTR(order_date, 4, 2) IN ('01','02','03') THEN 1
                WHEN SUBSTR(order_date, 4, 2) IN ('04','05','06') THEN 2
                WHEN SUBSTR(order_date, 4, 2) IN ('07','08','09') THEN 3
                ELSE 4
            END AS season
    FROM orders
)
SELECT  
        CASE WHEN GROUPING(bt.tier) = 1 THEN 'TOTAL_TIERS' ELSE bt.tier END AS tier,
        CASE WHEN GROUPING(co.customer_type) = 1 THEN 'TOTAL_CUSTOMERS' ELSE co.customer_type END AS customer_type,
        CASE WHEN GROUPING(os.season) = 1 THEN 'TOTAL_SEASONS' ELSE TO_CHAR(os.season) END AS season,
        ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount))) AS revenue
FROM    order_items oi
JOIN    products p     
ON      oi.product_id = p.product_id
JOIN    brand_tier bt  
ON      p.brand_id = bt.brand_id
JOIN    customer_orders co 
ON      oi.order_id = co.order_id
JOIN    order_season os   
ON      oi.order_id = os.order_id
WHERE   bt.tier IN ('High','Mid')
GROUP BY ROLLUP (bt.tier, co.customer_type, os.season)
ORDER BY 1, 2, 3;


--******
-- 결과
--******

-----------------------------------------------
-- High Tier (고가 브랜드)
-----------------------------------------------

-- 총 매출: 약 4.77M (전체의 ~63%)


-- Existing 고객
----------------
-- 합계: 681K (High Tier의 14% 수준)
-- Q2에서 **575K (84%)**로 압도적으로 몰림
-- 나머지 분기(Q1/Q3/Q4)는 각 3~5% 수준

-- 기존 고객은 특정 시즌(2분기)에만 집중적으로 소비하고, 나머지 시즌에는 활동이 미미함.


-- New 고객
----------------
-- 합계: 4.09M (High Tier의 86%)
-- Q1~Q4에 고르게 분포 (15~21%씩)
-- Q1은 1.54M으로 가장 큼

-- 신규 고객이 연중 고르게 분포된 매출을 견인, 고가 브랜드의 주 매출원 역할.


-----------------------------------------------
-- Mid Tier (중가 브랜드)
-----------------------------------------------

-- 총 매출: 약 2.76M (전체의 ~37%)


-- Existing 고객
----------------

-- 합계: 330K (Mid Tier의 12%)
-- Q2에서 **256K (78%)**로 몰림
-- 나머지 분기(Q1/Q3/Q4)는 합쳐도 70K (22%)

-- 기존 고객 매출이 High Tier와 마찬가지로 특정 시즌(2분기)에 집중됨.


-- New 고객
----------------
-- 합계: 2.43M (Mid Tier의 88%)
-- Q1~Q4 매출이 각각 500~780K 수준으로 고르게 분포
-- 특히 Q1(784K) 매출이 가장 큼

-- 신규 고객이 중가 브랜드 매출 대부분을 차지하며, 꾸준히 유입되는 구조.


--******
-- 종합
--******
-- 고가/중가 브랜드 모두 신규 고객 의존도가 매우 높음 (매출의 85% 이상) -> 기존 고객 충성도/재구매 유도 전략이 부족하다고 해석 가능.
-- 기존 고객 매출은 시즌성(Q2 집중)이 뚜렷 -> 특정 시점에만 반응하는 패턴.
-- 신규 고객은 연중 꾸준히 발생 -> 브랜드 인지도가 신규 유입을 지속적으로 만든다는 점에서 마케팅 효과가 일정하게 유지됨.


--******
-- 결론
--******
-- High/Mid 티어 브랜드 모두 신규 고객에 의존도가 크며, 기존 고객은 특정 시즌에만 기여한다. 
-- 따라서 재구매 고객을 늘리기 위한 유지 전략(멤버십, 시즌 외 할인 등)이 필요하다.