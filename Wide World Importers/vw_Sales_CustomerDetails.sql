USE WideWorldImporters;
GO

CREATE VIEW Sales.CustomerDetails
AS (
	SELECT CustomerID, CustomerName, BillToCustomerID, cc.CustomerCategoryName, bg.BuyingGroupName, pl.FullName AS PrimaryContact, pl.PhoneNumber AS PrimaryPhone, pl1.FullName AS SecondaryContact, pl1.PhoneNumber AS SecondaryPhone,
	DeliveryMethodId, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, cus.PhoneNumber, cus.FaxNumber, DeliveryRun, WebsiteURL,
	(DeliveryAddressLine1 + ' ' + DeliveryAddressLine2) AS DeliveryAddress, DeliveryPostalCode, (PostalAddressLine1 + ' ' + PostalAddressLine2) AS PostalAddress, PostalPostalCode FROM Sales.Customers cus
	LEFT OUTER JOIN Sales.BuyingGroups bg
	ON cus.BuyingGroupID = bg.BuyingGroupID
	LEFT OUTER JOIN Sales.CustomerCategories cc
	ON cus.CustomerCategoryID = cc.CustomerCategoryID
	LEFT OUTER JOIN Application.Peoples pl
	ON cus.PrimaryContactPersonID = pl.PersonID
	LEFT OUTER JOIN Application.People pl1
	ON cus.AlternateContactPersonID = pl1.PersonID
)