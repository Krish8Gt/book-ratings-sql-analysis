# ==============================================================
# Validity Check
# ==============================================================

use books_db;

show tables;

# Users Table

describe Users;

select *
from Users;

select *
from Users
where User_ID is null or User_ID = '' or User_ID = 0;

-- No invalid User IDs 

select distinct Location
from Users
where Location is null
	or trim(Location) = ''
    or Location in ('?' ,'N/A' ,'Unknown' ,'.' ,'-' ,'none' );
    
select count(*)
from Users
where Age < 5 or Age > 120;

-- 960 user ids with age lesser than 5 or greater than 120

update Users
set Age = null
where Age < 5 or Age > 120;

# Books Table

describe Books;

select count(*)
from Books
where ISBN is null or trim(ISBN) = '';

-- No Books with invalid ISBN

select count(*)
from Books
where Book_Title is null or trim(Book_Title) = '';

-- No Invalid Book Titles

select count(*)
from Books
where Year_Published < 1950;

-- 293 books published before the 1950 (the year from titles are designated ISBNs)
-- The Year published for these books represent their original Publication date and not their ISBN print date
-- Books published before 1950 will be given historical flag = True

describe Books;

alter table Books 
add column Historical_Flag boolean
default false;

-- Created Historical Filter for ISBNs before the 1950s which feature the publication year of the original IP
-- not the publication year of the ISBN reprint

update Books
set Historical_Flag = true
where Year_Published < 1950 ;

# All historical title - Pre 1950s

select *
from books
where Historical_Flag = true ;

# Checking invalid entries with Year_Published greater than 2025
# Impossible Publication Years in the future

select count(*)
from Books
where Year_Published > 2025;

# Titles with Publication Year after 2025

select *
from Books
where Year_Published > 2025;

update books
set Year_Published = null
where Year_Published > 2025;

-- Titles with Publication Year after 2025 were set to null

# Titles with 0 as publication year

select count(*)
from Books 
where Year_Published = 0;

# Checking Author and Publisher

select *
from Books
where Author is null or trim(Author) = '';

select *
from Books
where trim(Author) = '' ;

# Updating '' Author as Null
update Books
set Author = null
where trim(Author) = ''; 

select *
from Books
where Publisher is null ;

-- 0 entries with null publisher

select *
from Books
where trim(Publisher) = '' ;

# Fixing empty string publishers

update Books
set Publisher = null
where trim(Publisher) = '';

# Ratings Table
describe ratings;

select *
from ratings
where User_ID is null;

-- no Null User_IDs 

select *
from ratings
where User_ID = 0;

-- no invalid user ids with 0

select count(*)
from ratings
where ISBN is null or trim(ISBN) = '';

-- no invalid ISBNs (null or empty strings) in the ratings table

select *
from ratings
where Book_Rating is null;

-- no null ratings in the table

select *
from ratings 
where Book_Rating > 10 or Book_Rating < 0;

-- no Invalid ratings > 10 or < 0

# check Ratings by users who dont exist

select count(*) 
from Ratings as r
left join Users as u
on r.User_ID = u.User_ID
where u.User_ID is null;

-- 0 ratings by non- existent users

# another way?
select count(distinct User_ID)
from Ratings
where User_ID in (select User_ID from Users);	

# Check Ratings on books that might not exist

select count(*)
from Ratings as r
left join Books as b
on r.ISBN = b.ISBN
where r.ISBN is null;

-- 0 ratings by users on non existent books

# Fixing Duplicates in all tables

select User_ID ,ISBN ,count(*) as Dup_Count
from Ratings
group by User_ID ,ISBN
having count(*) > 1;

-- 0 duplicate ratings for the same user and same book

# Users

select User_ID ,count(*) as Dup_Count
from Users
group by User_ID
having Dup_Count > 1;

-- No Duplicate Users in the Users Table

# Books Table
select ISBN ,count(*) as Dup_Count
from Books
group by ISBN
having Dup_Count > 1;

-- Duplicate Book Entries exist

select count(*)
from (
	select ISBN ,count(*) as Dup_Count
	from Books
	group by ISBN
	having Dup_Count > 1
) as Dup;

-- 314 Book entries that have duplicate records

# Taking Backup of Books table before making any changes

describe Books;

# Preview the number of entries that have exact duplicates

select count(*) as will_be_deleted
from Books as b1
join Books as b2
	on lower(b1.ISBN) = lower(b2.ISBN)
    and b1.Book_Title = b2.Book_Title
    and b1.Author = b2.Author
    and b1.Year_Published = b2.Year_Published
    and b1.Publisher = b2.Publisher
    and binary b1.ISBN > binary b2.ISBN;
    
# Preview the exact duplicate entries that will be deleted (the lowercase x copies)

select b1.*
from Books as b1
join Books as b2
	on lower(b1.ISBN) = lower(b2.ISBN)
    and b1.Book_Title = b2.Book_Title
    and b1.Author = b2.Author
    and b1.Year_Published = b2.Year_Published
    and b1.Publisher = b2.Publisher
    and binary b1.ISBN > binary b2.ISBN;
    
# Create a temporary table to make a list of ISBNs to be deleted

create temporary table To_Delete as 
select b1.ISBN
from Books b1
join Books b2
	on lower(b1.ISBN) = lower(b2.ISBN)
    and b1.Book_Title = b2.Book_Title
    and b1.Author = b2.Author
    and b1.Year_Published = b2.Year_Published
    and b1.Publisher = b2.Publisher
    and binary b1.ISBN > binary b2.ISBN;

# verify that there are 306 entries
select count(*)
from To_Delete;

# Delete entries in Books which match in the temporary table
delete b
from books b
join To_Delete t
	on binary b.ISBN = binary t.ISBN;
    
select count(*)
from Books;

# Drop the temporary table

drop temporary table To_Delete;

