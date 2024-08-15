/* This query is an exercise file for the Norhtwind database. It will have a questions and the query to match the results.*/

USE NorthWind;
GO

-- 1. Which shippers do we have?
SELECT CompanyName FROM Shippers;

--2. Return only category name and it's description
SELECT CategoryName, Description FROM dbo.Categories;

--3. List all the Sales representatives
SELECT CONCAT(TitleOfCourtesy, ' ', FirstName, ' ', LastName) AS FullName, FirstName, LastName, CAST(HireDate AS date) AS HireDate
FROM dbo.Employees
WHERE Title = 'Sales Representative';

--4. List all Sales reps from USA
SELECT CONCAT(TitleOfCourtesy, ' ', FirstName, ' ', LastName) AS FullName, FirstName, LastName, CAST(HireDate AS date) AS HireDate
FROM dbo.Employees
WHERE Title = 'Sales Representative' AND Country = 'USA';

--5. Orders placed by a specific employee. In this case employee id is 5
SELECT OrderID, CAST(OrderDate AS date) AS OrderDate, CAST(OrderDate AS datetime) AS OrderDate2 FROM dbo.Orders
WHERE EmployeeID = 5;

--6. Get Supplier data who are not Marketing Manager
SELECT SupplierID, ContactName, ContactTitle FROM dbo.Suppliers
WHERE ContactTitle <> 'Marketing Manager';

--7. Products which have a specific keyword in the name of the product. In this case keyword is 'queso'.
SELECT ProductID, ProductName FROM dbo.Products
WHERE ProductName LIKE '%queso%';

--8. Get a list of orders being delivered to one or more countries. In this case, it is France & Belgium
-- Query using IN function
SELECT OrderID, CustomerID, ShipCountry FROM dbo.Orders
WHERE ShipCountry IN ('France', 'Belgium');

-- Query using OR function
SELECT OrderID, CustomerID, ShipCountry FROM dbo.Orders
WHERE ShipCountry = 'France' OR ShipCountry = 'Belgium';

--9. Get a list of orders being delivered to one or more contients. In this case, it is Latin America
SELECT OrderID, CustomerID, ShipCountry FROM dbo.Orders
WHERE ShipCountry IN ('Brazil', 'Mexico', 'Argentina', 'Venezuela');

--10. Get a list of all employees in descending order of age.
SELECT FirstName, LastName, Title, CAST(BirthDate AS date) AS BirthDate, DATEDIFF(year, BirthDate, GETDATE()) AS age_of_employee FROM dbo.Employees
ORDER BY age_of_employee DESC;

--11. Get a list of all employees and order them by date of birth
SELECT FirstName, LastName, Title, CAST(BirthDate AS date) AS BirthDate, DATEDIFF(year, BirthDate, GETDATE()) AS age_of_employee FROM dbo.Employees
ORDER BY BirthDate DESC;

--12. Employee full name
SELECT CONCAT(FirstName, ' ', LastName) AS FullName, FirstName, LastName
FROM dbo.Employees

--13. Get order detail amount per line item.
SELECT OrderID, ProductID, UnitPrice, Quantity, (UnitPrice*Quantity) AS TotalPrice FROM dbo.[Order Details]
ORDER BY OrderID, ProductID ASC;

--14. Get the total customers
SELECT COUNT(CustomerID) AS TotalCustomers FROM dbo.Customers;

--15. Get the first order, last order
SELECT CAST(MIN(OrderDate) AS date) AS OldestOrderDate, CAST(MAX(OrderDate) AS date) AS LatestOrderDate FROM dbo.Orders;

--16. Get data of countries where Northwind has customers
SELECT DISTINCT(Country) FROM dbo.Customers

--17. Show a list of all the different values in the Customers table for ContactTitles. Also include a count for each ContactTile
SELECT ContactTitle, COUNT(CustomerID) AS employee_count FROM dbo.Customers
GROUP BY ContactTitle
ORDER BY employee_count ASC;

--18. Show, for each product, the associated Supplier. Show the ProductID, ProductName, and the CompanyName of the Supplier. Sort by ProductID.
SELECT ProductID, ProductName, s.CompanyName FROM dbo.Products p
INNER JOIN dbo.Suppliers s
ON p.SupplierID = s.SupplierID

