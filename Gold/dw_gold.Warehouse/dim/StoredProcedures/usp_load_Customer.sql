-- Loads dim.Customer from lh_bronze.dbo.customers (SCD Type 1).
-- customer_key is the warehouse surrogate key; customer_bk carries the source customer_id.
CREATE PROCEDURE [dim].[usp_load_Customer]
AS
BEGIN
    SET NOCOUNT ON;

    -- Unknown member for late-arriving or missing customers
    IF NOT EXISTS (SELECT 1 FROM [dim].[Customer] WHERE [customer_key] = -1)
        INSERT INTO [dim].[Customer] ([customer_key], [customer_bk], [customer_name])
        VALUES (-1, -1, 'Unknown');

    -- Overwrite changed attributes for existing business keys
    UPDATE d
    SET    d.[customer_name] = COALESCE(s.[customer_name], 'Unknown')
    FROM   [dim].[Customer] AS d
    INNER JOIN [lh_bronze].[dbo].[customers] AS s
        ON s.[customer_id] = d.[customer_bk]
    WHERE  d.[customer_name] <> COALESCE(s.[customer_name], 'Unknown');

    -- Insert new business keys with the next surrogate keys
    DECLARE @max_key INT = (SELECT COALESCE(MAX([customer_key]), 0) FROM [dim].[Customer] WHERE [customer_key] > 0);

    INSERT INTO [dim].[Customer] ([customer_key], [customer_bk], [customer_name])
    SELECT @max_key + ROW_NUMBER() OVER (ORDER BY s.[customer_id]),
           s.[customer_id],
           COALESCE(s.[customer_name], 'Unknown')
    FROM   [lh_bronze].[dbo].[customers] AS s
    WHERE  s.[customer_id] IS NOT NULL
      AND  NOT EXISTS (SELECT 1 FROM [dim].[Customer] AS d WHERE d.[customer_bk] = s.[customer_id]);
END
