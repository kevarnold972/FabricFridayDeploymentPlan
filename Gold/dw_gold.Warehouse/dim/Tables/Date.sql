CREATE TABLE [dim].[Date] (
    [date_key]     INT          NOT NULL,
    [date]         DATE         NULL,
    [year]         SMALLINT     NULL,
    [quarter]      SMALLINT     NULL,
    [quarter_name] VARCHAR (2)  NULL,
    [month]        SMALLINT     NULL,
    [month_name]   VARCHAR (10) NULL,
    [year_month]   INT          NULL,
    [day_of_month] SMALLINT     NULL,
    [day_of_week]  SMALLINT     NULL,
    [day_name]     VARCHAR (10) NULL,
    [day_of_year]  SMALLINT     NULL,
    [is_weekend]   BIT          NULL
);


GO

ALTER TABLE [dim].[Date]
    ADD CONSTRAINT [PK_Date] PRIMARY KEY NONCLUSTERED ([date_key] ASC) NOT ENFORCED;


GO