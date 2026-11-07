# SQL – SQL Server (T-SQL)

Part of the [SQL](https://github.com/PRBerlanda/SQL) study repository. Each database lives in its own branch.

`Joins_and_relationships.sql` covers:

- **Facts vs dimensions:** joins `FactInternetSales` with `DimCustomer` and `DimCurrency` in the Microsoft sample data warehouse **AdventureWorksDW2017**.
- **Relationships:** creates the `CLINICA` database (patients, addresses, phones, doctors, appointments) to practise 1:1, 1:N and N:N relationships.
- **Joins:** `INNER`, `LEFT`, `RIGHT` and `FULL JOIN`, plus "only rows without a match" (patients with no appointment, doctors with no patients).

## How to run

- **Facts vs dimensions:** restore [AdventureWorksDW2017](https://learn.microsoft.com/sql/samples/adventureworks-install-configure) to run the first block.
- **Everything else:** the script creates its own database, so you only need SQL Server (Express or Developer). Run it in SSMS or Azure Data Studio; `GO` separates the batches.

## Changes from the original script

- **Moved here** from the MySQL folder, where it was saved as `Queries2.sql`: it is T-SQL.
- **Converted from Windows-1252 to UTF-8**, so accents display correctly on GitHub, for example `DIFERENÇA` and `JUNÇÃO`.
- **Dates in ISO format.** The appointment dates were written as `'23/05/2019'`. SQL Server reads that according to the session language, and with the default `us_english` it fails for days above 12. The dates are now `'20190523'`, which works in any configuration.
