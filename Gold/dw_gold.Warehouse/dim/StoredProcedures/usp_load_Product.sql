-- Loads dim.Product from lh_bronze.dbo.products (SCD Type 1).
-- product_key is the warehouse surrogate key; product_bk carries the source product_id.
CREATE PROCEDURE [dim].[usp_load_Product]
AS
BEGIN
    SET NOCOUNT ON;

    -- Unknown member for late-arriving or missing products
    IF NOT EXISTS (SELECT 1 FROM [dim].[Product] WHERE [product_key] = -1)
        INSERT INTO [dim].[Product] ([product_key], [product_bk], [product_name], [unit_price])
        VALUES (-1, -1, 'Unknown', NULL);

    -- Overwrite changed attributes for existing business keys
    UPDATE d
    SET    d.[product_name] = COALESCE(s.[product_name], 'Unknown'),
           d.[unit_price]   = s.[unit_price]
    FROM   [dim].[Product] AS d
    INNER JOIN [lh_bronze].[dbo].[products] AS s
        ON s.[product_id] = d.[product_bk]
    WHERE  d.[product_name] <> COALESCE(s.[product_name], 'Unknown')
       OR  COALESCE(d.[unit_price], -1) <> COALESCE(s.[unit_price], -1);

    -- Insert new business keys with the next surrogate keys
    DECLARE @max_key INT = (SELECT COALESCE(MAX([product_key]), 0) FROM [dim].[Product] WHERE [product_key] > 0);

    INSERT INTO [dim].[Product] ([product_key], [product_bk], [product_name], [unit_price])
    SELECT @max_key + ROW_NUMBER() OVER (ORDER BY s.[product_id]),
           s.[product_id],
           COALESCE(s.[product_name], 'Unknown'),
           s.[unit_price]
    FROM   [lh_bronze].[dbo].[products] AS s
    WHERE  s.[product_id] IS NOT NULL
      AND  NOT EXISTS (SELECT 1 FROM [dim].[Product] AS d WHERE d.[product_bk] = s.[product_id]);
END
