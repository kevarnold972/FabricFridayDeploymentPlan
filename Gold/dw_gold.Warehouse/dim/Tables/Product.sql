CREATE TABLE [dim].[Product] (
    [product_key]  INT           NOT NULL,
    [product_bk]   INT           NOT NULL,
    [product_name] VARCHAR (200) NOT NULL,
    [unit_price]   DECIMAL (10, 2) NULL
);
GO

ALTER TABLE [dim].[Product]
    ADD CONSTRAINT [PK_Product] PRIMARY KEY NONCLUSTERED ([product_key] ASC) NOT ENFORCED;
GO

ALTER TABLE [dim].[Product]
    ADD CONSTRAINT [UQ_Product_bk] UNIQUE NONCLUSTERED ([product_bk] ASC) NOT ENFORCED;
