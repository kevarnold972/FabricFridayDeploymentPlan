-- Populates dw_gold from lh_bronze: dimensions first, then the fact table.
CREATE PROCEDURE [dbo].[usp_load_dw_gold]
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [dim].[usp_load_Customer];
    EXEC [dim].[usp_load_Product];
    EXEC [dim].[usp_load_Date];
    EXEC [fact].[usp_load_Sales];
END
