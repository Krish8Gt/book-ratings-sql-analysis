# ==============================================================
# Establishing Keys and Relationships
# ==============================================================

# previewing the tables to understand the relationships
select *
from Users_Cleaned
limit 100;

select *
from Books_Cleaned
limit 100;

select *
from Ratings_Cleaned
limit 100;

show tables;

# Inspecting Tables

describe Books_Cleaned;
describe Users_Cleaned;
describe Ratings_Cleaned;

# Defining the Primary Keys

# Users table

alter table Users_Cleaned
add constraint primary key(User_ID);

# Books table

alter table Books_Cleaned
add constraint primary key(ISBN_13);

# Ratings Table

alter table Ratings_Cleaned
add constraint primary key(User_ID ,ISBN_13);

# Foreign Keys

alter table Ratings_Cleaned
add constraint fk_Ratings_User
foreign key(User_ID) references Users_Cleaned(User_ID)
on delete restrict
on update cascade;

alter table Ratings_Cleaned
add constraint fk_Ratings_Book
foreign key(ISBN_13) references Books_Cleaned(ISBN_13)
on delete restrict
on update cascade;

# Table Relationships Fixed Now

# creating finalized tables

create table Users_Final like Users_Cleaned;
create table Books_Final like Books_Cleaned;
create table Ratings_Final like Ratings_Cleaned;

# Inserting data 

insert into Users_Final
select * from Users_Cleaned;

insert into Books_Final
select * from Books_Cleaned;

insert into Ratings_Final
select * from Ratings_Cleaned;

alter table Ratings_Final
add constraint fk_Ratings_Final_User
foreign key (User_ID)
references Users_Final(User_ID)
on delete restrict
on update cascade;

alter table Ratings_Final
add constraint fk_Ratings_Final_Book
foreign key (ISBN_13)
references Books_Final(ISBN_13)
on delete restrict
on update cascade;

show create table ratings_final;

# Database Creation Complete