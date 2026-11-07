# SQL – Google BigQuery

Part of the [SQL](https://github.com/PRBerlanda/SQL) study repository. Each database lives in its own branch.

All scripts use the `belleza_verde` dataset (a fictitious cosmetics company from the Alura course). Its tables are:

- `clientes` / `clientes2`;
- `produtos`, whose `materiasprimas` and `distribuicao` columns are arrays;
- `materiasprimas`;
- `vendas`.

| Script | What it covers |
|---|---|
| `Starting_on_BigQuery.sql` | First queries, aggregations, `EXTRACT`, CTEs (`WITH`), arrays and `UNNEST` |
| `Logics_and_numbers.sql` | Logical and conditional functions, rounding and numeric functions, year-over-year sales comparison, `SAFE_OFFSET` |
| `Strings_and_dates.sql` | Text functions, cleaning customer data, `GENERATE_DATE_ARRAY`, date parts and formatting |
| `UDFs_Procedures.sql` | Procedures `incluiVenda1` to `incluiVenda5` (existence checks, `OUT` parameters, automatic price), UDFs `NumAleatorio` and `dataFormatada`, product cost from parallel arrays, and the final chain `incluiVenda5` → `incluiVendaFinal` → `conjuntoVendas`, which generates random daily sales |

## How to run

1. Create a dataset called `belleza_verde` in your Google Cloud project.
2. Load the course tables into it.
3. Open the BigQuery console, then select each block and run it.

The test blocks in `UDFs_Procedures.sql` are wrapped in `BEGIN ... END`, because BigQuery only accepts `DECLARE` at the start of a script or block. The final `CALL belleza_verde.conjuntoVendas(1, 10, 1, 5, 10)` can be set up as a *scheduled query* to generate sales every day.

## Changes from the original scripts

All the fixes are in `UDFs_Procedures.sql`; the other three scripts are unchanged, except that their line endings were normalised.

- **Customer check fixed.** Every customer check looked in the **products** table (`produtos WHERE id_cliente = ...`). It now uses `clientes`.
- **`incluiVendaFinal` call fixed.** `conjuntoVendas` called it as `(quantidade, dataVenda, margemLucro)`, but the signature is `(dataVenda, quantidade, margemLucro)`.
- **`conjuntoVendas` fixed:**
  - it used `minVendasDias`/`maxVendasDias`, but the parameters are `minVendasDia`/`maxVendasDia`;
  - `SET dataInicial = select ...` is not valid syntax and was replaced.
- **`incluiVenda3`/`incluiVenda4`:** the `OUT` parameters were declared outside the parameter list.
- **`incluiVenda1`:** it assigned `id_venda` (an undeclared name, the column) instead of the variable `idVenda`, so the procedure failed to compile.
- **`incluiVenda2`:** the test called the 6-parameter prototype `incluiVenda` with 5 arguments. It now calls `incluiVenda2`.
- **`incluiVenda5`:** the manufacturing cost was assigned with `precoVendaMP = WITH ...`, without `SET` and parentheses.
- **Product-cost query:**
  - `materias primas` had a space;
  - the distribution array read `materiasprimas` instead of `distribuicao`;
  - the alias `distribuica_materia` did not match `distribuicao_materia`;
  - `CROSS JOIN ... ON` is invalid and became `JOIN ... ON`;
  - the cost is now grouped per product.
- **Missing `;`** after several `SET (...)` statements; the `IF ... END IF` / `BEGIN ... END` blocks were rebuilt.

> **Not run:** no BigQuery project was available in this review. The simple statements were parsed with a SQL parser and the scripting blocks were reviewed by hand against the GoogleSQL syntax.
