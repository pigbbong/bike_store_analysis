-- 참고:
-- SQL Developer의 Import Data 기능을 사용하면
-- CSV 데이터를 일반 테이블로 더 간단하게 적재할 수 있다.
-- 하지만 필자는 Oracle의 External Table 기능을 활용하여
-- 데이터를 불러오는 방식을 직접 구현해 보았다.

-- 목적:
-- - 대용량 CSV 파일을 외부 테이블로 관리하는 방법 학습
-- - Oracle Loader 옵션, Access Parameters 사용법 실습


------------------------------------------------------------
-- BRANDS
------------------------------------------------------------
DROP TABLE brands_ext PURGE;

CREATE TABLE brands_ext (
    brand_id   NUMBER,
    brand_name VARCHAR2(30)
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
    (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
    )
    LOCATION ('brands.csv')
)
REJECT LIMIT UNLIMITED;


SELECT * FROM brands_ext;


------------------------------------------------------------
-- CATEGORIES
------------------------------------------------------------
DROP TABLE categories_ext PURGE;

CREATE TABLE categories_ext (
    category_id     NUMBER,
    category_name   VARCHAR2(30)
)
ORGANIZATION EXTERNAL
(
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
    (
          RECORDS DELIMITED BY NEWLINE
          SKIP 1
          NOBADFILE NOLOGFILE NODISCARDFILE
          FIELDS TERMINATED BY ','
    )
    LOCATION ('categories.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM categories_ext;


------------------------------------------------------------
-- CUSTOMERS
------------------------------------------------------------
DROP TABLE customers_ext PURGE;

CREATE TABLE customers_ext (
    customer_id NUMBER,
    first_name  VARCHAR2(20),
    last_name   VARCHAR2(20),
    phone       VARCHAR2(20),
    email       VARCHAR2(50),
    street      VARCHAR2(30),
    city        VARCHAR2(30),
    state       VARCHAR2(5),
    zip_code    VARCHAR2(5)
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
  ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
  )
  LOCATION ('customers.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM customers_ext;

------------------------------------------------------------
-- ORDERS ITEMS
------------------------------------------------------------
DROP TABLE order_items_ext PURGE;

CREATE TABLE order_items_ext (
    order_id   NUMBER,
    item_id    NUMBER,
    product_id NUMBER,
    quantity   NUMBER,
    list_price NUMBER,
    discount   NUMBER
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
  ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
  )
  LOCATION ('order_items.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM order_items_ext;


------------------------------------------------------------
-- ORDERS
------------------------------------------------------------
DROP TABLE orders_ext PURGE;

CREATE TABLE orders_ext (
    order_id       NUMBER,
    customer_id    NUMBER,
    order_status   NUMBER,
    order_date     VARCHAR2(20),
    required_date  VARCHAR2(20),
    shipped_date   VARCHAR2(20),
    store_id       NUMBER,
    staff_id       NUMBER
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
  ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
  )
  LOCATION ('orders.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM orders_ext;


------------------------------------------------------------
-- PRODUCTS
------------------------------------------------------------
DROP TABLE products_ext PURGE;

CREATE TABLE products_ext (
    product_id   NUMBER,
    product_name VARCHAR2(60),
    brand_id     NUMBER,
    category_id  NUMBER,
    model_year   NUMBER,
    list_price   NUMBER
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
  ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
  )
  LOCATION ('products.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM products_ext;


------------------------------------------------------------
-- STAFFS
------------------------------------------------------------
DROP TABLE staffs_ext PURGE;

CREATE TABLE staffs_ext (
    staff_id   VARCHAR(4),
    first_name VARCHAR2(50),
    last_name  VARCHAR2(50),
    email      VARCHAR2(50),
    phone      VARCHAR2(25),
    active     NUMBER,
    store_id   NUMBER,
    manager_id VARCHAR(4)
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
    ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
    )
    LOCATION ('staffs.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM staffs_ext;


------------------------------------------------------------
-- STOCKS
------------------------------------------------------------
DROP TABLE stocks_ext PURGE;

CREATE TABLE stocks_ext (
    store_id   NUMBER,
    product_id NUMBER,
    quantity   NUMBER
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
  ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
  )
  LOCATION ('stocks.csv')
)
REJECT LIMIT UNLIMITED;

SELECT * FROM stocks_ext;


------------------------------------------------------------
-- STORES
------------------------------------------------------------
DROP TABLE stores_ext PURGE;

CREATE TABLE stores_ext (
    store_id   NUMBER,
    store_name VARCHAR2(20),
    phone      VARCHAR2(15),
    email      VARCHAR2(30),
    street     VARCHAR2(30),
    city       VARCHAR2(15),
    state      VARCHAR2(5),
    zip_code   VARCHAR2(5)
)
ORGANIZATION EXTERNAL
( 
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY csv_dir
    ACCESS PARAMETERS
  ( 
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        NOBADFILE NOLOGFILE NODISCARDFILE
        FIELDS TERMINATED BY ','
  )
  LOCATION ('stores.csv')
)
REJECT LIMIT UNLIMITED;


SELECT * FROM stores_ext;
