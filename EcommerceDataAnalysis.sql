-- Portfolio Project
-- Indian E-commerce dataset 
-- Doing some data cleaning and exploratory data analysis (EDA)

-- Checking data

select *
From [List of Orders]

Select *
from [Order Details]

select *
from [Sales target]

-- Checking data types

SELECT 
TABLE_CATALOG,
TABLE_SCHEMA,
TABLE_NAME, 
COLUMN_NAME, 
DATA_TYPE,
CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 

-- Data cleaning

-- Converting date columns to correct formats

Select [Order Date], CONVERT(date, [Order Date], 103)
From [List of Orders]

ALTER TABLE [list of Orders]
Add [OrderDateFixed] date;

Update [List of Orders]
Set OrderDateFixed = CONVERT(date, [Order Date], 103)

SELECT [Month of Order Date], DATEFROMPARTS('20'+ SUBSTRING([Month of Order Date], 5 , 2),
charindex(SUBSTRING([Month of Order Date], 1 , 3),'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC')/4 + 1,'01')
FROM [Sales target]

ALTER TABLE [Sales target]
Add [MonthOrderDateFixed] date;

Update [Sales target]
Set [MonthOrderDateFixed] = DATEFROMPARTS('20'+ SUBSTRING([Month of Order Date], 5 , 2),
charindex(SUBSTRING([Month of Order Date], 1 , 3),'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC')/4 + 1,'01')
FROM [Sales target]

-- Converting columns with number values to correct format

select amount, Convert(money, amount)
From [Order Details]

Alter Table [order details]
Alter Column [amount] money;

-- Change profit 

select Profit, Convert(money, Profit)
From [Order Details]

Alter Table [order details]
Alter Column [Profit] money;

-- Change quantity

select Quantity, Convert(int, Quantity)
From [Order Details]

Alter Table [order details]
Alter Column [Quantity] int;

-- Change target

Alter Table [Sales Target]
Alter Column [Target] money;

-- Getting rid of bad columns

Alter Table [List of Orders]
Drop Column [Order Date]

Alter Table [Sales Target]
Drop Column [Month of Order Date]

-- Checking duplicate entries

Select [Order ID], OrderDateFixed, CustomerName, State, City, count(*)
From [list of orders]
Group by [Order ID], OrderDateFixed, CustomerName, State, City
having count(*) > 1

Select [Order ID], Amount, Profit, Quantity, Category, [Sub-Category], count(*)
From [Order Details]
Group by [Order ID], Amount, Profit, Quantity, Category, [Sub-Category]
having count(*) > 1

Select MonthOrderDateFixed, Category, count(*)
From [Sales target]
Group by MonthOrderDateFixed, Category
Having count(*) > 1


-- Maybe change Table names to no spaces?

-- Check for null values
Select *
From [List of Orders]
Where [Order ID] = '' or [Order ID] is null

Select *
From [Order Details]
Where [Order ID] = '' or [Order ID] is null

Select *
From [Sales target]
Where MonthOrderDateFixed = '' or MonthOrderDateFixed is null

-- Get rid of empty rows

DELETE FROM [List of Orders] WHERE [Order ID] = '' or [Order ID] is null



-- Exploratory Data Analysis


-- Looking at Orders and Order details

-- View categories and subcategories

Select Category
From [Order Details]
Group by Category

Select Category, [Sub-Category]
From [Order Details]
Group by [Sub-Category], Category
Order by 1, 2



-- Looking at total number of orders
-- 500 total orders

Select count(*)
From [List of Orders]

-- Find total number of orders by date

-- Highest amount of orders on Nov 11, 2018
-- 76/500 dates have more than one orders
-- Will check for trends in visualizations

Select OrderDateFixed, count(*) as TotalOrders
from [List of Orders] od
group by OrderDateFixed
Order by 2 desc

-- Picture drill down here
-- Total number of orders by State
-- Madhya Pradesh and Maharashtra are outliers and have around 3x more orders than all other states

Select State, count(*) as TotalOrders
From [List of Orders] list
group by State
Order by 2 desc

--Total number of orders by city
-- Indore is the most popular city

