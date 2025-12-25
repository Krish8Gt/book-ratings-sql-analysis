# ==============================================================
# Database Creation and initialisation
# ==============================================================

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

create database if not exists Books_db;

show databases;

use Books_db;

# ==============================================================
# Table Creation and Population
# ==============================================================

# Books Table
create table Books(
	ISBN varchar(20) ,
    Book_Title varchar(500) ,
    Author varchar(255) ,
    Year_Published smallint unsigned null ,
    Publisher varchar(300) 
);

describe Books;

load data local infile
  'C:/Book Recommendation SQL project(Business Insights)/Data/Books.csv'
into table Books
fields terminated by ',' 
optionally enclosed by '"' 
escaped by '"'
lines terminated by '\n'
ignore 1 lines
(
  ISBN,
  Book_Title,
  Author,
  Year_Published,
  Publisher,
  @dummy1,
  @dummy2,
  @dummy3
);

# Fixing messy Year_Published entries in Books Dataset

select *
from Books
limit 1 offset 209538;

update 
	Books
set 
	Year_Published = 2000 ,
    Publisher = 'DK Publishing Inc' ,
    Author = null
where ISBN = '078946697X';

select *
from Books
limit 1 offset 220731;

update
	Books
set
	Year_Published = 2003 ,
    Publisher = 'Gallimard' ,
    Author = null
where ISBN = '2070426769';

select *
from Books
limit 1 offset 221678;

update
	Books
set
	Year_Published = 2000 ,
    Publisher = 'DK Publishing Inc' ,
    Author = null
where ISBN = '0789466953';

# checking the count of rows with 0s as Year_Published
select count(*)
from (
	select *
	from Books
	where Year_Published = 0
)as zero;

# Fixing 0 Year_Published rows to NULLs
update Books
set Year_Published = null
where Year_Published = 0;

# verifying 
select count(*)
from (
	select *
	from Books
	where Year_Published is null
)as zero;

# Users Table
create table Users (
  User_ID   int unsigned,
  Location  varchar(255),
  Age       float null
);


describe Users;

load data local infile 'C:/Book Recommendation SQL project(Business Insights)/Data/Users-csv.csv'
into table Users
character set utf8mb4
fields terminated by ',' 
  enclosed by '"' 
  escaped by '"'          -- handles "" inside quoted fields
lines terminated by '\r\n' -- try '\n' if your file is LF only
ignore 1 lines
(@User_ID_raw, @Location_raw, @Age_raw, @extra)  -- @extra swallows any trailing junk/extra field
set
  User_ID  = nullif(TRIM(@User_ID_raw), ''),
  Location = nullif(TRIM(@Location_raw), ''),
  Age = case
          when TRIM(@Age_raw) regexp '^-?[0-9]+(\\.[0-9]+)?$' then trim(@Age_raw)
          else null
        end;

select count(*) from Users;

select * from users;

# Ratings Table
create table Ratings (
	User_ID int unsigned ,
    ISBN varchar(20) ,
    Book_Rating tinyint unsigned
);

describe Ratings;

load data local infile 'C:/Book Recommendation SQL project(Business Insights)/Data/Ratings.csv'
into table Ratings
character set utf8mb4
fields terminated by ',' 
  enclosed by '"' 
  escaped by '"' 
lines terminated by '\n'
ignore 1 lines
(@User_ID_raw, @ISBN_raw, @Book_Rating_raw, @extra)
set
  User_ID = nullif(trim(@User_ID_raw), ''),
  ISBN = nullif(trim(@ISBN_raw), ''),
  Book_Rating = case
                  when trim(@Book_Rating_raw) regexp '^[0-9]+$' then trim(@Book_Rating_raw)
                  else null
                end;

show tables;