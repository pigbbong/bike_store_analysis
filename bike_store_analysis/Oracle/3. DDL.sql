------------------------------------------------------------
-- CATEGORIES
------------------------------------------------------------
DROP TABLE categories CASCADE CONSTRAINTS PURGE;

CREATE TABLE categories AS
SELECT * FROM categories_ext;

ALTER TABLE categories
  ADD CONSTRAINT categories_pk PRIMARY KEY (category_id);


------------------------------------------------------------
-- BRANDS
------------------------------------------------------------
DROP TABLE brands CASCADE CONSTRAINTS PURGE;

CREATE TABLE brands AS
SELECT * FROM brands_ext;

ALTER TABLE brands
  ADD CONSTRAINT brands_pk PRIMARY KEY (brand_id);


------------------------------------------------------------
-- PRODUCTS
------------------------------------------------------------
DROP TABLE products CASCADE CONSTRAINTS PURGE;

CREATE TABLE products AS
SELECT * FROM products_ext;

ALTER TABLE products
  ADD CONSTRAINT products_pk PRIMARY KEY (product_id);

ALTER TABLE products
  ADD CONSTRAINT products_brand_fk FOREIGN KEY (brand_id)
  REFERENCES brands (brand_id);

ALTER TABLE products
  ADD CONSTRAINT products_category_fk FOREIGN KEY (category_id)
  REFERENCES categories (category_id);


------------------------------------------------------------
-- CUSTOMERS
------------------------------------------------------------
DROP TABLE customers CASCADE CONSTRAINTS PURGE;

CREATE TABLE customers AS
SELECT * FROM customers_ext;

ALTER TABLE customers
  ADD CONSTRAINT customers_pk PRIMARY KEY (customer_id);


------------------------------------------------------------
-- STORES
------------------------------------------------------------
DROP TABLE stores CASCADE CONSTRAINTS PURGE;

CREATE TABLE stores AS
SELECT * FROM stores_ext;

ALTER TABLE stores
  ADD CONSTRAINT stores_pk PRIMARY KEY (store_id);


------------------------------------------------------------
-- STAFFS
------------------------------------------------------------
DROP TABLE staffs CASCADE CONSTRAINTS PURGE;

CREATE TABLE staffs AS
SELECT 
    TO_NUMBER(TRIM(staff_id)) AS staff_id,   -- 문자열 staff_id → NUMBER
    first_name,
    last_name,
    email,
    phone,
    active,
    store_id,
    CASE 
        WHEN manager_id IS NULL 
             OR TRIM(manager_id) = 'NULL' 
             OR TRIM(manager_id) = '' THEN NULL
        ELSE TO_NUMBER(TRIM(manager_id))     -- "NULL"/공백 문자열을 실제 NULL로 변환
    END AS manager_id
FROM staffs_ext;

ALTER TABLE staffs
  ADD CONSTRAINT staffs_pk PRIMARY KEY (staff_id);

ALTER TABLE staffs
  ADD CONSTRAINT staffs_manager_fk FOREIGN KEY (manager_id)
  REFERENCES staffs (staff_id);

ALTER TABLE staffs
  ADD CONSTRAINT staffs_store_fk FOREIGN KEY (store_id)
  REFERENCES stores (store_id);


------------------------------------------------------------
-- ORDERS
------------------------------------------------------------
DROP TABLE orders CASCADE CONSTRAINTS PURGE;

CREATE TABLE orders AS
SELECT order_id,
       customer_id,
       order_status,
       CASE 
         WHEN order_date IS NOT NULL 
              AND REGEXP_LIKE(order_date, '^\d{4}-\d{2}-\d{2}$')
           THEN TO_DATE(order_date, 'YYYY-MM-DD')
         ELSE NULL
       END AS order_date,
       CASE 
         WHEN required_date IS NOT NULL 
              AND REGEXP_LIKE(required_date, '^\d{4}-\d{2}-\d{2}$')
           THEN TO_DATE(required_date, 'YYYY-MM-DD')
         ELSE NULL
       END AS required_date,
       CASE 
         WHEN shipped_date IS NOT NULL 
              AND REGEXP_LIKE(shipped_date, '^\d{4}-\d{2}-\d{2}$')
           THEN TO_DATE(shipped_date, 'YYYY-MM-DD')
         ELSE NULL
       END AS shipped_date,
       store_id,
       staff_id
FROM orders_ext;

ALTER TABLE orders
  ADD CONSTRAINT orders_pk PRIMARY KEY (order_id);

ALTER TABLE orders
  ADD CONSTRAINT orders_customer_fk FOREIGN KEY (customer_id)
  REFERENCES customers (customer_id);

ALTER TABLE orders
  ADD CONSTRAINT orders_store_fk FOREIGN KEY (store_id)
  REFERENCES stores (store_id);

ALTER TABLE orders
  ADD CONSTRAINT orders_staff_fk FOREIGN KEY (staff_id)
  REFERENCES staffs (staff_id);


------------------------------------------------------------
-- ORDER_ITEMS
------------------------------------------------------------
DROP TABLE order_items CASCADE CONSTRAINTS PURGE;

CREATE TABLE order_items AS
SELECT * FROM order_items_ext;

ALTER TABLE order_items
  ADD CONSTRAINT order_items_pk PRIMARY KEY (order_id, item_id);

ALTER TABLE order_items
  ADD CONSTRAINT order_items_order_fk FOREIGN KEY (order_id)
  REFERENCES orders (order_id);

ALTER TABLE order_items
  ADD CONSTRAINT order_items_product_fk FOREIGN KEY (product_id)
  REFERENCES products (product_id);


------------------------------------------------------------
-- STOCKS
------------------------------------------------------------
DROP TABLE stocks CASCADE CONSTRAINTS PURGE;

CREATE TABLE stocks AS
SELECT * FROM stocks_ext;

ALTER TABLE stocks
  ADD CONSTRAINT stocks_pk PRIMARY KEY (store_id, product_id);

ALTER TABLE stocks
  ADD CONSTRAINT stocks_store_fk FOREIGN KEY (store_id)
  REFERENCES stores (store_id);

ALTER TABLE stocks
  ADD CONSTRAINT stocks_product_fk FOREIGN KEY (product_id)
  REFERENCES products (product_id);