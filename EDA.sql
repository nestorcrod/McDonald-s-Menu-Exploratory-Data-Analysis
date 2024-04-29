/* Database Schema Information */

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

SELECT COLUMN_NAME, DATA_TYPE,CHARACTER_MAXIMUM_LENGTH	
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'menu$';


/*Category Names */

SELECT DISTINCT Category	 
FROM [McDonald's Menu Nutrition Facts].dbo.menu$


/* Number of Items by Category */

SELECT Category, Number_of_Items_by_Category = COUNT(*)	 
FROM [McDonald's Menu Nutrition Facts].dbo.menu$
GROUP BY Category


/* Highest-Calorie Item by Category */

SELECT Calories, Category, Item
FROM
(
SELECT Calories, Category, Item,
       Ranking = rank()OVER(PARTITION BY Category ORDER BY Calories DESC)    
FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
) A
WHERE Ranking = 1


/* Lowest-Calorie Item by Category */

SELECT Calories, Category, Item
FROM
(
SELECT Calories, Category, Item,
       Ranking = rank()OVER(PARTITION BY Category ORDER BY Calories)    
FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
) A
WHERE Ranking = 1


/* Average Calorie counts by Category */	/* Tableau Visualization named "Average calorie count by food category - Tableau Viz.png" takes the data from this querie */ 

SELECT DISTINCT Category,
   	        Average_Calorie_Count_By_Category = AVG(Calories)OVER(PARTITION BY Category)
FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
ORDER BY Average_Calorie_Count_By_Category


/* Median Calorie Item by Category with CTE’s */

WITH OrderedData AS
(
	SELECT Category, Item, Calories,
       	ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Calories) AS RowNum,
       	COUNT(*) OVER (PARTITION BY Category) AS Total_Items
	FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
)
SELECT Category, Calories AS Median_Calories_by_Category
FROM OrderedData
WHERE RowNum = (Total_Items + 1) / 2;


/* Mean & Median Calorie Count by Category with CTE's */

WITH OrderedData AS
(
	SELECT Category, Item, Calories,
       	ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Calories) AS RowNum,
       	COUNT(*) OVER (PARTITION BY Category) AS Total_Items,
   	Average_Calorie_Count_By_Category = AVG(Calories)OVER(PARTITION BY Category)
	FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
)
SELECT Category, Average_Calorie_Count_By_Category,Calories AS Median_Calories_by_Category
FROM OrderedData
WHERE RowNum = (Total_Items + 1) / 2;


/* Mode Calorie Count by Category with subqueries*/

SELECT DISTINCT Category, Calories AS Mode_Calories, X AS 'Number of item with same calorie count'
FROM
(
SELECT Category, Item, Calories, X, Y = DENSE_RANK( )OVER(PARTITION BY Category ORDER BY Category, X DESC) --finfing the mode within a Category
FROM
(
SELECT Category, Item, Calories, X = Count(*)OVER(PARTITION BY Category, Calories) --number of times a calorie number repeats  
  	 
FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
) A
) B
WHERE Y = 1


/* Calorie Count Variance & Standard Deviation by Category with subqueries*/

SELECT Category, Variance AS Calorie_Varienace, Calorie_Standard_Deviation = SQRT(Variance)
FROM
(
SELECT Category, Variance = AVG(POWER(Calories - Mean_Category, 2))
FROM
(
SELECT Category, Calories,
       Mean_Category = AVG(Calories)OVER(PARTITION BY Category)			
FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
) A
GROUP BY Category
)B	
FROM [McDonald's Menu Nutrition Facts].[dbo].[menu$]
) A
GROUP BY Category
)B
