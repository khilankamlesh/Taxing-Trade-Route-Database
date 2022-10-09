/*
* File: Assignment2_SubmissionTemplate.sql
* 
* 1) Rename this file according to the instructions in the assignment statement.
* 2) Use this file to insert your solution.
*
*
* Author: Kamlesh, Khilan
* Student ID Number: 2307483
* Institutional mail prefix: kxk183
*/


/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/


/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
--\cd 'C:/Users/Khilan/Desktop/Full Stack Application Development/Assignment 2'
--\connect postgres;
DROP DATABASE IF EXISTS "SmokedTrout";
  -- In PostgreSQL, folders are identified with '/'


-- 1) Create a database called SmokedTrout.

CREATE DATABASE "SmokedTrout"
	WITH
	OWNER = fsad
	ENCODING = 'UTF8'
	CONNECTION LIMIT = -1;

-- 2) Connect to the database

\c SmokedTrout fsad




/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state

CREATE TYPE materialState AS ENUM ('Solid', 'Liquid', 'Gas');

-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.

CREATE TYPE materialComposition AS ENUM ('Fundamental', 'Composite');

-- 3) Create the table TradingRoute with the corresponding attributes.

CREATE TABLE TradingRoute (
	MonitoringKey SERIAL,		
	OperatingCompany varchar(50),
	FleetSize integer,
	LastYearRevenue real,
	PRIMARY KEY (MonitoringKey));

-- 4) Create the table Planet with the corresponding attributes.

CREATE TABLE Planet (
	PlanetID SERIAL,
	StarSystem varchar(50),
	Name varchar(50),
	Population integer,
	PRIMARY KEY (PlanetID));

-- 5) Create the table SpaceStation with the corresponding attributes.

CREATE TABLE SpaceStation (
	StationID SERIAL,
	PlanetID SERIAL,
	Name varchar(50),
	Longitude varchar(20),
	Latitude varchar(20),
	PRIMARY KEY (StationID));

-- 6) Create the parent table Product with the corresponding attributes.

CREATE TABLE Product (
	ProductID SERIAL,
	Name varchar(50),
	VolumePerTon real,
	ValuePerTon real,
	PRIMARY KEY (ProductID));

-- 7) Create the child table RawMaterial with the corresponding attributes.

CREATE TABLE RawMaterial (
	State materialState,
	FundamentalOrComposite materialComposition) INHERITS (Product);

-- 8) Create the child table ManufacturedGood. 

CREATE TABLE ManufacturedGood (
	) INHERITS (Product);

-- 9) Create the table MadeOf with the corresponding attributes.

CREATE TABLE MadeOf (
	ManufacturedGoodID integer) INHERITS (Product);

-- 10) Create the table Batch with the corresponding attributes.

CREATE TABLE Batch (
	BatchID SERIAL,
	ProductID SERIAL references Product(ProductID),
	ExtractionOrManufacturingDate date,
	OriginalFrom integer references Planet(PlanetID),
	PRIMARY KEY (BatchID));

-- 11) Create the table Sells with the corresponding attributes.

CREATE TABLE Sells (
	BatchID SERIAL references Batch(BatchID),
	StationID SERIAL references SpaceStation(StationID),
	PRIMARY KEY (BatchID, StationID));

-- 12)  Create the table Buys with the corresponding attributes.

CREATE TABLE Buys (
	BatchID SERIAL references Batch(BatchID),
	StationID SERIAL references SpaceStation(StationID),
	PRIMARY KEY (BatchID, StationID));

-- 13)  Create the table CallsAt with the corresponding attributes.

CREATE TABLE CallsAt (
	MonitoringKey SERIAL references TradingRoute(MonitoringKey),
	StationID SERIAL references SpaceStation(StationID),
	VisitOrder integer,
	PRIMARY KEY (MonitoringKey, StationID));

-- 14)  Create the table Distance with the corresponding attributes.

CREATE TABLE Distance (
	PlanetOrigin integer references Planet(PlanetID),
	PlanetDestination integer,
	AvgDistance real,
	PRIMARY KEY (PlanetOrigin, PlanetDestination));
	



/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.

CREATE TABLE Dummy (
	MonitoringKey SERIAL,
	FleetSize integer,
	OperatingCompany varchar(50),
	LastYearRevenue real NOT NULL);

\copy Dummy from './data/TradeRoutes.csv' with (FORMAT CSV, HEADER);

INSERT INTO TradingRoute (MonitoringKey, OperatingCompany, FleetSize, LastYearRevenue)
SELECT MonitoringKey, OperatingCompany, FleetSize, LastYearRevenue FROM Dummy;

DROP TABLE Dummy;

