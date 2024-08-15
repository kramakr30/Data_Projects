USE WideWorldImporters;
GO

--8. Find employees based on langauge spoken
CREATE FUNCTION EmployeesfromLang (
	@languages VARCHAR(50)
)
RETURNS @result TABLE (
	PersonID INT,
	FullName VARCHAR(200),
	EmailAddress VARCHAR(100), 
	PhoneNumber VARCHAR(50),
	Languages VARCHAR(50)
)
AS 
BEGIN
	INSERT INTO @result
	SELECT PersonID, FullName, EmailAddress, PhoneNumber, value AS Languages FROM Application.People
	CROSS APPLY OPENJSON (OtherLanguages)
	WHERE EmailAddress LIKE '%wideworldimporters.com' AND value = @languages;

	RETURN;
END;