# 8 more duplicate entries left

# Previewing the uppercase and lowercase entries

select b1.*
from Books b1
join Books b2
	on lower(b1.ISBN) = lower(b2.ISBN)
    and binary b1.ISBN > binary b2.ISBN;
    
select b1.*
from Books b1
join Books b2
	on lower(b1.ISBN) = lower(b2.ISBN)
    and binary b1.ISBN < binary b2.ISBN;


-- Previewed both tables and confirmed that there is no difference between the remaining 8 entries and their respective duplicates
-- So in the remaining 8 entries both uppercase ISBNs and lowercase ISBNs contain the same amount of info
-- Except the uppercase and lowercase ISBNs
-- So the lowercase entries can safely be deleted 
    
# Creating temporary table to capture the lowercase entries
create temporary table To_Delete as
select b1.ISBN
from Books b1
join Books b2
	on lower(b1.ISBN) = lower(b2.ISBN)
    and binary b1.ISBN > binary b2.ISBN;
   
# Previewing the temp table once
select *
from To_Delete;

# deleting the lowercase ISBNs
delete b
from Books b
join To_Delete t
	on binary b.ISBN = binary t.ISBN;
    
drop temporary table To_Delete;

# Books Table cleaned 

# Now Confirming the total number of records
select count(*)
from Books;
-- as 271046 

# Now confirming that the total number of unique ISBNs also
select count(distinct ISBN)
from Books;
-- as 271046
    
describe Ratings;

select count(*)
from(
	select User_ID ,ISBN
	from Ratings
	group by User_ID ,ISBN
)as Unique_Reviews;

select count(*)
from Ratings;

-- Totally 11,49,780 Unique Reviews

select count(*) from Books;
select count(*) from Users;
select count(*) from Ratings;

show tables;

select *
from Books
where ISBN like '% %';

select *
from Books
where ISBN like '% %';

select *
from Books
where ISBN like '%-%';

select count(*)
from books
where ISBN like '% %' or ISBN like '%-%';

-- 2 entries with spaces and hyphens in Books table

# ISBN formats in Books
select
	length(regexp_replace(ISBN ,'[^0-9Xx]' ,'' )) as digit_length ,
    count(*) as Number_Of_Entries
from Books
group by digit_length
order by digit_length desc;

# ISBN formats in Ratings
select
	length(regexp_replace(ISBN ,'[^0-9Xx]' ,'' )) as digit_length ,
    count(*) as Number_Of_Entries
from Ratings
group by digit_length
order by digit_length desc;

# Previewing the upper cases and lower cases ISBNs in Books
select count(*)
from Books
where regexp_like(regexp_replace(ISBN ,'[^0-9Xx]' ,'' ) ,'X$' ,'c' );

select count(*)
from Books
where regexp_like(regexp_replace(ISBN ,'[^0-9Xx]' ,'' ) ,'x$' ,'c' );

-- 97 entries with lowercase x


# Standardizing lowercase xs to Xs in Books

update Books
set ISBN = upper(ISBN);

select count(*)
from Books
where regexp_like(ISBN ,'[a-z]' ,'c' );

-- No more lowercase Xs in ISBNs in Books Table

# Checking the Lowercase X entries in Ratings table
select count(*)
from Ratings
where regexp_like(regexp_replace(ISBN ,'[^0-9Xx]' ,'' ) ,'x$' ,'c' );

select count(*)
from Ratings
where regexp_like(ISBN ,'[a-z]' ,'c' );

-- 593 entries with lowercase x

# Converting the lowercase xs in Ratings to Uppercases

update Ratings
set ISBN = upper(ISBN);

# Searching for Entries in Books with Junk

select *
from Books
where ISBN regexp '[^0-9X]';

select ISBN
from Books
where ISBN regexp '[^0-9X]'
limit 118;

select count(*)
from Books
where ISBN regexp '[^0-9X]';

-- 118 Entries with Junk in ISBN

# Searching for Entries in Ratings with Junk

select *
from Ratings
where ISBN regexp '[^0-9X]';

select ISBN
from Ratings
where ISBN regexp '[^0-9X]'
limit 2436;

select count(*)
from Ratings
where ISBN regexp '[^0-9X]';

-- 2436 Entries with Junk in ISBN

show tables;

alter table Books
add column ISBN_clean varchar(20),
add column ISBN_13 varchar(13);

alter table Ratings
add column ISBN_clean varchar(20),
add column ISBN_13 varchar(13);

update Books
set ISBN_clean = regexp_replace(ISBN ,'[^0-9X]' ,'' );

update Ratings
set ISBN_clean = regexp_replace(ISBN ,'[^0-9X]' ,'' );

select * from Books;
select * from Ratings;

select count(*)
from Books
where ISBN_clean regexp '[^0-9X]';

select count(*)
from Ratings
where ISBN_clean regexp '[^0-9X]';

# Checking the ISBN digit distributions
select 
	length(ISBN_clean) as ISBN_Length,
    count(*) as Number_Entries
from books
group by ISBN_Length
order by ISBN_Length desc;

select 
	length(ISBN_clean) as ISBN_Length,
    count(*) as Number_Entries
from Ratings
group by ISBN_Length
order by ISBN_Length desc;

# Populating ISBN_13 column with 13 digit clean strings
# none expected based on digit distributions
update Books
set ISBN_13 = ISBN_clean
where length(ISBN_clean) = 13;

update Ratings
set ISBN_13 = ISBN_clean
where length(ISBN_clean) = 13;

# Converting 10 digit cleaned strings to valid 13 digit ISBNs

select count(*) as Valid_10_digit_ISBN
from Ratings
where
	ISBN_13 is null 
    and ISBN_clean regexp '^[0-9]{9}[0-9X]$';