-- 3) Populate the table Planet with the data in the file Planets.csv.

CREATE TABLE Dummy (
	PlanetID SERIAL,
	StarSystem varchar(50),
	Planet varchar(50),
	Population_inMillions_ integer);

\copy Dummy from './data/Planets.csv' with (FORMAT CSV, HEADER);

INSERT INTO Planet (PlanetID, StarSystem, Name, Population)
SELECT PlanetID, StarSystem, Planet, Population_inMillions_ FROM Dummy;

DROP TABLE Dummy;

-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.

CREATE TABLE Dummy (
	StationID SERIAL,
	PlanetID SERIAL,
	SpaceStations varchar(50),
	Longitude varchar(20),
	Latitude varchar(20));

\copy Dummy from './data/SpaceStations.csv' with (FORMAT CSV, HEADER);

INSERT INTO SpaceStation (StationID, PlanetID, Name, Longitude, Latitude)
SELECT StationID, PlanetID, SpaceStations, Longitude, Latitude FROM Dummy;

DROP TABLE Dummy;

-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 

CREATE TABLE Dummy (
	ProductID SERIAL,
	Product varchar(50),
	Composite varchar(50),
	VolumePerTon real,
	ValuePerTon real,
	State materialState);

\copy Dummy from './data/Products_Raw.csv' with (FORMAT CSV, HEADER);

UPDATE Dummy
SET Composite = REPLACE(Composite, 'No', 'Fundamental');
UPDATE Dummy
SET Composite = REPLACE(Composite, 'Yes', 'Composite');

INSERT INTO Product (ProductID, Name, VolumePerTon, ValuePerTon)
SELECT ProductID, Product, VolumePerTon, ValuePerTon FROM Dummy;

ALTER TABLE Dummy
	ALTER COLUMN Composite TYPE materialComposition using Composite::materialComposition;

INSERT INTO RawMaterial (ProductID, Name, VolumePerTon, ValuePerTon, State, FundamentalOrComposite)
SELECT ProductID, Product, VolumePerTon, ValuePerTon, State, Composite FROM Dummy;

DROP TABLE Dummy;

-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.

CREATE TABLE Dummy (
	ProductID SERIAL,
	Product varchar(50),
	VolumePerTon real,
	ValuePerTon real);

\copy Dummy from './data/Products_Manufactured.csv' with (FORMAT CSV, HEADER);

INSERT INTO Product (ProductID, Name, VolumePerTon, ValuePerTon)
SELECT ProductID, Product, VolumePerTon, ValuePerTon FROM Dummy;

INSERT INTO ManufacturedGood (ProductID, Name, VolumePerTon, ValuePerTon)
SELECT ProductID, Product, VolumePerTon, ValuePerTon FROM Dummy;

DROP TABLE Dummy;

-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.

CREATE TABLE Dummy (
	ManufacturedGoodID SERIAL,
	ProductID SERIAL);

\copy Dummy from './data/MadeOf.csv' with (FORMAT CSV, HEADER);

INSERT INTO MadeOf (ManufacturedGoodID, ProductID)
SELECT ManufacturedGoodID, ProductID FROM Dummy;

DROP TABLE Dummy;

-- 8) Populate the table Batch with the data in the file Batches.csv.

CREATE TABLE Dummy (
	BatchID integer,
	ProductID SERIAL,
	ExtractionOrManufacturingDate date,
	OriginalFrom SERIAL);

\copy Dummy from './data/Batches.csv' with (FORMAT CSV, HEADER);

INSERT INTO Batch (BatchID, ProductID, ExtractionOrManufacturingDate, OriginalFrom)
SELECT BatchID, ProductID, ExtractionOrManufacturingDate, OriginalFrom FROM Dummy;

DROP TABLE Dummy;

-- 9) Populate the table Sells with the data in the file Sells.csv.

CREATE TABLE Dummy (
	BatchID integer,
	StationID SERIAL);

\copy Dummy from './data/Sells.csv' with (FORMAT CSV, HEADER);

INSERT INTO Sells (BatchID, StationID)
SELECT BatchID, StationID FROM Dummy;

DROP TABLE Dummy;

-- 10) Populate the table Buys with the data in the file Buys.csv.

CREATE TABLE Dummy (
	BatchID integer,
	StationID SERIAL);

\copy Dummy from './data/Buys.csv' with (FORMAT CSV, HEADER);

INSERT INTO Buys (BatchID, StationID)
SELECT BatchID, StationID FROM Dummy;

DROP TABLE Dummy;

-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.

CREATE TABLE Dummy (
	MonitoringKey integer,
	StationID SERIAL,
	VisitOrder SERIAL);

