# SQL – study scripts

SQL scripts written while studying **MySQL**, **Google BigQuery** and **SQL Server** (Alura courses and MBA in Data Science and Analytics, USP/Esalq). They cover:

- DDL and DML;
- joins, aggregations and subqueries;
- views;
- functions and UDFs;
- stored procedures;
- triggers;
- string and date handling.

**Each database lives in its own branch.** This `main` branch only holds this index.

| Branch | Database | Scripts |
|---|---|---|
| [`MySql`](https://github.com/PRBerlanda/SQL/tree/MySql) | MySQL 8 | First steps (stores, bookstore, views), analysis of a rental platform, functions, procedures with handlers and cursors, triggers |
| [`Google-BigQuery`](https://github.com/PRBerlanda/SQL/tree/Google-BigQuery) | BigQuery (GoogleSQL) | First queries, logical and numeric functions, strings and dates, UDFs and procedures that generate sales automatically |
| [`SQL-Server`](https://github.com/PRBerlanda/SQL/tree/SQL-Server) | SQL Server (T-SQL) | Facts vs dimensions (AdventureWorksDW), 1:1, 1:N and N:N relationships, inner, left, right and full joins |

Each branch has a README with what each script does, the database it expects and how to run it.

Related: the notebook [`ETL_Exporting_to_SQL`](https://github.com/PRBerlanda/Python-Data-Focused-/blob/main/ETL_Exporting_to_SQL.ipynb) generates the `INSERT` scripts that fill the `livraria` (bookstore) database used in the MySQL branch.