# previewing the 10 digit entries in ratings that pass checksum test
select count(*) as valid_isbn10_checksum
from ratings
where
  ISBN_13 is null
  and ISBN_clean regexp '^[0-9]{9}[0-9X]$'
  and (
    (
      1 * substring(ISBN_clean,1,1) +
      2 * substring(ISBN_clean,2,1) +
      3 * substring(ISBN_clean,3,1) +
      4 * substring(ISBN_clean,4,1) +
      5 * substring(ISBN_clean,5,1) +
      6 * substring(ISBN_clean,6,1) +
      7 * substring(ISBN_clean,7,1) +
      8 * substring(ISBN_clean,8,1) +
      9 * substring(ISBN_clean,9,1) +
      10 * case
            when right(ISBN_clean,1) = 'X' then 10
            else right(ISBN_clean,1)
          end
    ) % 11 = 0
  );

# populating ISBN_13 column with 10 digit ISBNs after prefix them with 978 and dropping the last digit
# The Standard procedure to convert 10 digit ISBNs to 13 Digit format is
# Remove the last digit which is the checksum digit for 10 digit format

update Ratings
set ISBN_13 = concat('978', substring(ISBN_clean, 1, 9))
where
    ISBN_13 is null
    and ISBN_clean regexp '^[0-9]{9}[0-9X]$'
    and (
        (
            1 * substring(ISBN_clean, 1, 1) +
            2 * substring(ISBN_clean, 2, 1) +
            3 * substring(ISBN_clean, 3, 1) +
            4 * substring(ISBN_clean, 4, 1) +
            5 * substring(ISBN_clean, 5, 1) +
            6 * substring(ISBN_clean, 6, 1) +
            7 * substring(ISBN_clean, 7, 1) +
            8 * substring(ISBN_clean, 8, 1) +
            9 * substring(ISBN_clean, 9, 1) +
            10 * case
                    when right(ISBN_clean, 1) = 'X' then 10
                    else right(ISBN_clean, 1)
                 end
        ) % 11 = 0
    );

# The last digit viz the checksum digit for 13 digit format is appended to these 12 digit codes
update Ratings
set ISBN_13 = concat(
    ISBN_13,
    (
        (10 - (
            (
                1 * substring(ISBN_13, 1, 1) +
                3 * substring(ISBN_13, 2, 1) +
                1 * substring(ISBN_13, 3, 1) +
                3 * substring(ISBN_13, 4, 1) +
                1 * substring(ISBN_13, 5, 1) +
                3 * substring(ISBN_13, 6, 1) +
                1 * substring(ISBN_13, 7, 1) +
                3 * substring(ISBN_13, 8, 1) +
                1 * substring(ISBN_13, 9, 1) +
                3 * substring(ISBN_13, 10, 1) +
                1 * substring(ISBN_13, 11, 1) +
                3 * substring(ISBN_13, 12, 1)
            ) % 10
        )) % 10
    )
)
where
    length(ISBN_13) = 12;

# Previewing the number of illegitimate 13 digit codes of the first cleaned 13 digit strings that were taken from ISBN_clean column
select
    count(*)
from Ratings
where
    length(ISBN_13) = 13
    and ISBN_13 not regexp '^978'
    and (
        (
            1 * substring(ISBN_13, 1, 1) +
            3 * substring(ISBN_13, 2, 1) +
            1 * substring(ISBN_13, 3, 1) +
            3 * substring(ISBN_13, 4, 1) +
            1 * substring(ISBN_13, 5, 1) +
            3 * substring(ISBN_13, 6, 1) +
            1 * substring(ISBN_13, 7, 1) +
            3 * substring(ISBN_13, 8, 1) +
            1 * substring(ISBN_13, 9, 1) +
            3 * substring(ISBN_13, 10, 1) +
            1 * substring(ISBN_13, 11, 1) +
            3 * substring(ISBN_13, 12, 1)
        ) % 10
    ) != right(ISBN_13, 1);
    
# Deleting them
delete
from ratings
where
    length(ISBN_13) = 13
    and ISBN_13 not regexp '^978'
    and ISBN_13 regexp '^[0-9]{13}$'
    and (
        (
            1 * substring(ISBN_13, 1, 1) +
            3 * substring(ISBN_13, 2, 1) +
            1 * substring(ISBN_13, 3, 1) +
            3 * substring(ISBN_13, 4, 1) +
            1 * substring(ISBN_13, 5, 1) +
            3 * substring(ISBN_13, 6, 1) +
            1 * substring(ISBN_13, 7, 1) +
            3 * substring(ISBN_13, 8, 1) +
            1 * substring(ISBN_13, 9, 1) +
            3 * substring(ISBN_13, 10, 1) +
            1 * substring(ISBN_13, 11, 1) +
            3 * substring(ISBN_13, 12, 1)
        ) % 10
    ) != right(ISBN_13, 1);    

# legitimate 13 Digit ISBNs dont have X anywhere
select count(*)
from ratings
where
    length(isbn_13) = 13
    and isbn_13 regexp 'X';

# deleting them
delete 
from Ratings
where
	length(ISBN_13) = 13
    and ISBN_13 regexp 'X';
    
# Number of Ratings for invalid Books i.e the Codes for books that failed all these tests
select count(*)
from ratings
where isbn_13 is null;

# The Entries that failed the ISBN legitimacy check
select
    length(isbn_clean) as len,
    count(*) as cnt
from ratings
where isbn_13 is null
group by length(isbn_clean)
order by len;

# Deleting the Ratings for invalid books

delete
from Ratings
where ISBN_13 is null;

select count(*)
from Ratings
where ISBN_13 is null;

select count(*) from Ratings where length(ISBN_13) != 13;

select count(*) from Ratings where ISBN_13 regexp '[^0-9]';

select count(*) from Ratings where ISBN_13 regexp '[^0-9]{13}$';

select count(*) from Ratings;

show tables;

# Ratings table has been cleaned

