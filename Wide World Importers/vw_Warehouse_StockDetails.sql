USE WideWorldImporters;
GO

CREATE VIEW Warehouse.StockDetails
AS (
	SELECT si.StockItemID, StockItemName, SupplierID, ColorID, stockgroup.StockGroupName, PackageTypeName AS UnitPackage, pt.PackageTypeName AS OuterPackage, Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock, Barcode, TaxRate, UnitPrice, 
	RecommendedRetailPrice,	TypicalWeightPerUnit, MarketingComments, InternalComments, Photo, CustomFields, Tags, SearchDetails, sih.QuantityOnHand, sih.BinLocation, sih.LastStocktakeQuantity, sih.LastCostPrice, 
	sih.TargetStockLevel, sih.ReorderLevel
	FROM Warehouse.StockItems si
	LEFT OUTER JOIN Warehouse.StockItemHoldings sih
	ON si.StockItemID = sih.StockItemID
	LEFT OUTER JOIN Warehouse.PackageTypes pt
	ON si.UnitPackageID = pt.PackageTypeID
	LEFT OUTER JOIN (
					SELECT sisg.StockItemID, sg.StockGroupName FROM Warehouse.StockItemStockGroups sisg
					INNER JOIN Warehouse.StockGroups sg
					ON sisg.StockGroupID = sg.StockGroupID
				) AS stockgroup
	ON si.StockItemID = stockgroup.StockItemID
);