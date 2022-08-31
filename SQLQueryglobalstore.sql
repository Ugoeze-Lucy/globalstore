
SELECT * FROM Global_Superstore

/*** PRODUCT ANALYSIS ***/
/**** Which country has the top sales?***/
select Country,sum (Sales)country_sales
from Global_Superstore
GROUP BY Country
order by sum (Sales) DESC

/** What are the top five profit making product types on a yearly basis?***/
select top 5(Product_Name), year(Order_Date) DATE, sum(Profit)total_profit
from Global_Superstore
where year (Order_Date) = 2011
group by Product_Name, year (Order_Date)
order by sum(Profit) DESC

select top 5(Product_Name), year(Order_Date) DATE, sum(Profit)total_profit
from Global_Superstore
where year (Order_Date) = 2012
group by Product_Name, year (Order_Date)
order by sum(Profit) DESC

select top 5(Product_Name), year(Order_Date) DATE, sum(Profit)total_profit
from Global_Superstore
where year (Order_Date) = 2013
group by Product_Name, year (Order_Date)
order by sum(Profit) DESC

select top 5(Product_Name), year(Order_Date) DATE, sum(Profit)total_profit
from Global_Superstore
where year (Order_Date) = 2014
group by Product_Name, year (Order_Date)
order by sum(Profit) DESC


/*** CUSTOMER ANALYSIS ***/
/*** Which customer segment is most profitable in each year? ***/
select year (Order_Date)year, Segment, sum (Profit)total_profit
from Global_Superstore
WHERE year (Order_Date) = 2011
group by Segment, year (Order_Date)
order by sum (Profit)

select year (Order_Date)year, Segment, sum (Profit)total_profit
from Global_Superstore
WHERE year (Order_Date) = 2012
group by Segment, year (Order_Date)
order by sum (Profit)

select year (Order_Date)year, Segment, sum (Profit)total_profit
from Global_Superstore
WHERE year (Order_Date) = 2013
group by Segment, year (Order_Date)
order by sum (Profit)

select year (Order_Date)year, Segment, sum (Profit)total_profit
from Global_Superstore
WHERE year (Order_Date) = 2014
group by Segment, year (Order_Date)
order by sum (Profit)

/***Pofiling  the customers into High, Middle and Low profile customers using recency frequency monetry (RFM) Analysis***/
DROP TABLE IF EXISTS #RFM
select Customer_ID, MAX (Order_Date)max_order_date,count(*)Frequency,avg(Sales)Monetary, 
(select max(Order_Date)max_order_table_date from Global_Superstore)max_order_table_date,
datediff(dd,MAX (Order_Date),(select max(Order_Date)max_order_table_date from Global_Superstore))Recency,
  ntile(3) over (order by datediff(dd,MAX (Order_Date),(select max(Order_Date)max_order_table_date from Global_Superstore))DESC )R,
       ntile(3) over (order by count(*) ASC)F,
       ntile(3) over (order by avg(Sales) ASC)M,
	   ( ntile(3) over (order by datediff(dd,MAX (Order_Date),(select max(Order_Date)max_order_table_date from Global_Superstore))DESC )+
       ntile(3) over (order by count(*) ASC)+
       ntile(3) over (order by avg(Sales) ASC))RFM
	   INTO #RFM
from Global_Superstore 
group by Customer_ID
ORDER BY  ( ntile(3) over (order by datediff(dd,MAX (Order_Date),(select max(Order_Date)max_order_table_date from Global_Superstore))DESC )+
       ntile(3) over (order by count(*) ASC)+
       ntile(3) over (order by avg(Sales) ASC))DESC
	   
	   drop table if exists #customer_profile
	   SELECT Customer_ID,RFM,
	   CASE
	   WHEN  RFM in (1,2,3) THEN 'Low_profile_customers'
	   WHEN RFM in (4,5,6) THEN 'Middle_profile_customers'
	   when RFM in (7,8,9) then 'High_profile_customers'
	   end as customer_profile
	      into #customer_profile
	   from #RFM
	   ORDER BY RFM DESC

	   /***do the high profile customers contribute more revenue***/
	   drop table if exists #rev
	   select Country,Sales,Quantity,Profit,customer_profile, (Sales*Quantity)Revenue
	   into #rev
	   from Global_Superstore
	   full outer join #customer_profile
	   on Global_Superstore.Customer_ID=#customer_profile.Customer_ID

	   select customer_profile,sum (Revenue)revenue
	   from #rev
	   where customer_profile = 'High_profile_customers'
	   group by customer_profile
	   order by sum(Revenue) 
	   
	    select customer_profile,sum (Revenue)revenue
	   from #rev
	   where customer_profile = 'Low_profile_customers'
	   group by customer_profile
	   order by sum(Revenue) 
	   
	    select customer_profile,sum (Revenue)revenue
	   from #rev
	   where customer_profile = 'middle_profile_customers'
	   group by customer_profile
	   order by sum(Revenue) 
	   

	   /***how are the customers distributed across the countries?***/
	   select Country,count (customer_profile)total_customers, customer_profile
	   from #rev
	   group by Country, customer_profile
	   order by count(customer_profile) desc
	   
	   

	