# checking for duplicate ratings again

select count(*)
from(
select
	User_ID,
    ISBN_13,
	count(*) as dup
from Ratings
group by User_ID ,ISBN_13
having dup > 1
order by dup desc
)t;

create temporary table Ratings_Dedup as
select
	User_ID ,
    ISBN_13 ,
    min(ISBN) as ISBN ,
    min(Book_Rating) as Book_Rating ,
    min(ISBN_clean) as ISBN_clean
from Ratings
group by User_ID ,ISBN_13;

# checking if the temp table has any dups
select count(*)
from(
select
	User_ID ,
    ISBN_13
from Ratings_Dedup
group by User_ID ,ISBN_13
having count(*) > 1
)t;

# Previewing before and after counts
select count(*) from Ratings;
select count(*) from Ratings_Dedup;

# Emptying Ratings Table
truncate table Ratings;

# Refilling Ratings with cleaned records
insert into Ratings(User_ID ,ISBN ,Book_Rating ,ISBN_clean ,ISBN_13 )
select
	User_ID ,
    ISBN ,
    Book_Rating ,
    ISBN_clean ,
    ISBN_13
from Ratings_Dedup;

select count(*) from Ratings;

# Rechecking dups
select count(*)
from(
select
	User_ID ,
    ISBN_13
from Ratings
group by User_ID ,ISBN_13
having count(*) > 1
)t;

# Cleaning Database
drop temporary table Ratings_Dedup;

# Cleaning the Books Table

describe Books;

# Sanity checks

select count(*)
from Books
where ISBN_clean is not null;

select
	length(ISBN_clean) as Digit_Format ,
    count(*) as Number_Entries
from Books
group by Digit_Format
order by Digit_Format desc;

select count(*)
from Books
where ISBN_clean regexp '[^0-9X]';

# Checking how many of the ISBN_clean entries in Books have valid 10 digit ISBN format

select count(*) as valid_10_Digit_ISBN
from Books
where 
	ISBN_13 is null
    and ISBN_clean regexp '^[0-9]{9}[0-9X]$';
    
-- 270929 of the entries in ISBN_clean in Books are in a proper valid ISBN format
    
# Previewing which of these Entries will pass the 10 digit Checksum test

select count(*) as valid_isbn10_checksum
from Books
where
	ISBN_13 is null
    and ISBN_clean regexp '^[0-9]{9}[0-9X]$'
    and (
	(
		1 * substring(ISBN_clean ,1 ,1 ) +
		2 * substring(ISBN_clean ,2 ,1 ) +
		3 * substring(ISBN_clean ,3 ,1 ) +
		4 * substring(ISBN_clean ,4 ,1 ) +
		5 * substring(ISBN_clean ,5 ,1 ) +
		6 * substring(ISBN_clean ,6 ,1 ) +
		7 * substring(ISBN_clean ,7 ,1 ) +
		8 * substring(ISBN_clean ,8 ,1 ) +
		9 * substring(ISBN_clean ,9 ,1 ) +
		10 * case
				when right(ISBN_clean ,1 ) = 'X' then 10
				else right(ISBN_clean ,1 )
		     end
	) % 11 = 0
);

-- all 270929 ISBN_clean entries passed the checksum test

# Convert these 10 digit ratings to ISBN13 standard
# No need for the and (
#	(
#		1 * substring(ISBN_clean ,1 ,1 ) +
#		2 * substring(ISBN_clean ,2 ,1 ) +
#		3 * substring(ISBN_clean ,3 ,1 ) +
#		4 * substring(ISBN_clean ,4 ,1 ) +
#		5 * substring(ISBN_clean ,5 ,1 ) +
#		6 * substring(ISBN_clean ,6 ,1 ) +
#		7 * substring(ISBN_clean ,7 ,1 ) +
#		8 * substring(ISBN_clean ,8 ,1 ) +
#		9 * substring(ISBN_clean ,9 ,1 ) +
#		10 * case
#				when right(ISBN_clean ,1 ) = 'X' then 10
#				else right(ISBN_clean ,1 )
#		     end
#	) % 11 = 0
# Because we have verified that all ISBN_cleans with '^[0-9]{9}[0-9X]$' ISBN10 format have valid ISBN10 checksums

update Books
set ISBN_13 = concat('978' ,substring(ISBN_clean ,1 ,9 ) )
where
	ISBN_13 is null 
    and ISBN_clean regexp '^[0-9]{9}[0-9X]$';
    
-- 270929 rows affected - confirmed

# Now we will give the 13th digit i.e checksum digit to these newly converted 10 digit ISBNs with 978 prefixed to them

# Confirming that all 12 digit ISBNs in ISBN_13 columns were the 10 digit ones that were newly prefixed with 978
select count(*)
from Books
where length(ISBN_13) = 12;

update Books
set ISBN_13 = concat(
    ISBN_13,
    (
        (10 - (
            (
                1 * substring(ISBN_13, 1, 1) +
                3 * substring(ISBN_13, 2, 1) +
                1 * substring(ISBN_13, 3, 1) +
                3 * substring(ISBN_13, 4, 1) +
                1 * substring(ISBN_13, 5, 1) +
                3 * substring(ISBN_13, 6, 1) +
                1 * substring(ISBN_13, 7, 1) +
                3 * substring(ISBN_13, 8, 1) +
                1 * substring(ISBN_13, 9, 1) +
                3 * substring(ISBN_13, 10, 1) +
                1 * substring(ISBN_13, 11, 1) +
                3 * substring(ISBN_13, 12, 1)
            ) % 10
        )) % 10
    )
)
where
    length(ISBN_13) = 12;
	
# Sanity check
select length(ISBN_13), count(*)
from books
group by length(ISBN_13);

