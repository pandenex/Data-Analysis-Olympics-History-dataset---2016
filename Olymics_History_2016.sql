# 1)How many olympics games have been held?

Select 
count(Distinct games)  as total_gaames
From olympics_history;
---------------------------------------------------------------------------------------------------------------------------

# 2)List down all Olympics games held so far.

Select
	Concat(total_gaames, ' - ', city) as Games
	From
(
	Select 
	Distinct games  as total_gaames, city
	From olympics_history
	Order By Games) c;
 # OR
 
 Select 
	year as Year, season as Season, city as City
	From olympics_history
	Group By year, season, city
	Order By year;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 3) City with Maximum Olympics Summer/Winter Games

SELECT Season, City, Total_Games_on_City
FROM (
    SELECT 
        Season, 
        City, 
        Count(DISTINCT Year) AS Total_Games_on_City,
        RANK() OVER (PARTITION BY Season ORDER BY COUNT(DISTINCT Year) DESC) AS Rnk
    FROM olympics_history
    GROUP BY Season, City
) RankedCities
WHERE Rnk = 1
ORDER BY Season, City;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 4) Mention the total no of nations who participated in each olympics game?

Select
	games, count(Distinct noc) as Total_Countries
    From olympics_history
    group by games
    order by games;
    
---------------------------------------------------------------------------------------------------------------------------------------------------

# 5) Which year saw the highest and lowest no of countries participating in olympics?

WITH T1 AS (
    SELECT
        games, 
        COUNT(DISTINCT noc) AS Total_Countries
    FROM olympics_history
    GROUP BY games
)
Select 
Concat(
(Select games from T1 order by Total_Countries DESC Limit 1), ' - ',
 (Select Total_Countries from T1 order by Total_Countries DESC Limit 1) 
 ) as Maximum_Countries,
 Concat(
(Select games from T1 order by Total_Countries ASC Limit 1), ' - ',
 (Select Total_Countries from T1 order by Total_Countries ASC Limit 1) 
 ) as Minimum_Countries;
 
 ---------------------------------------------------------------------------------------------------------------------------------------------------
 
 # 6) Which nation has participated in all of the olympic games
 With T1 as
 (
Select 
Count(distinct games) as Total_Games
From olympics_history
),
T2 as
( 
 Select 
	nr.region as Country, Count(Distinct oh.games) as Games_Participated
	From olympics_history oh 
    Left Join olympics_history_noc_regions nr 
    on oh.noc=nr.noc
    Group By nr.region
)
Select Country as Most_Participated_Countries
from T2, T1
where T2.Games_Participated = T1.Total_Games;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 7) Identify the sport which was played in all summer olympics.

with T1 as 
(
Select 
count(Distinct (games)) as total_games 
From olympics_history
Where season = 'summer'
),
T2 as
(
Select 
Sport, count(Distinct (games)) as no_of_games 
From olympics_history
Where season = 'summer' 
Group By sport 
)
Select 
T2.sport, T2.no_of_games 
From T2  
Join T1 on T1.total_games = T2.no_of_games;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 8) Which Sports were just played only once in the olympics?

Select 
Sport, count(Distinct (games)) as no_of_games 
From olympics_history
Group By sport 
Having no_of_games=1;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 9) Fetch the total no of sports played in each olympic games.

Select
games as Games, Count(Distinct sport) as Total_Games
From olympics_history
Where games like '%summer'
Group by games
Order By games DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 10)Fetch oldest athletes to win a gold medal

Select *
From
(
Select 
* , Rank() Over (Order By age DESC) as rnk
From olympics_history
where medal = 'gold'
)r
where  rnk =1;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 11) Fetch the top 5 athletes who have won the most gold medals.

Select
Name, Gold_count
From 
(
Select name as Name, count(name) as Gold_count, Dense_Rank () Over (Order By Count(1) DESC) as rnk
From olympics_history
where medal = 'gold'
group by name
order by Gold_count DESC) a
Where rnk <6;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 12) Find the Ratio of male and female athletes participated in all olympic games.

With T1 as
(
Select
Count(sex) as Male
From olympics_history
where sex = 'M'
), 
T2 as
(
Select
Count(sex) as Female
From olympics_history
where sex = 'F'
)
SELECT 
  CONCAT('1 : ', ROUND(Cast(Male as Decimal(10,2)) / CAST(Female AS DECIMAL(10, 2)), 2)) AS Ratio
FROM T1, T2;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 13) Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

Select
Name, total_medal
From
(
Select 
name as Name, count(1) as total_medal, Dense_Rank () Over (Order BY Count(1) Desc) as rnk
from olympics_history
where medal IN ('gold', 'silver', 'bronze')
Group By name
Order By total_medal DESC
)a
Where rnk < 6;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 14) Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

