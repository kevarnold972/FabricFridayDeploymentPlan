CREATE TABLE [fact].[Sales] (
    [sale_bk]      INT             NOT NULL,
    [date_key]     INT             NOT NULL,
    [customer_key] INT             NOT NULL,
    [product_key]  INT             NOT NULL,
    [quantity]     INT             NOT NULL,
    [unit_price]   DECIMAL (10, 2) NULL,
    [sales_amount] DECIMAL (12, 2) NOT NULL
);


GO

ALTER TABLE [fact].[Sales]
    ADD CONSTRAINT [FK_Sales_Customer] FOREIGN KEY ([customer_key]) REFERENCES [dim].[Customer] ([customer_key]) NOT ENFORCED;


GO

ALTER TABLE [fact].[Sales]
    ADD CONSTRAINT [FK_Sales_Date] FOREIGN KEY ([date_key]) REFERENCES [dim].[Date] ([date_key]) NOT ENFORCED;


GO

ALTER TABLE [fact].[Sales]
    ADD CONSTRAINT [FK_Sales_Product] FOREIGN KEY ([product_key]) REFERENCES [dim].[Product] ([product_key]) NOT ENFORCED;


GO

ALTER TABLE [fact].[Sales]
    ADD CONSTRAINT [PK_Sales] PRIMARY KEY NONCLUSTERED ([sale_bk] ASC, [product_key] ASC) NOT ENFORCED;


GO