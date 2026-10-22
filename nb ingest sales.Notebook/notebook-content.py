# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   }
# META }

# MARKDOWN ********************

# # Simulated sales ingestion
# Attach `lh_bronze` as this notebook's default Lakehouse before running.
# This notebook creates synthetic customers, products, sales, and sale lines.
# **Each run overwrites the four demo tables in the default Lakehouse.**
# A fixed seed makes the data reproducible; no external sources are required.

# CELL ********************

from datetime import datetime, timedelta
from decimal import Decimal
from random import Random

number_of_sales = 100
rng = Random(42)

customers = [
    (customer_id, f"Demo Customer {customer_id}")
    for customer_id in range(1, 11)
]

products = [
    (1, "Notebook", Decimal("4.50")),
    (2, "Pen", Decimal("1.25")),
    (3, "Backpack", Decimal("29.99")),
    (4, "Water Bottle", Decimal("12.00")),
    (5, "Desk Lamp", Decimal("24.95")),
]

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

sales = []
sale_lines = []
start_time = datetime(2026, 1, 1)

for sale_id in range(1, number_of_sales + 1):
    customer_id = rng.choice(customers)[0]
    sale_timestamp = start_time + timedelta(seconds=rng.randrange(30 * 24 * 60 * 60))
    sale_total = Decimal("0.00")

    for line_number, product in enumerate(
        rng.sample(products, rng.randint(1, 4)), start=1
    ):
        product_id, _, unit_price = product
        quantity = rng.randint(1, 5)
        line_total = unit_price * quantity
        sale_lines.append(
            (sale_id, line_number, product_id, quantity, unit_price, line_total)
        )
        sale_total += line_total

    sales.append((sale_id, customer_id, sale_timestamp, sale_total))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ## Write managed Delta tables
# `sales.customer_id` references `customers.customer_id`.
# Sale lines reference both `sales.sale_id` and `products.product_id`;
# `(sale_id, line_number)` identifies each line. Prices use decimal values,
# and each sale total is the sum of its line totals.

# CELL ********************

tables = [
    (
        "customers",
        customers,
        "customer_id INT, customer_name STRING",
    ),
    (
        "products",
        products,
        "product_id INT, product_name STRING, unit_price DECIMAL(10,2)",
    ),
    (
        "sales",
        sales,
        "sale_id INT, customer_id INT, sale_timestamp TIMESTAMP, sale_total DECIMAL(12,2)",
    ),
    (
        "sale_lines",
        sale_lines,
        "sale_id INT, line_number INT, product_id INT, quantity INT, "
        "unit_price DECIMAL(10,2), line_total DECIMAL(12,2)",
    ),
]

for table_name, rows, schema in tables:
    df = spark.createDataFrame(rows, schema=schema)
    df.write.format("delta").mode("overwrite").saveAsTable(table_name)
    print(f"Ingested {len(rows)} rows into {table_name}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