# Previewing the number of illegitimate 13 digit codes of the first cleaned 13 digit strings that were taken from ISBN_clean column
select count(*) as invalid_isbn13_group_a
from Books
where
    ISBN_13 is not null
    and ISBN_13 not regexp '^978'
    and ISBN_13 regexp '^[0-9]{13}$'
    and (
        (
            1 * substring(ISBN_13, 1, 1) +
            3 * substring(ISBN_13, 2, 1) +
            1 * substring(ISBN_13, 3, 1) +
            3 * substring(ISBN_13, 4, 1) +
            1 * substring(ISBN_13, 5, 1) +
            3 * substring(ISBN_13, 6, 1) +
            1 * substring(ISBN_13, 7, 1) +
            3 * substring(ISBN_13, 8, 1) +
            1 * substring(ISBN_13, 9, 1) +
            3 * substring(ISBN_13, 10, 1) +
            1 * substring(ISBN_13, 11, 1) +
            3 * substring(ISBN_13, 12, 1)
        ) % 10
    ) != right(ISBN_13, 1);
    
    -- 0 counts
    
# Doing a final check on all 13 digit codes in the column one last time
    
select count(*) as invalid_isbn13_any
from Books
where
    ISBN_13 regexp '^[0-9]{13}$'
    and (
        (
            10 - (
                (
                    1 * substring(ISBN_13, 1, 1) +
                    3 * substring(ISBN_13, 2, 1) +
                    1 * substring(ISBN_13, 3, 1) +
                    3 * substring(ISBN_13, 4, 1) +
                    1 * substring(ISBN_13, 5, 1) +
                    3 * substring(ISBN_13, 6, 1) +
                    1 * substring(ISBN_13, 7, 1) +
                    3 * substring(ISBN_13, 8, 1) +
                    1 * substring(ISBN_13, 9, 1) +
                    3 * substring(ISBN_13, 10, 1) +
                    1 * substring(ISBN_13, 11, 1) +
                    3 * substring(ISBN_13, 12, 1)
                ) % 10
            )
        ) % 10
    ) != right(ISBN_13, 1);

-- Confirmed all 13 digit codes in ISBN_13 are now in perfectly valid ISBN13 format

# Rechecking the nulls in ISBN_13 column
select count(*)
from Books
where ISBN_13 is null;

# Confirming length wise
select
	length(ISBN_13) as Format_type ,
    count(*) as No_Entries
from Books
group by Format_type
order by No_Entries desc;

# Deleting them
delete
from Books
where ISBN_13 is null;

-- Deleted all Book Entries with unverifiable ISBNs - 117

# Checking if every Rating in Ratings Table points to a valid Book in Books Table now

select count(*) as Orphan_Ratings
from Ratings r
left join Books b
	on r.ISBN_13 = b.ISBN_13
where b.ISBN_13 is null;

select count(*)
from ratings r
left join books b
  on r.isbn_13 = b.isbn_13
where r.isbn_13 is not null
  and b.isbn_13 is null;

-- 1,03,725 Ratings on Books that do not exist 

# deleting Orphan Ratings in the Ratings Table to enforce Referential Integrity

delete r
from Ratings r
left join Books b
	on r.ISBN_13 = b.ISBN_13
where b.ISBN_13 is null;
-- This query takes forever to Run and execute

# Temporary method instead
create temporary table Orphan_Ratings as 
select distinct r.ISBN_13
from Ratings r
left join Books b
	on r.ISBN_13 = b.ISBN_13
where b.ISBN_13 is null;

# Now deleting entries from Ratings whose ISBN_13 are present in Orphan_Ratings temporary table
delete 
from Ratings
where ISBN_13 in (
	select ISBN_13
    from Orphan_Ratings
);

-- Again this query takes forever to run

# There is one duplicate ISBN_13 in Books

select *
from Books
where isbn_13 = '9780486404240';

delete
from Books
where ISBN_13 = '9780486404240'
limit 1;

select count(*)
from Books;

select count(distinct ISBN_13)
from Books;

# Ensuring unique ISBN_13
select ISBN_13, count(*)
from Books
group by ISBN_13
having count(*) > 1;

# Ensuring There are no duplicate ISBN_13s anymore
alter table Books
add unique(ISBN_13);

create table Ratings_Cleaned like Ratings;

insert into Ratings_Cleaned
select r.*
from ratings r
join Books b
  on r.ISBN_13 = b.ISBN_13;

select count(*) from Ratings_Cleaned;
select count(*) from Ratings;

select count(*)
from Ratings_Cleaned r
left join Books b
  on r.ISBN_13 = b.ISBN_13
where b.ISBN_13 is null;

rename table 
	Ratings to Ratings_Old ,
    Ratings_Cleaned to Ratings;

select count(*) from Ratings;

drop table Ratings_Old;

show tables;

# Making Backups ,because this amount of cleaned data is workable
create table if not exists Books_Backup as select * from Books;
create table if not exists Users_Backup as select * from Users;
create table if not exists Ratings_backup as select * from Ratings;

# Going a step further
# Checking Authors whose current format doesnt match their trimmed versions(with leading and trailing spaces removed) and have multiple spaces inside their names
select Author
from Books
where Author <> Trim(Author)
   or Author regexp '  +';
  
# Previewing Counts of such Authors
select count(*)
from Books
where Author <> Trim(Author)
   or Author regexp '  +';

-- 1313 such authors

# Previewing them before and after replacement
select
  Author as before_replace,
  trim(
    regexp_replace(Author, '  +', ' ')
  ) as after_replace
from Books
where Author <> trim(Author)
   or Author regexp '  +'
limit 1314;

# Updating these rows
update Books
set Author = trim(regexp_replace(Author ,'  +' ,' ' ))
where 
	Author <> trim(Author) 
	or Author regexp '  +';

# Checking remaining dirty names
select count(*) as remaining_dirty
from Books
where Author <> trim(Author)
   or Author regexp '  +';
  
