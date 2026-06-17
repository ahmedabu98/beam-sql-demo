# Beam SQL Iceberg Cross-Catalog Demo

This repo demonstrates Apache Beam SQL querying across multiple Apache Iceberg catalogs from the Beam SQL shell.

The demo creates two regional `orders` tables in different Iceberg catalogs, then writes a derived global table by joining across those catalogs:

- `sales_america`: Iceberg `GlueCatalog` backed by AWS Glue + S3
- `sales_europe`: Iceberg REST catalog backed by Databricks Unity Catalog
- `global_sales`: Iceberg REST catalog backed by Google BigLake + GCS

Beam SQL can run normal SQL DDL and DML across separate catalog implementations, then join them in one query.

## What This Shows

- Connecting to Iceberg catalogs with `CREATE CATALOG`
- Creating namespaces/databases with `CREATE DATABASE`
- Creating Iceberg tables with `CREATE EXTERNAL TABLE`
- Writing rows with `INSERT INTO`
- Running cross-catalog SQL joins
- Writing query results into a third Iceberg catalog

## Requirements

- Java 11 or newer
- Bash
- Network access to Maven Central
- Valid credentials for the catalogs you want to use
- Apache Beam SQL shell script, `beam-sql.sh`

## Get The Beam SQL Shell

Use the Beam SQL shell script from Apache Beam and include Iceberg:

```bash
./beam-sql.sh --version 2.75.0-SNAPSHOT --io iceberg
```
