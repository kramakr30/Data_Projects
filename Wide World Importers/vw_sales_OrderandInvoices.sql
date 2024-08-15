USE WideWorldImporters;
GO

CREATE VIEW Sales.OrderandInvoices
AS (
	SELECT OrderLineID, od.OrderID, Invoices.InvoiceID, odl.StockItemID, odl.Description, odl.PackageTypeID, odl.Quantity, odl.UnitPrice, odl.TaxRate, Invoices.TaxAmount, Invoices.LineProfit, Invoices.ExtendedPrice, 
	PickedQuantity, odl.PickingCompletedWhen AS OrderLinePickingCompleted, od.CustomerID, SalespersonPersonID, PickedByPersonID, ContactPersonId, BackorderOrderID, OrderDate, InvoiceDate, ExpectedDeliveryDate, 
	IsUndersupplyBackordered, od.PickingCompletedWhen AS OrderPickingCompleted 
	FROM Sales.OrderLines odl
	LEFT OUTER JOIN Sales.Orders od
	ON odl.OrderID = od.OrderID
	LEFT OUTER JOIN (
	SELECT il.InvoiceLineID, il.InvoiceID, inv.CustomerID, il.StockItemID, il.Description, il.PackageTypeID, il.Quantity, il.UnitPrice, il.TaxRate, il.TaxAmount, il.LineProfit, il.ExtendedPrice, inv.BillToCustomerID, inv.OrderID, inv.InvoiceDate,
	inv.CustomerPurchaseOrderNumber FROM Sales.InvoiceLines il
	LEFT OUTER JOIN Sales.Invoices inv
	ON il.InvoiceID = inv.InvoiceID
	) AS Invoices
	ON od.OrderID = Invoices.OrderID
);