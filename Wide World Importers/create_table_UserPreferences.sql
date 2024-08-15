USE WideWorldImporters;
GO

CREATE TABLE Application.UserPreferences (
	PersonID INT PRIMARY KEY,
	theme VARCHAR(50),
	Date_format VARCHAR(20),
	timezone VARCHAR(20),
	favoritesOnDashboard VARCHAR(10),
	pagingType VARCHAR(20),
	pageLength INT
);
--SELECT * FROM Application.UserPreferences
INSERT INTO Application.UserPreferences (PersonID, theme, Date_format, timezone, favoritesonDashboard, pagingType, pageLength)
SELECT PersonID, JSON_VALUE(UserPreferences, '$.theme') AS theme, JSON_VALUE(UserPreferences, '$.dateFormat') AS Date_format, JSON_VALUE(UserPreferences, '$.timezone') AS timezone,
JSON_VALUE(UserPreferences, '$.favoritesOnDashboard') AS favoritesOnDashboard, JSON_VALUE(JSON_QUERY(UserPreferences, '$.table'), '$.pagingType') AS pagingType, JSON_VALUE(JSON_QUERY(UserPreferences, '$.table'), '$.pageLength') AS pageLength
FROM (
	SELECT PersonID, UserPreferences FROM Application.People
	WHERE UserPreferences IS NOT NULL
) AS xyz;