Select State, City, count(*) as TotalOrders
From [List of Orders]
group by State, City
Order by 3 desc

-- Total Revenue by State

Select list.State, sum(od.Amount) as TotalRevenue
From [List of Orders] list
Join [Order Details] od
on list.[Order ID] = od.[Order ID]
Group by State
Order by 2 desc

-- Total Revenue by City

Select list.State, list.City, sum(od.Amount) as TotalRevenue
From [List of Orders] list
Join [Order Details] od
on list.[Order ID] = od.[Order ID]
Group by State, City
Order by 3 desc

-- Total orders by customer

Select CustomerName, count(*)
From [List of Orders]
Group by CustomerName
Order by 2 desc



-- How many number of sales in each order? How much quantity in each sale?
-- Note: Multiple sales of different products in each order
-- 1 sale of clothing and 2 sales of electronics would mean 3 sales to 1 order


-- Hankerchief, Saree, Stole are biggest sellers... but do they generate the most profit
-- Maybe push sales on trousers and tables

-- 1500 sales
-- 500 Orders
-- 3 sales per order on average

select count(*)
from [Order Details]

-- Looking at quantity sold

select count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]

Order by 2 desc


-- Total number of sales by customer with quantities

select list.CustomerName, count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
from [Order Details] od
join [List of Orders] list on od.[Order ID] = list.[Order ID]
group by list.CustomerName
Order by 3 desc

-- Looking at total number of sales by date with quantity 
select list.OrderDateFixed, count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
from [Order Details] od
join [List of Orders] list on od.[Order ID] = list.[Order ID]
group by list.OrderDateFixed
Order by 2 desc


-- Number of sales in each order with total quantity 
-- About half of orders have more than 1 sale

select [Order ID], count(*) as SalesPerOrder, Sum(quantity) as QuantitySold
From [Order Details]
Group by [Order ID]
Order by 2 desc

-- Looking at biggest orders by quantity sold
-- Which orders has the highest quantity sold?
-- Top 5 orders

select top 5 [Order ID], count(*) as SalesPerOrder, Sum(quantity) as QuantitySold
From [Order Details]
Group by [Order ID]
Order by 2 desc


-- Number of Sales and quantity sold in each category
-- Clothing has most, then electronics, then Furniture

select category, count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category
Order by 2 desc

-- Looking at subcategories
-- Number of sales and quantity of Saree, Hankerchief, and stole surpass ALL others by more than double

select category, [Sub-Category], count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category, [Sub-Category]
Order by 3 desc

-- Looking at number of sales with percentages now

declare @TotalSalesNum money
set @TotalSalesNum = (select count(*) from [Order Details]);

with temp as
(
select category, [Sub-Category], count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category, [Sub-Category]
--Order by 3 desc
)

Select *, (TotalSalesNum/@TotalSalesNum)*100 as SalesNumPercentage
From temp
Order by SalesNumPercentage desc

-- Check top 20%
select top 20 percent category, [Sub-Category], count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category, [Sub-Category]
Order by 3 desc

-- Check top 5 
select top 5 Category, [Sub-Category], count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category, [Sub-Category]
Order by 3 desc

-- Viewing amount recieved from orders by category sorted (highest to lowest)


Select list.OrderDateFixed, list.CustomerName, det.Amount, det.Profit, det.Quantity, det.Category
From [Order Details] det
join [List of Orders] list on det.[Order ID] = list.[Order ID]
Where Category = 'Furniture'
Order by Amount desc

Select list.OrderDateFixed, list.CustomerName, det.Amount, det.Profit, det.Quantity, det.Category
From [Order Details] det
join [List of Orders] list on det.[Order ID] = list.[Order ID]
Where Category = 'Electronics'
Order by Amount desc

Select list.OrderDateFixed, list.CustomerName, det.Amount, det.Profit, det.Quantity, det.Category
From [Order Details] det
join [List of Orders] list on det.[Order ID] = list.[Order ID]
Where Category = 'Clothing'
Order by Amount desc

-- Looking at total amount received by category

Select Category, SUM(Amount) as TotalAmount
From [Order Details]
Group by Category

-- Now by sub-category