# Checking problematic 5 Author names
select
  Author,
  length(Author) as len,
  length(replace(Author, ' ', '')) as len_no_space
from Books
where Author like '%  %';

# Cleaning those 5 names 
update Books
set Author = trim(
  regexp_replace(
    regexp_replace(Author, '[[:space:]]+', ' '),
    ' +', ' '
  )
)
where Author regexp '[[:space:]]{2,}';

# Final check on Author
select count(*)
from Books
where Author regexp '[[:space:]]{2,}';

# Lightweight Cleaning on Book_Title

select Book_Title
from Books
where Book_Title <> Trim(Book_Title)
   or Book_Title regexp '  +';
   
select count(*)
from Books
where Book_Title <> Trim(Book_Title)
   or Book_Title regexp '  +';

update Books
set Book_Title = trim(regexp_replace(Book_Title ,'  +' ,' ' ))
where
	Book_Title <> trim(Book_Title)
    or Book_Title regexp '  +';

# Comparing Cleaned and Uncleaned Book_Title
select
	b1.Book_Title as Before_Cleaning ,
    b2.Book_Title as After_Cleaning
from Books_Backup b1
join Books b2
	on b1.ISBN_13 = b2.ISBN_13
where 
	b1.Book_Title <> trim(b1.Book_Title)
    or b1.Book_Title regexp '  +'
limit 2284;
    
# Lightweight Cleaning on Publisher

select Publisher
from Books
where
	Publisher <> trim(Publisher)
    or Publisher regexp '  +';
    
select count(*)
from Books
where
	Publisher <> trim(Publisher)
    or Publisher regexp '  +';

select count(*)
from Books
where Publisher regexp '  +';
    
# Trimming them and cleaning the strings
update Books
set Publisher = trim(regexp_replace(Publisher ,'  +' ,' ' ))
where
	Publisher <> trim(Publisher)
    or Publisher regexp '  +';

# Comparing them
select
	b1.Publisher as Before_Cleaning ,
    b2.Publisher as After_Cleaning
from Books_Backup b1
join Books b2
	on b1.ISBN_13 = b2.ISBN_13
where 
	b1.Publisher <> trim(b1.Publisher)
    or b1.Publisher regexp '  +';

# Lightweight Cleaning on Location

select Location
from Users
where
	Location <> trim(Location)
    or Location regexp '  +';
    
select count(*)
from Users
where
	Location <> trim(Location)
    or Location regexp '  +';
    
update Users
set Location = trim(regexp_replace(Location ,'  +' ,' ' ))
where
	Location <> trim(Location)
    or Location regexp '  +';

# Comparing them     
select
	b1.Location as Before_Cleaning ,
    b2.Location as After_Cleaning
from Users_Backup b1
join Users b2
	on b1.User_ID = b2.User_ID
where 
	b1.Location <> trim(b1.Location)
    or b1.Location regexp '  +';

# Creating Country Field from Location field for better further analysis
alter table Users
add column Country varchar(100);

# Extracting the last word after the second comma as the Country
update Users
set Country = trim(substring_index(Location ,',' ,-1 ))
where Location is not null;


# Looking for All possible unnecessary whitespaces including NBSPs
select count(*) as country_whitespace_issues
from Users
where Country is not null
  and Country <> trim(
        regexp_replace(Country, '[[:space:]]+', ' ')
      );
	
# Looking for All possible unnecessary whitespaces including NBSPs
select count(*) as author_whitespace_issues
from Books
where Author is not null
  and Author <> trim(
        regexp_replace(Author, '[[:space:]]+', ' ')
      );

# Looking for All possible unnecessary whitespaces including NBSPs      
select count(*) as book_title_whitespace_issues
from Books
where Book_Title is not null
  and Book_Title <> trim(
        regexp_replace(Book_Title, '[[:space:]]+', ' ')
      );
      
# Removing NBSPs in Author column
# Previewing the entries
select *
from Books 
where
	Author is not null
	and Author <> trim(regexp_replace(Author ,'[[:space:]]+' ,' ' ));

# Cleaning them
update Books
set Author = trim(regexp_replace(Author ,'[[:space:]]+' ,' ' ))
where
	Author is not null
    and Author <> trim(regexp_replace(Author ,'[[:space:]]+' ,' ' ));

SELECT
  Country,
  COUNT(*) AS cnt
FROM Users
WHERE Country IS NOT NULL
GROUP BY Country
ORDER BY Country
limit 708;

# Light weight cleaning Country column

# CATEGORY 1 — Empty / placeholders / explicit “no data”
select count(*) as cnt_placeholder
from Users
where Country is not null
  and lower(trim(Country)) in (
    '',
    'na',
    'n/a',
    'n/a - on the road',
    'none',
    'unknown',
    '?',
    '-',
    '-------'
  );
  
update Users
set Country = null
where Country is not null
  and lower(trim(Country)) in (
    '',
    'na',
    'n/a',
    'n/a - on the road',
    'none',
    'unknown',
    '?',
    '-',
    '-------'
  );

# CATEGORY 2 — Pure punctuation / symbols / quote junk
select count(*) as cnt_symbols_only
from Users
where Country is not null
  and Country regexp '^[^a-zA-Z0-9]+$';

update Users
set Country = null
where Country is not null
  and Country regexp '^[^a-zA-Z0-9]+$';
  
# CATEGORY 3 — HTML entities / encoding garbage
select count(*) as cnt_encoding_junk
from Users
where Country is not null
  and (
       Country regexp '&#[0-9]+;'
    or Country regexp '[Ã¤Ã¥Ã¶Ã¸]'
    or Country regexp 'ä¸'
  );

update Users
set Country = null
where Country is not null
  and (
       Country regexp '&#[0-9]+;'
    or Country regexp '[Ã¤Ã¥Ã¶Ã¸]'
    or Country regexp 'ä¸'
  );
  
