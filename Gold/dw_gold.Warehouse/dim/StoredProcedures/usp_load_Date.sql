-- Loads dim.Date with one row per calendar day.
-- date_key is a yyyymmdd surrogate key. When no range is supplied, the range covers
-- full calendar years spanning the sale dates in lh_bronze.dbo.sales.
-- Only missing dates are inserted, so the procedure can be re-run safely.
CREATE PROCEDURE [dim].[usp_load_Date]
    @start_date DATE = NULL,
    @end_date   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Unknown member for missing sale dates
    IF NOT EXISTS (SELECT 1 FROM [dim].[Date] WHERE [date_key] = -1)
        INSERT INTO [dim].[Date] ([date_key], [date], [year], [quarter], [quarter_name], [month], [month_name],
                                  [year_month], [day_of_month], [day_of_week], [day_name], [day_of_year], [is_weekend])
        VALUES (-1, NULL, NULL, NULL, NULL, NULL, 'Unknown', NULL, NULL, NULL, 'Unknown', NULL, NULL);

    IF @start_date IS NULL
        SELECT @start_date = DATEFROMPARTS(YEAR(MIN(CAST([sale_timestamp] AS DATE))), 1, 1)
        FROM   [lh_bronze].[dbo].[sales];

    IF @end_date IS NULL
        SELECT @end_date = DATEFROMPARTS(YEAR(MAX(CAST([sale_timestamp] AS DATE))), 12, 31)
        FROM   [lh_bronze].[dbo].[sales];

    IF @start_date IS NULL OR @end_date IS NULL OR @start_date > @end_date
        RETURN;

    DECLARE @day_count INT = DATEDIFF(DAY, @start_date, @end_date) + 1;

    WITH digits AS (
        SELECT n FROM (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)) AS v (n)
    ),
    numbers AS (
        SELECT d1.n + d2.n * 10 + d3.n * 100 + d4.n * 1000 + d5.n * 10000 AS n
        FROM   digits AS d1
        CROSS JOIN digits AS d2
        CROSS JOIN digits AS d3
        CROSS JOIN digits AS d4
        CROSS JOIN digits AS d5
    ),
    dates AS (
        SELECT DATEADD(DAY, n, @start_date) AS [date]
        FROM   numbers
        WHERE  n < @day_count
    )
    INSERT INTO [dim].[Date] ([date_key], [date], [year], [quarter], [quarter_name], [month], [month_name],
                              [year_month], [day_of_month], [day_of_week], [day_name], [day_of_year], [is_weekend])
    SELECT YEAR(d.[date]) * 10000 + MONTH(d.[date]) * 100 + DAY(d.[date]),
           d.[date],
           YEAR(d.[date]),
           DATEPART(QUARTER, d.[date]),
           CONCAT('Q', DATEPART(QUARTER, d.[date])),
           MONTH(d.[date]),
           DATENAME(MONTH, d.[date]),
           YEAR(d.[date]) * 100 + MONTH(d.[date]),
           DAY(d.[date]),
           -- ISO day of week (Monday = 1), independent of DATEFIRST; 1900-01-01 was a Monday
           DATEDIFF(DAY, '19000101', d.[date]) % 7 + 1,
           DATENAME(WEEKDAY, d.[date]),
           DATEPART(DAYOFYEAR, d.[date]),
           CASE WHEN DATEDIFF(DAY, '19000101', d.[date]) % 7 >= 5 THEN 1 ELSE 0 END
    FROM   dates AS d
    WHERE  NOT EXISTS (SELECT 1 FROM [dim].[Date] AS x WHERE x.[date] = d.[date]);
END

GO