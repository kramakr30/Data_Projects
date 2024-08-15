USE WideWorldImporters;
GO

--Create a function which will generate employee details based on full name

CREATE FUNCTION GetEmployeeDetails (
	@test_name VARCHAR(50)
)
RETURNS @details TABLE (
	PersonID INT,
	FullName VARCHAR(50),
	IsEmployee INT,
	IsSalesperson INT,
	PhoneNumber VARCHAR(30),
	FaxNumber VARCHAR(30),
	EmailAddress VARCHAR(100),
	OtherLanguages NVARCHAR(MAX),
	HireDate DATE,
	Title VARCHAR(20),
	PrimarySalesTerritory VARCHAR(20),
	CommissionRate FLOAT
)
AS
BEGIN
	INSERT INTO @details
	SELECT PersonID, FullName, IsEmployee, IsSalesperson, PhoneNumber, FaxNumber, EmailAddress, OtherLanguages, HireDate, Title, PrimarySalesTerritory, CommissionRate FROM Application.Peoples
	WHERE FullName = @test_name
	RETURN
END;