Select
Country, total_medal
From
(
Select 
nr.region as Country, count(1) as total_medal, Dense_Rank () Over (Order BY Count(1) Desc) as rnk
from olympics_history oh
Left Join olympics_history_noc_regions nr
on oh.noc = nr.noc
where medal IN ('gold', 'silver', 'bronze')
Group By nr.region
Order By total_medal DESC
)a
Where rnk < 6;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 15) List down total gold, silver and bronze medals won by each country.

SELECT nr.region as country,
       COUNT(CASE WHEN medal = 'gold' THEN 1 END) AS gold,
       COUNT(CASE WHEN medal = 'silver' THEN 1 END) AS silver,
       COUNT(CASE WHEN medal = 'bronze' THEN 1 END) AS bronze
FROM olympics_history oh join olympics_history_noc_regions nr on nr.noc = oh.noc
GROUP BY 
    country
HAVING 
    gold > 0 AND silver > 0 AND bronze > 0 
order by gold DESC, silver Desc, Bronze Desc;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 16) List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

SELECT games, nr.region as country,
       COUNT(CASE WHEN medal = 'gold' THEN 1 END) AS gold,
       COUNT(CASE WHEN medal = 'silver' THEN 1 END) AS silver,
       COUNT(CASE WHEN medal = 'bronze' THEN 1 END) AS bronze
FROM olympics_history oh join olympics_history_noc_regions nr on nr.noc = oh.noc
GROUP BY games, country
HAVING 
    gold > 0 OR silver > 0 OR bronze > 0
    order by games, country;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 17) Identify which country won the most gold, most silver and most bronze medals in each olympic games.

 WITH MedalCounts AS (
    SELECT 
        games, 
        nr.region AS country, 
        SUM(CASE WHEN medal = 'gold' THEN 1 ELSE 0 END) AS gold_count,
        SUM(CASE WHEN medal = 'silver' THEN 1 ELSE 0 END) AS silver_count,
        SUM(CASE WHEN medal = 'bronze' THEN 1 ELSE 0 END) AS bronze_count
    FROM 
        olympics_history oh
    JOIN 
        olympics_history_noc_regions nr 
        ON nr.noc = oh.noc
    GROUP BY 
        games, country
),
MaxMedals AS (
    SELECT 
        games,
        MAX(gold_count) AS max_gold,
        MAX(silver_count) AS max_silver,
        MAX(bronze_count) AS max_bronze
    FROM 
        MedalCounts
    GROUP BY 
        games
)
SELECT 
    mc.games,
    CONCAT(mc.country, ' - ', mc.gold_count) AS Max_Gold,
    CONCAT(ms.country, ' - ', ms.silver_count) AS Max_Silver,
    CONCAT(mb.country, ' - ', mb.bronze_count) AS Max_Bronze
FROM 
    MaxMedals mm
JOIN 
    MedalCounts mc 
    ON mm.games = mc.games AND mm.max_gold = mc.gold_count
JOIN 
    MedalCounts ms 
    ON mm.games = ms.games AND mm.max_silver = ms.silver_count
JOIN 
    MedalCounts mb 
    ON mm.games = mb.games AND mm.max_bronze = mb.bronze_count
ORDER BY 
    mc.games;
    
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    
# 18 Which countries have never won gold medal but have won silver/bronze medals?
SELECT nr.region as country,
       COUNT(CASE WHEN medal = 'gold' THEN 1 END) AS gold,
       COUNT(CASE WHEN medal = 'silver' THEN 1 END) AS silver,
       COUNT(CASE WHEN medal = 'bronze' THEN 1 END) AS bronze
FROM olympics_history oh join olympics_history_noc_regions nr on nr.noc = oh.noc
GROUP BY country
HAVING 
    gold = 0 AND (silver > 0 OR bronze > 0)
    order by bronze DESC;
    
---------------------------------------------------------------------------------------------------------------------------------------------------

# 19) In which Sport/event, India has won highest medals.

SELECT
	sport, count(medal) as Medal_Count 
FROM
	(
SELECT 
	noc, sport, medal
FROM
	olympics_history
HAVING noc = 'IND' AND medal <> 'NULL')c
group by sport
order by Medal_Count  DESC
Limit 1;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 20)  Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

SELECT
	games, sport, count(medal) as Medal_Count 
FROM
	(
SELECT 
	noc, games, sport, medal
FROM
	olympics_history
HAVING noc = 'IND' AND medal <> 'NULL')c
where sport ='hockey'
group by games
order by Medal_Count  DESC;


	