--19. Show a list of orders that were made, shipper that was used. Give order id, order date, company name. sort by order id. Order id < 10300
SELECT OrderID, CAST(OrderDate AS date) AS OrderDate, sp.CompanyName FROM dbo.Orders o
INNER JOIN dbo.Shippers sp
ON o.ShipVia = sp.ShipperID
WHERE OrderID < 10300
ORDER BY OrderID DESC;

--20. Get the categories and total product in each category
SELECT CategoryName, COUNT(ProductID) AS TotalProducts FROM (
	SELECT p.ProductID, c.CategoryName FROM dbo.Products p
	INNER JOIN dbo.Categories c
	ON p.CategoryID = c.CategoryID
) AS sbq
GROUP BY CategoryName
ORDER BY TotalProducts DESC;

--21. Show the total number of customers per Country & City
SELECT Country, City, COUNT(CustomerID) AS TotalCustomers FROM dbo.Customers
GROUP BY Country, City
ORDER BY TotalCustomers DESC;

/*22. What products do we have in our inventory that should be reordered? For now, just use the fields UnitsInStock and ReorderLevel, where UnitsInStock is less than the ReorderLevel, ignoring the fields UnitsOnOrder and 
Discontinued. Order the results by ProductID.*/
SELECT ProductID, ProductName, UnitsInStock, ReorderLevel FROM dbo.Products
WHERE UnitsInStock < ReorderLevel
ORDER BY ProductID;

--23 Continuation of 22. Producst that need reordering with the following : UnitsInStock plus UnitsOnOrder are less than or equal to Reorder level & it is nor discontinued
SELECT ProductID, ProductName, UnitsInStock, UnitsOnOrder, ReorderLevel FROM dbo.Products
WHERE Discontinued = 0 AND (UnitsInStock+UnitsOnOrder) <= ReorderLevel
ORDER BY ProductID;

/*24. A salesperson for Northwind is going on a business trip to visit customers, and would like to see a list of all customers, sorted by region, alphabetically. However, he wants the customers with no region 
(null in the Region field) to be at the end, instead of at the top, where you’d normally find the null values. Within the same region, companies should be sorted by CustomerID.*/

SELECT *, RANK() OVER (PARTITION BY Region ORDER BY Region ASC) FROM (
SELECT CustomerID, CompanyName, ContactName, ContactTitle, CONCAT(Address, ' ', City) AS Address, Phone,
CASE
	WHEN Region IS NULL THEN 'Unknown'
	ELSE Region
END AS Region FROM dbo.Customers
) AS temptbl

--25. Return the three ship countries with the highest average freight overall, in descending order by average freight.
SELECT TOP 3 ShipCountry, AVG(Freight) AS avgcharge FROM dbo.Orders
GROUP BY ShipCountry
ORDER BY avgcharge DESC;

--26. We're continuing on the question above on high freight charges. Now, instead of using all the orders we have, we only want to see orders from the year 2015
SELECT TOP 5 ShipCountry, AVG(Freight) AS avgcharge FROM dbo.Orders
WHERE CONVERT(DATE,OrderDate) LIKE '1996%'
GROUP BY ShipCountry
ORDER BY avgcharge DESC;

/*28. We're continuing to work on high freight charges. We now want to get the three ship countries with the highest average freight charges.
But instead of filtering for a particular year, we want to use the last 12 months of order data, using as the end date the last OrderDate in Orders.*/

-- Consider current date as 10-05-1998
SELECT TOP 3 ShipCountry, AVG(Freight) AS avgcharge
FROM (	SELECT *, DATEDIFF(month, CONVERT(DATE, OrderDate), '1998-05-10') AS Age_in_months
		FROM dbo.Orders
	) AS order_data
WHERE Age_in_months <= 12
GROUP BY ShipCountry
ORDER BY avgcharge DESC;

--29. Inventory List
WITH cte_inventory (OrderID, QTY, PrdName, EmpID, EmpLastName) 
AS (
	SELECT od.OrderID, od.Quantity, p.ProductName, e.EmployeeID, e.LastName FROM dbo.[Order Details] od
	INNER JOIN dbo.Orders o
	ON od.OrderID = o.OrderID
	INNER JOIN dbo.Products p
	ON od.ProductID = p.ProductID
	INNER JOIN dbo.Employees e
	ON o.EmployeeID = e.EmployeeID
)
SELECT * FROM cte_inventory;