\copy Dummy from './data/CallsAt.csv' with (FORMAT CSV, HEADER);

INSERT INTO CallsAt (MonitoringKey, StationID, VisitOrder)
SELECT MonitoringKey, StationID, VisitOrder FROM Dummy;

DROP TABLE Dummy;

-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.

CREATE TABLE Dummy (
	PlanetOrigin SERIAL,
	PlanetDestination SERIAL,
	Distance real);

\copy Dummy from './data/PlanetDistances.csv' with (FORMAT CSV, HEADER);

INSERT INTO Distance (PlanetOrigin, PlanetDestination, AvgDistance)
SELECT PlanetOrigin, PlanetDestination, Distance FROM Dummy;

DROP TABLE Dummy;




/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute

ALTER TABLE TradingRoute 
ADD Taxes real;

-- 2) Set the derived attribute taxes as 12% of LastYearRevenue

UPDATE TradingRoute
SET Taxes = 0.12 * LastYearRevenue;

-- 3) Report the operating company and the sum of its taxes group by company.

SELECT OperatingCompany,SUM(Taxes) AS "Total Tax"
FROM TradingRoute
GROUP BY OperatingCompany;


-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.

CREATE TABLE RouteLength (
	TradingRoute integer,
	Length real,
	PRIMARY KEY (TradingRoute));

-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.

CREATE OR REPLACE VIEW EnrichedCallsAt AS
SELECT SpaceStation.PlanetID, SpaceStation.StationID, CallsAt.MonitoringKey, CallsAt.VisitOrder
FROM CallsAt
INNER JOIN SpaceStation 
	ON CallsAt.StationID = SpaceStation.StationID;

--SELECT * FROM EnrichedCallsAt; -- Testing

-- 3) Add the support to execute an anonymous code block as follows;

DO 
$$	
DECLARE
	routeDistance real := 0.0;
	hopPartialDistance real := 0.0;
	rRoute record;
	hRoute record;
	query text;
BEGIN
	FOR rRoute IN SELECT MonitoringKey FROM TradingRoute
	LOOP
		routeDistance := 0.0;
		query := 'CREATE OR REPLACE VIEW PortsOfCall AS '
					|| 'SELECT PlanetID, VisitOrder '
					|| 'FROM EnrichedCallsAt '
					|| 'WHERE MonitoringKey = ' || rRoute.MonitoringKey
					|| 'ORDER BY VisitOrder';
		EXECUTE query;
		
		CREATE OR REPLACE VIEW Hops AS
		SELECT PortsOfCall.PlanetID, PortsOfCall.VisitOrder, 
		LEAD(PortsOfCall.PlanetID, 1, PortsOfCall.PlanetID) OVER (ORDER BY PortsOfCall.VisitOrder)
		FROM PortsOfCall;
		
		FOR hRoute IN SELECT PlanetID, lead FROM Hops
		LOOP
			query := 'SELECT AvgDistance '
						|| 'FROM Distance '
						|| 'WHERE PlanetOrigin = ' || hRoute.PlanetID
						|| 'AND PlanetDestination = ' || hRoute.lead;
			EXECUTE query INTO hopPartialDistance;
			
			routeDistance := routeDistance + hopPartialDistance;
		END LOOP;
		
		INSERT INTO RouteLength
			VALUES (rRoute.MonitoringKey, routeDistance);
		
		DROP VIEW Hops;
		DROP VIEW PortsOfCall;
	END LOOP;

END;
$$;
	
SELECT * FROM RouteLength
WHERE Length = (
	SELECT MAX(Length)
	FROM RouteLength);

-- 4) Within the declare section, declare a variable of type real to store a route total distance.
--Done
-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.
--Done
-- 6) Within the declare section, declare a variable of type record to iterate over routes.
--Done
-- 7) Within the declare section, declare a variable of type record to iterate over hops.
--Done
-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.
--Done
-- 9) Within the main body section, loop over routes in TradingRoutes
--Done
-- 10) Within the loop over routes, get all visited planets (in order) by this trading route.
--Done
-- 11) Within the loop over routes, execute the dynamic view
--Done
-- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 
--Done
-- 13) Within the loop over routes, initialize the route total distance to 0.0.
--Done
-- 14) Within the loop over routes, create an inner loop over the hops
--Done
-- 15) Within the loop over hops, get the partial distances of the hop. 
--Done
-- 16)  Within the loop over hops, execute the dynamic view and store the outcome INTO the hop partial distance.
--Done
-- 17)  Within the loop over hops, accumulate the hop partial distance to the route total distance.
--Done
-- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).
--Done
-- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).
--Done
-- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).
--Done
-- 21)  Finally, just report the longest route in the dummy table RouteLength.
--Done