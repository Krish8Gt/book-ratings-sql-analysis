# ==============================================================
# Business Analysis
# ==============================================================

# General Metrics
select count(*) from Users_Final;
select count(*) from Books_Final;
select count(*) from Ratings_Final;

-- 2,78,858 Unique Users
-- 2,70,928 Unique Books
-- 10,31,582 Unique Ratings

# Timeframe of Published Books
select
	min(Year_Published) as Lower_Limit ,
    max(year_Published) as Upper_Limit
from Books_Final
where Year_Published is not null;

-- Oldest Book was first Published originally in 1376 A.D
-- Newest Book was Published in 2024

# Age range of the Users
select
	min(Age) as Lower_Limit ,
    max(Age) as Upper_Limit
from Users_Final
where Age is not null;

-- Youngest User was 5 years old and the oldest user was 119 years old

# Top countries by number of active readers

# Business question: Where are our most engaged user bases?

select
	u.Country as Country ,
    count(distinct r.User_ID) as Number_Of_Active_Users 
from Users_Final u
join Ratings_Final r
	on u.User_ID = r.User_ID
where u.Country is not null
group by Country
order by Number_Of_Active_Users desc
limit 10;


-- Top 10 countries with most active users/user engagement
-- Country			Number Of users
-- united states	58128
-- united kingdom	4208
-- switzerland		634
-- spain			2360
-- new zealand		708
-- italy			1219
-- germany			5083
-- france			1079
-- canada			8884
-- australia		2689

# Countries with the highest average ratings

# Business question: Which regions rate books more positively?

select
	u.Country as Country ,
    round(sum(r.Book_Rating)/count(r.Book_Rating) ,2 ) as Average_Rating ,
    count(r.Book_Rating) as Total_Ratings
from Ratings_Final r
join Users_Final u
	on r.User_ID = u.User_ID
where u.Country is not null
group by u.Country
having count(*) > 500
order by Average_Rating desc
limit 10;

-- Country				Average Rating		Total Number Of Ratings
-- philippines			6.28				765
-- singapore			4.76				1151
-- belgium				4.39				645
-- china				3.96				611
-- portugal				3.85				6973
-- japan				3.71				775
-- ireland				3.67				854
-- brazil				3.64				925
-- romania				3.64				1168
-- dominican republic	3.62				923
-- spain				3.51				14989
-- united kingdom		3.43				33080
-- switzerland			3.40				4211
-- france				3.32				10720
-- italy				3.31				3501
-- sweden				3.30				772
-- germany				3.26				27704
-- malaysia				3.14				5090
-- austria				2.96				2814
-- canada				2.87				93054
-- australia			2.86				18239
-- netherlands			2.77				4986
-- united states		2.70				747135
-- new zealand			2.37				5575
-- iran					2.25				1649
-- finland				2.12				1196

# Most-rated books (true popularity, not average bias)

# Business question: Which books generate the most engagement?

# 1000 Of the most engaging Books

select
	b.ISBN_13 as ISBN ,
	b.Book_Title as Book_Title ,
    b.Author as Author ,
    count(r.Book_Rating) as Number_Of_Ratings
from Books_Final b
join Ratings_Final r
	on b.ISBN_13 = r.ISBN_13
group by b.ISBN_13 ,b.Book_Title ,b.Author
order by Number_Of_Ratings desc
limit 1000;

# Top 20 Most Engaging Titles
select
	b.ISBN_13 as ISBN ,
	b.Book_Title as Book_Title ,
    b.Author as Author ,
    count(r.Book_Rating) as Number_Of_Ratings
from Books_Final b
join Ratings_Final r
	on b.ISBN_13 = r.ISBN_13
group by b.ISBN_13 ,b.Book_Title ,b.Author
order by Number_Of_Ratings desc
limit 20;

# Top 10 Most Engaging Titles
select
	b.ISBN_13 as ISBN ,
	b.Book_Title as Book_Title ,
    b.Author as Author ,
    count(r.Book_Rating) as Number_Of_Ratings
from Books_Final b
join Ratings_Final r
	on b.ISBN_13 = r.ISBN_13
