-- create america table
CREATE CATALOG sales_america
TYPE 'iceberg'
PROPERTIES (
    'catalog-impl'='org.apache.iceberg.aws.glue.GlueCatalog',
    'warehouse'='s3://sales-america',
    'client.region'='us-east-2',
    'io-impl'='org.apache.iceberg.aws.s3.S3FileIO'
);

USE CATALOG sales_america;
SHOW DATABASES;

DROP DATABASE IF EXISTS sales_america.retail CASCADE;
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


-- create europe table
CREATE CATALOG sales_europe
TYPE 'iceberg'
PROPERTIES (
    'type'='rest',
    'uri'='https://dbc-09b7f10f-a19c.cloud.databricks.com/api/2.1/unity-catalog/iceberg-rest',
    'oauth2-server-uri'='https://dbc-09b7f10f-a19c.cloud.databricks.com/oidc/v1/token',
    'credential'='f8c295c9-d57e-4fa5-9d20-621a1ee0062f:dose314f327aecd97e0e337f8cfc3e48e6a5',
    'warehouse'='my_catalog',
    'io-impl'='org.apache.iceberg.aws.s3.S3FileIO',
    'client.region'='us-east-1',
    'scope'='all-apis',
    'header.X-Iceberg-Access-Delegation'='vended-credentials'
);
USE CATALOG sales_europe;
SHOW DATABASES;

DROP DATABASE IF EXISTS sales_europe.retail CASCADE;
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



-- create global sales table
CREATE CATALOG global_sales
TYPE 'iceberg'
PROPERTIES (
    'type' = 'rest',
    'uri' = 'https://biglake.googleapis.com/iceberg/v1/restcatalog',
    'warehouse' = 'gs://sales-global',
    'header.x-goog-user-project' = 'apache-beam-testing',
    'rest.auth.type' = 'google',
    'io-impl' = 'org.apache.iceberg.gcp.gcs.GCSFileIO',
    'header.X-Iceberg-Access-Delegation' = 'vended-credentials'
);

DROP DATABASE IF EXISTS global_sales.us_eu CASCADE;
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
