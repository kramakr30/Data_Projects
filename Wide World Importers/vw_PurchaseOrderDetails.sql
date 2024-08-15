USE WideWorldImporters;
GO

CREATE VIEW Purchasing.PurchaseOrderDetails
AS (
	SELECT PurchaseOrderLineID, pol.PurchaseOrderID, StockItemID, OrderedOuters, Description, ReceivedOuters, pt.PackageTypeName, ExpectedUnitPricePerOuter, LastReceiptDate, IsOrderLineFinalized, SupplierID,
	OrderDate, DeliveryMethodID, ContactPersonID, ExpectedDeliveryDate, SupplierReference, IsOrderFinalized
	FROM Purchasing.PurchaseOrderLines pol
	LEFT OUTER JOIN Purchasing.PurchaseOrders po
	ON pol.PurchaseOrderID = po.PurchaseOrderID
	LEFT OUTER JOIN Warehouse.PackageTypes pt
	ON pol.PackageTypeID = pt.PackageTypeID
);