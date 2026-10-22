-- Loads fact.Sales from lh_bronze.dbo.sales and lh_bronze.dbo.sale_lines.
-- Grain: one row per sale and product. sale_bk is the source sale_id (degenerate dimension)
-- and date_key uses only the date portion of sale_timestamp.
-- Sales present in the source are deleted and reloaded, so the procedure can be re-run safely.
-- Run the dimension load procedures first; unmatched keys map to the -1 unknown members.
CREATE PROCEDURE [fact].[usp_load_Sales]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM [fact].[Sales]
        WHERE  [sale_bk] IN (SELECT [sale_id] FROM [lh_bronze].[dbo].[sales]);

        INSERT INTO [fact].[Sales] ([sale_bk], [date_key], [customer_key], [product_key],
                                    [quantity], [unit_price], [sales_amount])
        SELECT l.[sale_id],
               COALESCE(dd.[date_key], -1),
               COALESCE(dc.[customer_key], -1),
               COALESCE(dp.[product_key], -1),
               l.[quantity],
               CAST(l.[sales_amount] / NULLIF(l.[quantity], 0) AS DECIMAL (10, 2)),
               l.[sales_amount]
        FROM (
            SELECT [sale_id],
                   [product_id],
                   SUM([quantity])   AS [quantity],
                   SUM([line_total]) AS [sales_amount]
            FROM   [lh_bronze].[dbo].[sale_lines]
            GROUP BY [sale_id], [product_id]
        ) AS l
        INNER JOIN [lh_bronze].[dbo].[sales] AS s
            ON s.[sale_id] = l.[sale_id]
        LEFT JOIN [dim].[Date] AS dd
            ON dd.[date] = CAST(s.[sale_timestamp] AS DATE)
        LEFT JOIN [dim].[Customer] AS dc
            ON dc.[customer_bk] = s.[customer_id]
        LEFT JOIN [dim].[Product] AS dp
            ON dp.[product_bk] = l.[product_id];

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO