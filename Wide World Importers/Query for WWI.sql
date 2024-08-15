USE WideWorldImporters;
GO

--List the employees of wide world importers and get the number of languages spoken
SELECT DISTINCT (PersonID) , FullName, COUNT(lang) OVER (PARTITION BY PersonID) AS NumberofLangs
FROM (
	SELECT PersonID, FullName, value AS lang FROM Application.People
	CROSS APPLY OPENJSON (OtherLanguages)
	WHERE EmailAddress LIKE '%wideworldimporters.com'
) AS lang_t
ORDER BY NumberofLangs DESC;

--Find employees based on langauge spoken
--Refer function EmployeesfromLang
SELECT * FROM EmployeesfromLang('Polish');

--List the distinct languages sopken by employees
SELECT DISTINCT (value) AS Languages FROM Application.People
CROSS APPLY OPENJSON (OtherLanguages)
ORDER BY Languages ASC;

--Create a tables with all people details
SELECT * FROM Application.UserPreferences
SELECT * FROM Application.CustomFields

--Create a view with all necessary details from People
SELECT * FROM Application.Peoples;

--Create a function which shows employees based on HireDate
SELECT * FROM GetEmployeesfromHireDate('2009-01-01', '2009-12-31');

--Create a function which will generate employee details based on full name
SELECT * FROM GetEmployeeDetails('Kayla Woodcock');

--Create a view which purchase orders and order line data
SELECT * FROM Purchasing.PurchaseOrderDetails;

--Create a view for warehouse details
SELECT * FROM Warehouse.StockDetails;

--Create a view which has customer details
SELECT * FROM Sales.CustomerDetails;

--Create a view which has sales order & invoice details
SELECT * FROM Sales.OrderandInvoices

--How many customers belong to each customer category?
SELECT CustomerCategoryName, COUNT(CustomerID) AS NumberofCustomers FROM Sales.CustomerDetails
GROUP BY CustomerCategoryName
ORDER BY NumberofCustomers DESC;

--What are the top 10 cities with the highest number of customers?
SELECT TOP 10 CityName, COUNT(CustomerID) AS NumberofCustomers FROM Sales.CustomerDetails
INNER JOIN Application.Cities
ON CustomerDetails.PostalCityID = Cities.CityID
GROUP BY CityName
ORDER BY NumberofCustomers DESC;

--What is the distribution of customers by region or city?
SELECT CityName, SalesTerritory, COUNT(CustomerID) AS NumberofCustomers FROM Sales.CustomerDetails
INNER JOIN Application.Locations
ON CustomerDetails.PostalCityID = Locations.CityID
GROUP BY CityName, SalesTerritory
ORDER BY NumberofCustomers DESC;

--What are the total product figures for the past year, broken down by month?
SELECT OrderDate, DATEPART(YEAR, CAST(OrderDate AS date)) AS Year, DATEPART(MONTH, CAST(OrderDate AS date)) AS Month, SUM((Quantity * UnitPrice)) AS ProductCost, 
SUM((UnitPrice * TaxRate) / 100 ) AS Tax, SUM((Quantity * UnitPrice) + ((UnitPrice * TaxRate) / 100 )) AS TotalProductCost
FROM Sales.OrderandInvoices
GROUP BY OrderDate
ORDER BY OrderDate DESC;

--Which salespersons have the highest sales figures?
SELECT FullName, SUM((Quantity * UnitPrice))AS TotalCost, SUM(Taxamount) AS TotalTax, SUM(ExtendedPrice) AS TotalRevenue, SUM(LineProfit) AS TotalProfit FROM Sales.OrderandInvoices
INNER JOIN Application.Peoples
ON OrderandInvoices.SalespersonPersonID = Peoples.PersonID
GROUP BY FullName
ORDER BY TotalRevenue DESC;

--What are the top-selling products by revenue?
SELECT wsd.StockItemName,
CASE
	WHEN wsd.StockGroupName IS NOT NULL THEN wsd.StockGroupName
	ELSE 'Unknown'
END AS StockGroupName, COUNT(OrderID) AS NumberofOrders, SUM(ExtendedPrice) AS TotalSales
FROM Sales.OrderandInvoices oai
INNER JOIN (SELECT * FROM Warehouse.StockDetails) AS wsd
ON oai.StockItemID = wsd.StockItemID
GROUP BY wsd.StockItemName, wsd.StockGroupName
ORDER BY TotalSales DESC;

--How many orders are placed each day/week/month?
-- Day basis
SELECT DATEPART(DAY, OrderDate) AS OrderDay, SUM(NumberofOrders) AS TotalOrders
FROM (
	SELECT OrderDate, COUNT(OrderID) AS NumberofOrders FROM Sales.Orders
	GROUP BY OrderDate
) AS ODdata
GROUP BY DATEPART(DAY, OrderDate)
ORDER BY OrderDay ASC;

--Week basis
SELECT DATEPART(WEEK, OrderDate) AS OrderWeek, SUM(NumberofOrders) AS TotalOrders
FROM (
	SELECT OrderDate, COUNT(OrderID) AS NumberofOrders FROM Sales.Orders
	GROUP BY OrderDate
) AS ODdata
GROUP BY DATEPART(WEEK, OrderDate)
ORDER BY OrderWeek ASC;