--30. Get a list of customers who never placed an order
SELECT c.CustomerID, orderlist.CountofOrders FROM dbo.Customers c
LEFT JOIN ( SELECT CustomerID, COUNT(OrderID) AS CountofOrders FROM dbo.Orders
			GROUP BY CustomerID
		) AS orderlist
ON c.CustomerID = orderlist.CustomerID
WHERE CountofOrders IS NULL;

/*31. Customers with no orders for EmployeeID : One employee (Margaret Peacock, EmployeeID 4) has placed the most orders. However, there are some customers who've never placed an order with her. Show only those customers 
who have never placed an order with her.*/
WITH cte_all
AS (
	SELECT DISTINCT o.CustomerID, COUNT(e.EmployeeID) AS CountAll
	FROM (  SELECT DISTINCT o.CustomerID, e.EmployeeID FROM dbo.Orders o
			INNER JOIN dbo.Employees e
			ON o.EmployeeID = e.EmployeeID
		) AS o
	INNER JOIN dbo.Employees e
	ON o.EmployeeID = e.EmployeeID
	GROUP BY CustomerID
),
cte_without4
AS (
	SELECT o.CustomerID, COUNT(e.EmployeeID) AS CountWT4 
	FROM (  SELECT DISTINCT o.CustomerID, e.EmployeeID FROM dbo.Orders o
			INNER JOIN dbo.Employees e
			ON o.EmployeeID = e.EmployeeID
		) AS o
	INNER JOIN dbo.Employees e
	ON o.EmployeeID = e.EmployeeID AND e.EmployeeID <> 4
	GROUP BY CustomerID
),
cte_final
AS (
	SELECT cte_all.*, cte_without4.CountWT4,
	CASE
		WHEN cte_all.CountAll <> cte_without4.CountWT4 THEN 'Uneven'
		ELSE 'even'
	END AS compare
	FROM cte_all
	INNER JOIN cte_without4
	ON cte_all.CustomerID = cte_without4.CustomerID
)
SELECT CustomerID FROM cte_final
WHERE compare = 'even';

/*We want to send all of our high-value customers a special VIP gift. We're defining high-value customers as those who've made at least 1 order with a total value (not including the discount) equal to $10,000 or more. 
We only want to consider orders made in the year 1997.*/
WITH cte_highval
AS (
	SELECT *, (UnitPrice*Quantity) AS SalesAmount,
	CASE
		WHEN Discount <> 0 THEN ((UnitPrice - (UnitPrice*Discount))*Quantity)
		ELSE (UnitPrice*Quantity)
	END AS Discount_SalesAmount
	FROM dbo.[Order Details]
)
SELECT ch.OrderID, ch.SalesAmount, ch.Discount_SalesAmount, o.CustomerID, CONVERT(DATE,o.OrderDate) AS OrderDate FROM cte_highval ch
INNER JOIN dbo.Orders o
ON ch.OrderID = o.OrderID
WHERE ch.SalesAmount >= 10000 AND CONVERT(DATE,o.OrderDate) LIKE '1997%'
ORDER BY ch.SalesAmount DESC;

/*32. Send all high value customers a special VIp gift. High value customers are those who have made at least 1 order with a total value equal to 10,000 or more excluding the discount. Only consider orders in a specific year*/
WITH cte_highvalue
AS (
	SELECT od.OrderID, orderinfo.CustomerID, orderinfo.OrderDate, orderinfo.CompanyName, (od.UnitPrice * od.Quantity) AS SaleAmount FROM dbo.[Order Details] od
	LEFT OUTER JOIN (SELECT o.OrderID, o.CustomerID, CONVERT(date,o.OrderDate, 103) AS OrderDate,c.CompanyName FROM dbo.Orders o
	LEFT OUTER JOIN dbo.Customers c
	ON o.CustomerID = c.CustomerID) AS orderinfo
	ON od.OrderID = orderinfo.OrderID
	)
