-- create america table
CREATE CATALOG sales_america
TYPE 'iceberg'
PROPERTIES (
    'type'='hadoop',
    'warehouse'='/Users/ahmedabualsaud/github/beam-sql-demo/warehouse'
);

CREATE DATABASE sales_america.retail;
USE DATABASE sales_america.retail;

CREATE EXTERNAL TABLE orders (
    customer_id BIGINT,
    total_spend INT,
    city VARCHAR,
    state VARCHAR,
    order_ts TIMESTAMP)
TYPE 'iceberg';

INSERT INTO orders VALUES
  (100001,  84, 'Seattle',       'WA', TIMESTAMP '2026-06-15 09:14:22'),
  (100002, 156, 'Austin',        'TX', TIMESTAMP '2026-06-15 10:03:41'),
  (100003,  42, 'Miami',         'FL', TIMESTAMP '2026-06-15 11:28:09'),
  (100001, 238, 'Seattle',       'WA', TIMESTAMP '2026-06-15 13:47:55'),
  (100004,  97, 'Chicago',       'IL', TIMESTAMP '2026-06-15 15:12:18'),
  (100005, 315, 'San Francisco', 'CA', TIMESTAMP '2026-06-16 08:36:04'),
  (100002,  64, 'Austin',        'TX', TIMESTAMP '2026-06-16 09:58:33'),
  (100006, 129, 'Boston',        'MA', TIMESTAMP '2026-06-16 12:21:45'),
  (100003, 211, 'Miami',         'FL', TIMESTAMP '2026-06-16 14:09:27'),
  (100007,  73, 'Atlanta',       'GA', TIMESTAMP '2026-06-16 16:42:11');

SELECT * FROM orders ORDER BY customer_id ASC LIMIT 10;




-- create europe table
CREATE CATALOG sales_europe
TYPE 'iceberg'
PROPERTIES (
    'type'='hadoop',
    'warehouse'='/Users/ahmedabualsaud/github/beam-sql-demo/warehouse2'
);

USE CATALOG sales_europe;
SHOW DATABASES;

CREATE DATABASE sales_europe.retail;
USE DATABASE sales_europe.retail;

CREATE EXTERNAL TABLE orders (
    customer_id BIGINT,
    total_spend INT,
    city VARCHAR,
    country VARCHAR,
    order_ts TIMESTAMP)
TYPE 'iceberg';

INSERT INTO orders VALUES
  (100001, 142, 'London',    'United Kingdom', TIMESTAMP '2026-06-15 09:22:10'),
  (100002,  88, 'Paris',     'France',         TIMESTAMP '2026-06-15 10:41:33'),
  (100003, 196, 'Madrid',    'Spain',          TIMESTAMP '2026-06-15 12:08:54'),
  (100005, 254, 'Berlin',    'Germany',        TIMESTAMP '2026-06-15 14:37:19'),
  (200001,  73, 'Amsterdam', 'Netherlands',    TIMESTAMP '2026-06-16 08:16:45'),
  (200002, 119, 'Dublin',    'Ireland',        TIMESTAMP '2026-06-16 09:52:27'),
  (200003, 305, 'Milan',     'Italy',          TIMESTAMP '2026-06-16 11:24:08'),
  (200001,  61, 'Amsterdam', 'Netherlands',    TIMESTAMP '2026-06-16 13:05:31'),
  (200004, 177, 'Lisbon',    'Portugal',       TIMESTAMP '2026-06-16 15:48:12'),
  (200005,  94, 'Stockholm', 'Sweden',         TIMESTAMP '2026-06-16 17:29:44');

SELECT * FROM orders ORDER BY customer_id ASC LIMIT 10;


-- create global table
CREATE CATALOG global_sales
TYPE 'iceberg'
PROPERTIES (
    'type'='hadoop',
    'warehouse'='/Users/ahmedabualsaud/github/beam-sql-demo/warehouse3'
);

CREATE DATABASE global_sales.us_eu;
USE DATABASE global_sales.us_eu;

CREATE EXTERNAL TABLE total_spend_per_customer (
    customer_id BIGINT,
    total_spend INT)
TYPE 'iceberg';

-- query
INSERT INTO total_spend_per_customer (customer_id, total_spend)
SELECT
  a.customer_id,
  a.america_spend + e.europe_spend AS total_spend
FROM (
  SELECT customer_id, SUM(total_spend) AS america_spend
  FROM sales_america.retail.orders
  GROUP BY customer_id
) AS a
JOIN (
  SELECT customer_id, SUM(total_spend) AS europe_spend
  FROM sales_europe.retail.orders
  GROUP BY customer_id
) AS e
  ON a.customer_id = e.customer_id;


SELECT * FROM total_spend_per_customer ORDER BY customer_id ASC LIMIT 10;
