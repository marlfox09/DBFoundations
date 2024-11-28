--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-11-20,Jonathan Pruiett,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_JPruiett')
	 Begin 
	  Alter Database [Assignment06DB_JPruiett] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_JPruiett;
	 End
	Create Database Assignment06DB_JPruiett;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_JPruiett;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!


go
CREATE 
VIEW [vCategories Table] AS
SELECT CategoryID, CategoryName
FROM Categories;

GO

CREATE 
VIEW [vProducts Table] AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM Products;

GO
CREATE 

VIEW [vEmployees Table] AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM Employees;

GO
CREATE 
VIEW [vInventories Table] AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
FROM Inventories;
GO







-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

USE Northwind;
GO
DENY SELECT ON Inventories TO PUBLIC;
DENY SELECT ON Employees TO PUBLIC;
DENY SELECT ON Products TO PUBLIC;
DENY SELECT ON Categories TO PUBLIC;
GO
GRANT SELECT ON [vInventories Table] TO PUBLIC;
GRANT SELECT ON [vEmployees Table] TO PUBLIC;
GRANT SELECT ON [vProducts Table] TO PUBLIC;
GRANT SELECT ON [vCategories Table] TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE 
VIEW [vCategory and Products] AS
SELECT
Categories.CategoryName, Products.ProductName, Products.UnitPrice
From Categories
Join Products
On Categories.CategoryID = Products.CategoryID
GO
SELECT 
    CategoryName, 
    ProductName, 
    UnitPrice
FROM [vCategory_Products]
ORDER BY CategoryName, ProductName;

GO



-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!



CREATE --- Drop
VIEW [VProducts and Inventory]
AS
SELECT Products.ProductName, Inventories.[Count], Inventories.InventoryDate
FROM Products
Join Inventories
ON Products.ProductID = Inventories.ProductID;

GO

Select ProductName, [Count], InventoryDate
From [VProducts and Inventory]
ORDER BY ProductName, InventoryDate, [Count];
GO


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth


Create
VIEW [vInventory Dates by Employee]
AS
Select Inventories.InventoryDate,  [EmployeeName] = Employees.EmployeeFirstName + ' '+ Employees.EmployeeLastName
From Inventories
Join Employees
On Inventories.EmployeeID = Employees.EmployeeID;
Go
Select DISTINCT InventoryDate, EmployeeName
From [vInventory Dates by Employee]
Order By InventoryDate;
GO



-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!


CREATE
VIEW [vCategories and Products and Inventory]
AS
SELECT Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count]
FROM Categories
Join Products
ON Categories.CategoryID = Products.CategoryID
Join Inventories
ON  Products.ProductID = Inventories.ProductID;
GO

Select CategoryName, ProductName, InventoryDate, [Count]
From [vCategories and Products and Inventory]
ORDER BY CategoryName, ProductName, InventoryDate, [Count];
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE
VIEW [vCategories and Products and Inventory and Employees]
AS
SELECT Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count],  [EmployeeName] = Employees.EmployeeFirstName + ' '+ Employees.EmployeeLastName
FROM Categories
Join Products
ON Categories.CategoryID = Products.CategoryID
Join Inventories
ON  Products.ProductID = Inventories.ProductID
Join Employees
On Inventories.EmployeeID = Employees.EmployeeID;
GO

Select CategoryName, ProductName, InventoryDate, [Count], EmployeeName
From [vCategories and Products and Inventory and Employees]
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 


Select CategoryName, ProductName, InventoryDate, [Count], EmployeeName
From [vCategories and Products and Inventory and Employees]
WHERE ProductName IN ('Chai', 'Chang')
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Select [EmployeeName] = E.EmployeeFirstName+' '+E.EmployeeLastName, [ManagerName] = M.EmployeeFirstName +' ' +M.EmployeeLastName
From Employees AS E
Inner Join Employees AS M 
On M.EmployeeID = E.ManagerID 
Order By [ManagerName];
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
CREATE VIEW [vCategoriesAndProductsAndInventoryAndEmployees] AS
SELECT 
    [vCategories Table].CategoryName,
    [vProducts Table].ProductName,
    [vInventories Table].InventoryID,
    [vEmployees Table].EmployeeFirstName + ' ' + [vEmployees Table].EmployeeLastName AS EmployeeName,
    [vEmployees Table].EmployeeFirstName + ' ' + [vEmployees Table].EmployeeLastName AS ManagerName
FROM 
    [vCategories Table]
JOIN 
    [vProducts Table] ON [vCategories Table].CategoryID = [vProducts Table].CategoryID
JOIN 
    [vInventories Table] ON [vProducts Table].ProductID = [vInventories Table].ProductID
JOIN 
    [vEmployees Table] ON [vInventories Table].EmployeeID = [vEmployees Table].EmployeeID
LEFT JOIN 
    [vEmployees Table] ON [vEmployees Table].ManagerID = [vEmployees Table].EmployeeID;
GO

SELECT * 
FROM [vCategoriesAndProductsAndInventoryAndEmployees]
ORDER BY CategoryName, ProductName, InventoryID, EmployeeName;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/