USE WideWorldImporters;
GO

--Create a function which shows employees based on HireDate
CREATE FUNCTION GetEmployeesfromHireDate (
	@HireStart DATE,
	@HireEnd DATE
)
RETURNS @ResultList TABLE (
	PersonID INT PRIMARY KEY, 
	FullName VARCHAR(100),
	PhoneNumber VARCHAR(50),
	EmailAddress VARCHAR(100),
	HireDate DATE,
	Title VARCHAR(50),
	PrimarySalesTerritory VARCHAR(20),
	CommissionRate FLOAT
)
AS
BEGIN
	IF (@HireStart = @HireEnd)
	BEGIN
		INSERT INTO @ResultList
		SELECT PersonID, FullName, PhoneNumber, EmailAddress, HireDate, Title, PrimarySalesTerritory, CommissionRate
		FROM Application.Peoples
		WHERE HireDate = @HireStart;
	END
	ELSE
	BEGIN
		INSERT INTO @ResultList
		SELECT PersonID, FullName, PhoneNumber, EmailAddress, HireDate, Title, PrimarySalesTerritory, CommissionRate
		FROM Application.Peoples
		WHERE HireDate BETWEEN @HireStart AND @HireEnd;
	END
	RETURN
END;