--Month basis
SELECT DATEPART(MONTH, OrderDate) AS OrderMonth, SUM(NumberofOrders) AS TotalOrders
FROM (
	SELECT OrderDate, COUNT(OrderID) AS NumberofOrders FROM Sales.Orders
	GROUP BY OrderDate
) AS ODdata
GROUP BY DATEPART(MONTH, OrderDate)
ORDER BY OrderMonth ASC;

--What is the average order value?
SELECT AVG(Quantity * UnitPrice) AS AverageValue FROM Sales.OrderandInvoices

--What are the total sales figures for each region or city?
SELECT CityName, StateProvincename, SalesTerritory, SUM(TransactionAmount) AS TotalSales FROM Sales.CustomerTransactions ct
LEFT OUTER JOIN (
SELECT CustomerID, CustomerName, PostalCityID, CityName, StateProvinceName, SalesTerritory FROM Sales.CustomerDetails cd
LEFT OUTER JOIN Application.Locations loc
ON cd.PostalCityID = loc.CityID
) AS region
ON ct.CustomerID = region.CustomerID
GROUP BY CityName, StateProvincename, SalesTerritory
ORDER BY TotalSales DESC;

--What is the current inventory level of each product?
SELECT si.StockItemName, sih.QuantityOnHand, sih.LastStocktakeQuantity, (QuantityOnHand - LastStocktakeQuantity) AS Differen FROM Warehouse.StockItemHoldings sih
LEFT OUTER JOIN Warehouse.StockItems si
ON sih.StockItemID = si.StockItemID
ORDER BY Differen DESC;

--Which products are low in stock and need replenishment?
SELECT si.StockItemName, sih.QuantityOnHand, sih.LastStocktakeQuantity, ((QuantityOnHand + LastStocktakeQuantity)/2) AS AverageQuantity FROM Warehouse.StockItemHoldings sih
LEFT OUTER JOIN Warehouse.StockItems si
ON sih.StockItemID = si.StockItemID
WHERE QuantityOnHand <= ((QuantityOnHand + LastStocktakeQuantity)/2)
GROUP BY si.StockItemName, sih.QuantityOnHand, sih.LastStocktakeQuantity
ORDER BY AverageQuantity ASC;

--What is the product order trend ?
SELECT oai.OrderDate, si.StockItemID, si.StockItemName, COUNT(oai.OrderLineID) AS NumberofOrders FROM Sales.OrderandInvoices oai
LEFT OUTER JOIN Warehouse.StockItems si
ON oai.StockItemID = si.StockItemID
GROUP BY oai.OrderDate, si.StockItemID, si.StockItemName
ORDER BY OrderDate DESC;

--What is the total revenue and profit for the past year?
SELECT *, LAG(TotalRevenue) OVER (ORDER BY OrderYear) AS PreviousYear, ((TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY OrderYear))/LAG(TotalRevenue) OVER (ORDER BY OrderYear)) * 100 AS YoY
FROM (
	SELECT DATEPART(year, OrderDate) AS OrderYear, SUM(ExtendedPrice) AS TotalRevenue, SUM(LineProfit) AS TotalProfit FROM Sales.OrderandInvoices
	GROUP BY DATEPART(year, OrderDate)
) AS SalesData;

--What are the profit margins for each product category?
SELECT sd.StockGroupName AS ProductCategory, SUM(ExtendedPrice) AS TotalRevenue, SUM(LineProfit) AS TotalProfit, ROUND((SUM(LineProfit) / SUM(ExtendedPrice)), 5) * 100 AS ProfitMargin FROM Sales.OrderandInvoices oai
LEFT OUTER JOIN Warehouse.StockDetails sd
ON oai.StockItemID = sd.StockItemID
GROUP BY sd.StockGroupName
ORDER BY ProfitMargin DESC;

--How do revenue and profit compare across different regions?
SELECT SalesTerritory, CityName, SUM(ExtendedPrice) AS TotalRevenue, SUm(LineProfit) AS TotalProfit FROM Sales.OrderandInvoices oai
LEFT OUTER JOIN (SELECT cd.CustomerID, cd.PostalCityID, loc.CityName, loc.SalesTerritory FROM Sales.CustomerDetails cd
				 LEFT OUTER JOIN Application.Locations loc
				 ON cd.PostalCityID = loc.CityID
				 ) AS Loca
ON oai.CustomerID = Loca.CustomerID
GROUP BY SalesTerritory, CityName
ORDER BY TotalProfit DESC;

--What is the average order processing time?
SELECT AVG(DATEDIFF(day, OrderDate, ExpectedDeliveryDate)) AS TimeTaken FROM Sales.Orders;

--How many suppliers are there for each product category?
SELECT sd.StockGroupName, sp.SupplierName, sp.SupplierCategoryName, COUNT(sd.StockItemID) AS NumberofItems FROM Warehouse.StockDetails sd
LEFT OUTER JOIN Website.Suppliers sp
ON sd.SupplierID = sp.SupplierID
GROUP BY sd.StockGroupName, sp.SupplierName, sp.SupplierCategoryName
ORDER BY NumberofItems DESC;

-- What is the average vehicle temprature ?
SELECT VehicleRegistration, ChillerSensorNumber, AVG(Temperature) AS AverageTemp FROM Website.VehicleTemperatures
GROUP BY VehicleRegistration, ChillerSensorNumber
ORDER BY AverageTemp DESC;