SELECT OrderID, CustomerID, CompanyName, SUM(SaleAmount) AS TotalSales FROM cte_highvalue
WHERE OrderDate LIKE '1998%'
GROUP BY OrderID, CustomerID, CompanyName
HAVING SUM(SaleAmount) >= 10000
ORDER BY TotalSales DESC;

/*33. Send all high value customers a special VIp gift. High value customers are those who have made orders with a total value equal to 15,000 or more excluding the discount. Only consider orders in a specific year*/
WITH cte_highvalue_totalorder
AS (
	SELECT od.OrderID, orderinfo.CustomerID, orderinfo.OrderDate, orderinfo.CompanyName, (od.UnitPrice * od.Quantity) AS SaleAmount FROM dbo.[Order Details] od
	LEFT OUTER JOIN (SELECT o.OrderID, o.CustomerID, CONVERT(date,o.OrderDate, 103) AS OrderDate,c.CompanyName FROM dbo.Orders o
	LEFT OUTER JOIN dbo.Customers c
	ON o.CustomerID = c.CustomerID) AS orderinfo
	ON od.OrderID = orderinfo.OrderID
	)
SELECT CustomerID, CompanyName, SUM(SaleAmount) AS TotalSales FROM cte_highvalue_totalorder
WHERE OrderDate LIKE '1998%'
GROUP BY CustomerID, CompanyName
HAVING SUM(SaleAmount) >= 15000
ORDER BY TotalSales DESC;

/*34. Send all high value customers a special VIp gift. High value customers are those who have made orders with a total value equal to 15,000 or more including the discount. Only consider orders in a specific year*/
WITH cte_dis_highvalue
AS (
	SELECT od.OrderID, orderinfo.CustomerID, orderinfo.OrderDate, orderinfo.CompanyName, (od.UnitPrice * od.Quantity) AS SaleAmount,
	CASE
		WHEN od.Discount = 0 THEN (od.UnitPrice * od.Quantity)
		ELSE ((od.UnitPrice * od.Discount) * od.Quantity)
	END AS DiscountSales
	FROM dbo.[Order Details] od
	LEFT OUTER JOIN (SELECT o.OrderID, o.CustomerID, CONVERT(date,o.OrderDate, 103) AS OrderDate,c.CompanyName FROM dbo.Orders o
	LEFT OUTER JOIN dbo.Customers c
	ON o.CustomerID = c.CustomerID) AS orderinfo
	ON od.OrderID = orderinfo.OrderID
	)
SELECT CustomerID, CompanyName, ROUND(SUM(DiscountSales),2) AS TotalSales FROM cte_dis_highvalue
WHERE OrderDate LIKE '1998%'
GROUP BY CustomerID, CompanyName
HAVING SUM(SaleAmount) >= 10000
ORDER BY TotalSales DESC;

-- 35. Show all orders made on the last day of the month
SELECT OrderID, CustomerID, EmployeeID, OrderDate FROM dbo.Orders
WHERE DAY(OrderDate) IN (31, 30) OR (MONTH(OrderDate) = 2 AND DAY(OrderDate) IN (28))
ORDER BY EmployeeID, OrderID;

/*36. The Northwind mobile app developers are testing an app that customers will use to show orders. In order to make sure that even the largest orders will show up correctly on the app, they'd like some samples of orders 
that have lots of individual line items. Show the 10 orders with the most line items, in order of total line items*/
SELECT TOP 10 * FROM (	SELECT OrderID, COUNT(ProductID) AS ItemsOrdered FROM dbo.[Order Details]
						GROUP BY OrderID
						) AS OrderCount
ORDER BY ItemsOrdered DESC;

/*37. The Northwind mobile app developers would now like to just get a random assortment of orders for beta testing on their app. Show a random set of 2% of all orders*/
--REVIEW THIS QUERY

/*38. Janet Leverling, one of the salespeople, has come to you with a request. She thinks that she accidentally doubleentered a line item on an order, with a 
different ProductID, but the same quantity. She remembers that the quantity was 60 or more. Show all the OrderIDs with line items that match this, in order of 
OrderID*/

SELECT OrderID, ProductID, Quantity, COUNT(ProductID) OVER (ORDER BY OrderID ASC) AS fil FROM dbo.[Order Details]
WHERE Quantity >= 60
ORDER BY Quantity, OrderID ASC