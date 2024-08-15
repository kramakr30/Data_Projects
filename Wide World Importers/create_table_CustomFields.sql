USE WideWorldImporters;
GO

CREATE TABLE Application.CustomFields (
	PersonID INT PRIMARY KEY,
	HireDate DATETIME,
	Title VARCHAR(50),
	PrimarySalesTerritory VARCHAR(20),
	CommissionRate FLOAT
);
--SELECT * FROM Application.CustomFields
INSERT INTO Application.CustomFields (PersonID, HireDate, Title, PrimarySalesTerritory, CommissionRate)
SELECT PersonID, JSON_VALUE(CustomFields, '$.HireDate') AS HireDate, JSON_VALUE(CustomFields, '$.Title') AS Title,
JSON_VALUE(CustomFields, '$.PrimarySalesTerritory') AS PrimarySalesTerritory, JSON_VALUE(CustomFields, '$.CommissionRate') AS CommissionRate
FROM (
	SELECT PersonID, CustomFields FROM application.people
	WHERE CustomFields IS NOT NULL
) cstfds;