Select Category, [Sub-Category], SUM(Amount) as TotalAmount
From [Order Details]
Group by Category, [Sub-Category] 
Order by 1, 2


-- Looking at total amount recieved per order with profits


With temp as
(
Select list.[Order ID], Sum(od.Amount) as TotalAmountPerOrder, sum(od.profit) as TotalProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by list.[Order ID]
)
-- Looking at only orders with postive profit
--Select *
--From temp
--where Totalprofit > 0

-- Orders with negative profit
Select *
From temp
where Totalprofit < 0
Order by 3

-- Total Profit by category

Select Category, Sum(Amount) as TotalAmount, Sum(Profit) as TotalProfit
from [Order Details]
Group by Category

Select Category, [Sub-Category], Sum(Amount) as TotalAmount, Sum(Profit) as TotalProfit
from [Order Details]
Group by Category, [Sub-Category]
Order by 1



-- Finding average amount of revenue and profit per category
-- Positive profit overall
-- Negative profit on electronic games and tables

Select Category, Avg(Amount) as AvgAmount, AVG(Profit) as AvgProfit
from [Order Details]
Group by Category

Select Category, [Sub-Category], Avg(Amount) as AvgAmount, AVG(Profit) as AvgProfit
from [Order Details]
Group by Category, [Sub-Category]
Order by 1

-- Which customers have spent the most money?
-- No customer IDs so no way of telling which are repeats
-- Assuming each customer has different name

Select CustomerName, count(*)
From [list of orders]
Group by CustomerName--, State, City
having count(*) > 1

Select list.CustomerName, Sum(od.Amount) as TotalAmountPerOrder, sum(od.profit) as TotalProfit
from [List of Orders] list
	left join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by list.CustomerName
Order by 2 desc

-- Which customer has generated the biggest profit?
-- Does total amount and profit have a positive correlation?

Select list.CustomerName, Avg(od.Amount) as TotalAmountPerOrder, Avg(od.profit) as TotalProfit
from [List of Orders] list
	left join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by list.CustomerName
Order by 3 desc

--Grouping by customername prevents two different customers with same name displaying.. grouping by state wi
-- leave out people to aggregrate better to treat all as different people 



-- Figuring out KPIs
-- Group revenue and profit by month and year

Select Year(list.OrderDateFixed) as Year, Month(list.OrderDateFixed) as Month, Sum(od.Amount) as TotalAmount, sum(od.profit) as TotalProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)
Order by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)

-- Now averages
Select Year(list.OrderDateFixed) as Year, Month(list.OrderDateFixed) as Month, avg(od.Amount) as AvgAmount, avg(od.profit) as AvgProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)
Order by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)

-- Pivot table with amounts by category


select  Clothing, Furniture, Electronics
from
(
  select Amount, Category
  from [Order Details]
) od
pivot
(
  sum(Amount) 
  for Category in (Clothing, Furniture, Electronics)
) piv

-- Looking at target sales for the month

select MonthOrderDateFixed, Category, Target
from [Sales target]
GROUP BY MonthOrderDateFixed, Category, Target

-- Target compared to actual
-- Looks like every month except for clothing in july of 2018
with MonthlyTotals as (
Select Year(list.OrderDateFixed) as Year, Month(list.OrderDateFixed) as Month, Sum(od.Amount) as TotalAmount, sum(od.profit) as TotalProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)
--Order by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)
)
--Sum of all categories
select Year, Month, mt.TotalAmount, sum(st.Target) as MonthlyTarget, (TotalAmount - sum(st.Target)) as Difference
from MonthlyTotals as mt
right join [Sales Target] st 
on  year(MonthOrderDateFixed)  = mt.Year and month(MonthOrderDateFixed) = mt.Month
--Where (TotalAmount - Target) < 0
group by Year, Month, st.MonthOrderDateFixed, TotalAmount
Order by 1, 2


-- Figuring out how much item cost us by subtracting profit from amount
-- Visualize cost, amount recieved, profit together


Select *, (Amount-Profit) as Cost
from [Order Details]

-- -- temp

select *
From [List of Orders]
order by OrderDateFixed

Select *
from [Order Details]

select *
from [Sales target]

