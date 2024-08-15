USE WideWorldImporters;
GO

CREATE VIEW Application.Locations
AS (
	SELECT CityID, CityName, cy.LatestRecordedPopulation AS CityPopulation, sp.StateProvinceCode, StateProvinceName, SalesTerritory, sp.LatestRecordedPopulation AS StatePopulation, ct.CountryID, CountryName,
	FormalName,	ct.LatestRecordedPopulation AS CountryPopulation, Continent, Region, Subregion FROM Application.Cities cy
	FULL OUTER JOIN Application.StateProvinces sp
	ON cy.StateProvinceID = sp.StateProvinceID
	FULL OUTER JOIN Application.Countries ct
	ON sp.CountryID = ct.CountryID
)