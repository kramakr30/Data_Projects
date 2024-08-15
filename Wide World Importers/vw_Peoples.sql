USE WideWorldImporters;
GO

--11. Create a view with all necessary details from People
CREATE VIEW Application.Peoples
AS
(
	SELECT p.PersonID, FullName, IsSystemUser, IsEmployee, IsSalesperson, PhoneNumber, FaxNumber, EmailAddress, Photo, OtherLanguages, usp.theme, usp.Date_format, usp.timezone, usp.favoritesOnDashboard,
	usp.pagingType, usp.pageLength, CONVERT(DATE, csfd.HireDate) AS HireDate, csfd.Title, csfd.PrimarySalesTerritory, csfd.CommissionRate, ValidFrom, ValidTo FROM Application.People p
	LEFT OUTER JOIN Application.UserPreferences usp
	ON p.PersonID = usp.PersonID
	LEFT OUTER JOIN Application.CustomFields csfd
	ON p.PersonID = csfd.PersonID
)