# CATEGORY 4 — Pure numeric values (ZIPs, codes)
select count(*) as cnt_numeric_only
from Users
where Country is not null
  and Country regexp '^[0-9]+$';

update Users
set Country = null
where Country is not null
  and Country regexp '^[0-9]+$';

# CATEGORY 5 — Alphanumeric garbage (no vowels)
select count(*) as cnt_gibberish
from Users
where Country is not null
  and Country regexp '^[a-zA-Z0-9]{2,}$'
  and Country not regexp '[aeiouAEIOU]';
  
update Users
set Country = null
where Country is not null
  and Country regexp '^[a-zA-Z0-9]{2,}$'
  and Country not regexp '[aeiouAEIOU]';

# CATEGORY 6 — Single-character values
select count(*) as cnt_single_char
from Users
where Country is not null
  and length(trim(Country)) = 1;
  
update Users
set Country = null
where Country is not null
  and length(trim(Country)) = 1;


select
	Country ,
    count(*)
from Users
where Country is not null
group by Country
order by Country;

select count(*)
from(
select distinct Country
from Users
where Country regexp '"$')c;

select count(*)
from Users
where Country regexp '"$';

select distinct Country
from Users
where Country regexp 'n/a';

select count(*) as cnt_na_garbage
from Users
where Country regexp 'n/a';

update Users
set Country = null
where Country regexp 'n/a';

SELECT COUNT(*)
FROM Users
WHERE Country REGEXP 'n/a';

select count(*)
from (
select distinct Country
from Users
where Country regexp '"$'
order by Country)c;

update Users
set Country = trim(trailing '"' from Country)
where Country regexp '"$';

select count(*)
from(
select distinct Country
from Users
order by Country)c;

select
	Country ,
    count(*)
from Users
group by Country
order by count(*) desc;

select
	Country ,
    count(*)
from Users
group by Country
order by Country;

# Clubbing the Country names for the top 20 Countries

# USA
select Country, count(*) 
from Users
where Country in (
  'usa','us','u.s.a.','u.s.a!','u.s.a','u.s>','u.s. of a.',
  'united states','united states of america',
  'united stated','united staes','united sates',
  'good old u.s.a.','good old usa !','wonderful usa'
)
group by Country
order by count(*) desc;

select count(*)
from Users
where Country in (
  'usa','us','u.s.a.','u.s.a!','u.s.a','u.s>','u.s. of a.',
  'united states','united states of america',
  'united stated','united staes','united sates',
  'good old u.s.a.','good old usa !','wonderful usa'
);

update Users
set Country = 'united states'
where Country in (
  'usa','us','u.s.a.','u.s.a!','u.s.a','u.s>','u.s. of a.',
  'united states','united states of america',
  'united stated','united staes','united sates',
  'good old u.s.a.','good old usa !','wonderful usa'
);

# UK

select count(*)
from Users
where Country in (
  'uk','u k','u.k.','u.k',
  'united kingdom','united kingdom.',
  'united kindgdom','united kindgonm'
);

select Country, count(*) 
from Users
where Country in (
  'uk','u k','u.k.','u.k',
  'united kingdom','united kingdom.',
  'united kindgdom','united kindgonm'
)
group by Country
order by count(*) desc;

update Users
set Country = 'united kingdom'
where Country in (
  'uk','u k','u.k.','u.k',
  'united kingdom','united kingdom.',
  'united kindgdom','united kindgonm'
);

# Germany

select count(*)
from Users
where Country in (
  'germany','geermany','germay','deutschland'
);

select Country, count(*) 
from Users
where Country in (
  'germany','geermany','germay','deutschland'
)
group by Country
order by count(*) desc;

update Users
set Country = 'germany'
where Country in (
  'germany','geermany','germay','deutschland'
);

# Spain

select count(*)
from Users
where Country in (
  'spain','españa'
);

select Country, count(*) 
from Users
where Country in (
  'spain','españa'
)
group by Country
order by count(*) desc;

update Users
set Country = 'spain'
where Country in (
  'spain','españa'
);

# Australia

select count(*)
from Users
where Country in (
  'australia','australii','autralia','austbritania'
);

select Country, count(*) 
from Users
where Country in (
  'australia','australii','autralia','austbritania'
)
group by Country
order by count(*) desc;

update Users
set Country = 'australia'
where Country in (
  'australia','australii','autralia','austbritania'
);

# Italy

select count(*)
from Users
where Country in (
  'italy','italia','italien','itlay'
);

select Country, count(*) 
from Users
where Country in (
  'italy','italia','italien','itlay'
)
group by Country
order by count(*) desc;

update Users
set Country = 'italy'
where Country in (
  'italy','italia','italien','itlay'
);

# France

select count(*)
from Users
where Country in (
  'france','la france'
);

select Country, count(*) 
from Users
where Country in (
  'france','la france'
)
group by Country
order by count(*) desc;

update Users
set Country = 'france'
where Country in (
  'france','la france'
);

# Netherlands

select count(*)
from Users
where Country in (
  'netherlands','the netherlands','nederlands'
);

select Country, count(*) 
from Users
where Country in (
  'netherlands','the netherlands','nederlands'
)
group by Country
order by count(*) desc;

update Users
set Country = 'netherlands'
where Country in (
  'netherlands','the netherlands','nederlands'
);

# Brazil

select count(*)
from Users
where Country in (
  'brazil','brasil','_ brasil'
);

select Country, count(*) 
from Users
where Country in (
  'brazil','brasil','_ brasil'
)
group by Country
order by count(*) desc;

update Users
set Country = 'brazil'
where Country in (
  'brazil','brasil','_ brasil'
);

# China

select count(*)
from Users
where Country in (
  'china',
  'people`s republic of china',
  'china people`s republic',
  'p r china','p.r. china','p.r.c'
);