-- Figure out repeat customers
-- Find time distance of orders  Make note customer may have repeat names but just for the sake of coding
 

-- Running total by categories
select list.OrderDateFixed, Category, Amount,
SUM(Amount) Over (Partition by Category Order by list.OrderDateFixed) as RunningTotal
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Order by list.OrderDateFixed

-- Running total just by date

select list.OrderDateFixed, Amount,
SUM(Amount) Over (Order by list.OrderDateFixed) as RunningTotal
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by OrderDateFixed, Amount
Order by list.OrderDateFixed

-- Setup drill down for total orders by state and city on map


-- Forecasting 

--Business inquiries
-- Do higher order amounts correlate with profit?
-- Does higher quantity have negative relationship with profit?
-- Do higher cost of goods have bigger profits?
-- When did targets get met
-- Which category and sub category had highest sales


-- Creating views

Create View MonthlyOrderRevenue as
Select Year(list.OrderDateFixed) as Year, Month(list.OrderDateFixed) as Month, Sum(od.Amount) as TotalAmount, sum(od.profit) as TotalProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)

Create View MonthlyAvgRevenue as
Select Year(list.OrderDateFixed) as Year, Month(list.OrderDateFixed) as Month, avg(od.Amount) as AvgAmount, avg(od.profit) as AvgProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)

Create View OrdersByState as
Select State, count(*) as TotalOrders
From [List of Orders] list
group by State

Create View OrdersByCity as
Select State, City, count(*) as TotalOrders
From [List of Orders]
group by State, City

Create View CustomerSalesAndQuantities as
select list.CustomerName, count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
from [Order Details] od
join [List of Orders] list on od.[Order ID] = list.[Order ID]
group by list.CustomerName

Create View SalesAndQuantityByDate as
select list.OrderDateFixed, count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
from [Order Details] od
join [List of Orders] list on od.[Order ID] = list.[Order ID]
group by list.OrderDateFixed

Create View CategorySales as
select category, count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category

Create View SubcategorySales as
select category, [Sub-Category], count(*) as TotalSalesNum, Sum(quantity) as QuantitySold
From [Order Details]
Group by Category, [Sub-Category]

Create View CategoryRevenue as
Select Category, SUM(Amount) as TotalAmount
From [Order Details]
Group by Category

Create View SubcategoryRevenue as
Select Category, [Sub-Category], SUM(Amount) as TotalAmount
From [Order Details]
Group by Category, [Sub-Category] 

Create View CategoryAvgRevenue as 
Select Category, Avg(Amount) as AvgAmount, AVG(Profit) as AvgProfit
from [Order Details]
Group by Category

Create View SubcategoryAvgRevenue as
Select Category, [Sub-Category], Avg(Amount) as AvgAmount, AVG(Profit) as AvgProfit
from [Order Details]
Group by Category, [Sub-Category]

Create View CustomerRevenue as
Select list.CustomerName, Sum(od.Amount) as TotalAmountPerOrder, sum(od.profit) as TotalProfit
from [List of Orders] list
	left join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by list.CustomerName

Create View CategoryTargetSales as
select MonthOrderDateFixed, Category, Target
from [Sales target]
GROUP BY MonthOrderDateFixed, Category, Target

Create View TargetVsActual as
with MonthlyTotals as (
Select Year(list.OrderDateFixed) as Year, Month(list.OrderDateFixed) as Month, Sum(od.Amount) as TotalAmount, sum(od.profit) as TotalProfit
from [List of Orders] list
	join [Order Details] od
	on list.[Order ID] = od.[Order ID]
Group by YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)
--Order by  YEAR(list.OrderDateFixed), MONTH(list.OrderDateFixed)
)
--Sum of all categories
select Year, Month, mt.TotalAmount, sum(st.Target) as MonthlyTarget, (TotalAmount - sum(st.Target)) as Difference
from MonthlyTotals as mt
right join [Sales Target] st 
on  year(MonthOrderDateFixed)  = mt.Year and month(MonthOrderDateFixed) = mt.Month
--Where (TotalAmount - Target) < 0
group by Year, Month, st.MonthOrderDateFixed, TotalAmount

