CREATE TABLE [dim].[Customer] (
    [customer_key]  INT           NOT NULL,
    [customer_bk]   INT           NOT NULL,
    [customer_name] VARCHAR (200) NOT NULL
);


GO

ALTER TABLE [dim].[Customer]
    ADD CONSTRAINT [PK_Customer] PRIMARY KEY NONCLUSTERED ([customer_key] ASC) NOT ENFORCED;


GO

ALTER TABLE [dim].[Customer]
    ADD CONSTRAINT [UQ_Customer_bk] UNIQUE NONCLUSTERED ([customer_bk] ASC) NOT ENFORCED;


GO