group by b.ISBN_13 ,b.Book_Title ,b.Author
order by Number_Of_Ratings desc
limit 10;

-- ISBN				Book_Title																			Number Of Ratings
-- 9780971880108	Wild Animus	Rich Shapero															2502
-- 9780316666343	The Lovely Bones: A Novel	Alice Sebold											1295
-- 9780385504201	The Da Vinci Code	Dan Brown														884
-- 9780060928339	Divine Secrets of the Ya-Ya Sisterhood: A Novel	Rebecca Wells						732
-- 9780312195519	The Red Tent (Bestselling Backlist)	Anita Diamant									723
-- 9780440237228	A Painted House	John Grisham														649
-- 9780142001745	The Secret Life of Bees	Sue Monk Kidd												621
-- 9780679764021	Snow Falling on Cedars	David Guterson												618
-- 9780446672214	Where the Heart Is (Oprah's Book Club (Paperback))	Billie Letts					587
-- 9780671027360	Angels &amp; Demons	Dan Brown														586
-- 9780590353427	Harry Potter and the Sorcerer's Stone (Harry Potter (Paperback))	J. K. Rowling	575
-- 9780316601955	The Pilot's Wife : A Novel	Anita Shreve											568
-- 9780375727344	House of Sand and Fog	Andre Dubus III												552
-- 9780440211457	The Firm	John Grisham															534
-- 9780452282155	Girl with a Pearl Earring	Tracy Chevalier											526
-- 9780440214045	The Pelican Brief	John Grisham													523
-- 9780804106306	The Joy Luck Club	Amy Tan															519
-- 9780440211723	A Time to Kill	JOHN GRISHAM														517
-- 9780345337665	Interview with the Vampire	Anne Rice												506
-- 9780060930530	The Poisonwood Bible: A Novel	Barbara Kingsolver									496

# Best-rated books (quality + volume filter)

# Business question: Which books are both popular and loved?

select
	b.ISBN_13 as ISBN ,
    b.Book_Title as Book_Title ,
    b.Author as Author ,
    round(sum(r.Book_Rating)/count(r.Book_Rating) ,2 ) as  Average_Rating ,
    count(r.Book_Rating) as Number_Of_Ratings
from Books_Final b
join Ratings_Final r
	on b.ISBN_13 = r.ISBN_13
group by b.ISBN_13 ,b.Book_Title ,b.Author
having count(r.Book_Rating) >= 100
order by Average_Rating desc
limit 10;

-- ISBN				Book_Title														Author				Average rating		Number Of Ratings
-- 9780439064866	Harry Potter and the Chamber of Secrets (Book 2)				J. K. Rowling		6.61				170
-- 9780439139595	Harry Potter and the Goblet of Fire (Book 4)					J. K. Rowling		6.56				195
-- 9780439136358	Harry Potter and the Prisoner of Azkaban (Book 3)				J. K. Rowling		6.47				197
-- 9780590353403	Harry Potter and the Sorcerer's Stone (Book 1)					J. K. Rowling		6.36				168
-- 9780439358064	Harry Potter and the Order of the Phoenix (Book 5)				J. K. Rowling		5.59				335
-- 9780439136365	Harry Potter and the Prisoner of Azkaban (Book 3)				J. K. Rowling		5.35				226
-- 9780812550702	Ender's Game (Ender Wiggins Saga (Paperback))					Orson Scott Card	5.30				195
-- 9780671027346	The Perks of Being a Wallflower									Stephen Chbosky		5.19				103
-- 9780439139601	Harry Potter and the Goblet of Fire (Book 4)					J. K. Rowling		5.10				193
-- 9780345339683	The Hobbit : The Enchanting Prelude to The Lord of the Rings	J.R.R. TOLKIEN		5.01				281

# Historical vs modern books: rating comparison

# Business question: Do classic books age well with modern readers?

select
    b.Historical_Flag as Historical_Or_Non_Historical_Books,
    round(avg(r.Book_Rating), 2) as Avg_Rating,
    count(*) as Total_Number_Of_Ratings
from Ratings_Final r
join Books_Final b
    on r.ISBN_13 = b.ISBN_13
group by b.Historical_Flag;

-- Book Type					Average Rating	Number Of Ratings
-- Non Historical Books			2.84			1030852
-- Historical Books/Classics	3.36			730

-- Classics have not disappeared or aged badly but there is very little User data /Ratings to conclude properly

select
	b.ISBN_13 as ISBN ,
	b.Book_Title as Book_Title ,
    b.Author as Author ,
    round(sum(r.Book_Rating)/count(r.Book_Rating) ,2 ) as Average_Rating ,
    count(r.Book_Rating) as Number_Of_Ratings
from Books_Final b 
join Ratings_Final r
	on b.ISBN_13 = r.ISBN_13
where b.Historical_Flag = 1
group by b.ISBN_13 ,b.Book_Title ,b.Author
having count(r.Book_Rating) >= 5
order by Average_Rating desc
limit 10;

-- ISBN				Book Title															Author					Average Rating		Number Of Ratings
-- 9780395071229	The Hobbit															J. R. R. Tolkien		7.25				8
-- 9780448095264	Clue of the Leaning Chimney (Nancy Drew (Hardcover))				Carolyn Keene			6.40				5
-- 9780440772095	RAMONA THE PEST (Ramona Quimby (Paperback))							BEVERLY CLEARY			6.00				5
-- 9780060263959	Stuart Little 60th Anniversary Edition								E. B. White				5.88				8
-- 9780448095226	The Clue in the Crumbling Wall (Nancy Drew Mystery Stories, No 22)	Carolyn Keene			5.40				5
-- 9780684717975	Farewell to Arms													Ernest Hemingway		5.31				13
-- 9780582530089	Animal Farm (Bridge)												Naura Hayden			5.20				5
-- 9780717802418	Manifesto of the Communist Party									Karl Marx				4.83				6
-- 9780448095240	The Clue in the Old Album (Nancy Drew Mystery Stories, No 24)		Carolyn Keene			4.57				7
-- 9780684830681	Gone With the Wind													Margaret Mitchell		4.38				8

# Publisher performance (quality + engagement)

# Business question: Which publishers consistently deliver high-rated books?

select
	b.Publisher as Publishing_House ,
    round(sum(r.Book_Rating)/count(r.Book_Rating) ,2 ) as Average_Rating ,
    count(r.Book_Rating) as Total_Number_Of_Ratings
from Books_Final b
join Ratings_Final r
	on b.ISBN_13 = r.ISBN_13
where b.Publisher is not null
group by b.Publisher
having count(r.Book_Rating) >= 300
order by Average_Rating desc
limit 10;

-- Publishing House				Average Rating		Total Number Of Ratings
-- Tokyopop						6.39				515
-- DC Comics					5.87				543
-- Arthur A. Levine Books		4.79				629
-- Andrews McMeel Publishing	4.69				2589
-- O'Reilly						4.62				388
-- Lonely Planet Publications	4.54				323
-- Distribooks					4.30				678
-- Chronicle Books				4.25				1139
-- Alianza						4.15				472
-- Llewellyn Publications		4.15				1003

# Age-group rating behavior

# Business question: How do different age groups rate books?

select
	case
		when u.Age < 18 then 'Under 18 Years' 
        when u.Age between 18 and 25 then '18 - 25 Years'
        when u.Age between 26 and 35 then '26 - 35 Years'
        when u.Age between 36 and 50 then '36 - 50 years'
        else '50+ Years'
	end as Age_Group ,
    round(sum(r.Book_Rating)/count(r.Book_Rating) ,2 ) as Average_Rating ,
    count(r.Book_Rating) as Total_Number_Of_Ratings
from Users_Final u
join Ratings_Final r
	on u.User_ID = r.User_ID
where u.Age is not null
group by Age_Group
order by Total_Number_Of_Ratings desc; 

-- Age group		Average rating		Total Number Of Ratings
-- 26 - 35 Years	2.74				259024
-- 36 - 50 years	2.67				249085
-- 50+ Years		2.77				120165
-- 18 - 25 Years	2.93				101804
-- Under 18 Years	3.60				20617