select Country, count(*) 
from Users
where Country in (
  'china',
  'people`s republic of china',
  'china people`s republic',
  'p r china','p.r. china','p.r.c'
)
group by Country
order by count(*) desc;

update Users
set Country = 'china'
where Country in (
  'china',
  'people`s republic of china',
  'china people`s republic',
  'p r china','p.r. china','p.r.c'
);

# India

select count(*)
from Users
where Country in (
  'india','indiai'
);

select Country, count(*) 
from Users
where Country in (
  'india','indiai'
)
group by Country
order by count(*) desc;

update Users
set Country = 'india'
where Country in (
  'india','indiai'
);

# Sri Lanka

select count(*)
from Users
where Country in (
  'sri lanka','srilanka'
);

select Country, count(*) 
from Users
where Country in (
  'sri lanka','srilanka'
)
group by Country
order by count(*) desc;

update Users
set Country = 'sri lanka'
where Country in (
  'sri lanka','srilanka'
);

# Turkey

select count(*)
from Users
where Country in (
  'turkey','turkei','türkiye'
);

select Country, count(*) 
from Users
where Country in (
  'turkey','turkei','türkiye'
)
group by Country
order by count(*) desc;

update Users
set Country = 'turkey'
where Country in (
  'turkey','turkei','türkiye'
);

# Philippines

select count(*)
from Users
where Country in (
  'philippines','philippine','philippinies',
  'phillipines','phils','phippines'
);

select Country, count(*) 
from Users
where Country in (
  'philippines','philippine','philippinies',
  'phillipines','phils','phippines'
)
group by Country
order by count(*) desc;

update Users
set Country = 'philippines'
where Country in (
  'philippines','philippine','philippinies',
  'phillipines','phils','phippines'
);

# United Arab Emirates

select count(*)
from Users
where Country in (
  'uae','u.a.e','united arab emirates'
);

select Country, count(*) 
from Users
where Country in (
  'uae','u.a.e','united arab emirates'
)
group by Country
order by count(*) desc;

update Users
set Country = 'united arab emirates'
where Country in (
  'uae','u.a.e','united arab emirates'
);

# Switzerland

select count(*)
from Users
where Country in (
  'switzerland','suisse','la suisse','la svizzera'
);

select Country, count(*) 
from Users
where Country in (
  'switzerland','suisse','la suisse','la svizzera'
)
group by Country
order by count(*) desc;

update Users
set Country = 'switzerland'
where Country in (
  'switzerland','suisse','la suisse','la svizzera'
);

# Belgium

select count(*)
from Users
where Country in (
  'belgium','belgi','belgique','la belgique'
);

select Country, count(*) 
from Users
where Country in (
  'belgium','belgi','belgique','la belgique'
)
group by Country
order by count(*) desc;

update Users
set Country = 'belgium'
where Country in (
  'belgium','belgi','belgique','la belgique'
);

# New Zealand

select count(*)
from Users
where Country in (
  'new zealand','newzealand'
);

select Country, count(*) 
from Users
where Country in (
  'new zealand','newzealand'
)
group by Country
order by count(*) desc;

update Users
set Country = 'new zealand'
where Country in (
  'new zealand','newzealand'
);

# Russia

select count(*)
from Users
where Country in (
  'russia','russian federation'
);

select Country, count(*) 
from Users
where Country in (
  'russia','russian federation'
)
group by Country
order by count(*) desc;

update Users
set Country = 'russia'
where Country in (
  'russia','russian federation'
);

# South Korea

select count(*)
from Users
where Country in (
  'south korea','s.corea','republic of korea'
);

select Country, count(*) 
from Users
where Country in (
  'south korea','s.corea','republic of korea'
)
group by Country
order by count(*) desc;

update Users
set Country = 'south korea'
where Country in (
  'south korea','s.corea','republic of korea'
);

# Argentina

select count(*)
from Users
where Country in ('argentina','la argentina');

select Country, count(*) 
from Users
where Country in ('argentina','la argentina')
group by Country
order by count(*) desc;

update Users
set Country = 'argentina'
where Country in ('argentina','la argentina');

# Canada

select count(*)
from Users
where Country in ('canada','le canada','il canada','canada eh');

select Country, count(*) 
from Users
where Country in ('canada','le canada','il canada','canada eh')
group by Country
order by count(*) desc;

update Users
set Country = 'canada'
where Country in ('canada','le canada','il canada','canada eh');

show tables;

# Confirming clean tables
select count(*) from Users;
select count(*) from Books;
select count(*) from Ratings;

# Cleaned Users Table
create table Users_Cleaned (
	User_ID int unsigned not null ,
    Age int unsigned ,
    Country varchar(100)
);

insert into Users_Cleaned (User_ID ,Age ,Country )
select
	User_ID ,
    Age ,
    Country
from Users;

select * from Users_Cleaned;

# Cleaned Books Table

create table Books_Cleaned (
	ISBN_13 varchar(13) not null ,
    Book_Title varchar(500) ,
    Author varchar(255) ,
    Publisher varchar(300) ,
    Year_Published smallint unsigned ,
    Historical_Flag tinyint(1)
);

insert into Books_Cleaned (ISBN_13 ,Book_Title ,Author ,Publisher ,Year_Published ,Historical_Flag )
select
	ISBN_13 ,
    Book_Title ,
    Author ,
    Publisher ,
    Year_Published ,
    Historical_Flag
from Books;

select * from Books_Cleaned;

# Cleaned Ratings Table

create table Ratings_Cleaned (
	User_ID int unsigned not null ,
    ISBN_13 varchar(13) not null ,
    Book_Rating tinyint unsigned
);

insert into Ratings_Cleaned (User_ID ,ISBN_13 ,Book_Rating )
select
	User_ID ,
    ISBN_13 ,
    Book_Rating
from Ratings;

# All 3 tables Cleaned