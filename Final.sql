-- #final 

-- PATRONS 
/*******************************************************/
-- How many patrons are registered in the library?
select count(*) from patrons ; -- 100

/* generate a report of showing 10 patrons who have
checked out the fewest books.                          */
select l.bookid  , p.firstname , l.patronid , count(loanid) as total_loans  from loans  as l inner join patrons as p ON p.patronid = l.patronid 
group by l.bookid , l.patronid 
order by total_loans  desc 
limit 10 ;

-- How many unique patrons have borrowed books in the last month?
 select Count(distinct patronid )  as unique_patrons_last_month FROM loans 
 where loandate between '2020-06-01' and '2020-06-30' ; 
 
 -- What is the average number of books borrowed per patron, and how does this vary by demographic?
select patronid , avg(loanid) from loans 
group by patronid ; 

select  
		 concat(firstname , ' ' , lastname ) as fullname ,
         p.email  ,
        count(distinct(l.patronid)) as Total_patrons ,
        count(l.loanid) as tota_loand , 
        count(l.loanid) / nullif(count(distinct(l.patronid)), 0 )  as avgeg
from loans l 
inner join patrons p ON l.patronid = p.patronid 
group by p.email , fullname
order by avgeg desc  ;         
select * from patrons ; 

-- Which patrons have the most overdue books?
select  concat(firstname , lastname ) , p.patronid , count(distinct(bookid )) as OverdueBooks from loans as l 
inner join patrons as p ON l.patronid = p.patronid 
where  returneddate is null  or ReturnedDate  > DueDate
group by p.patronid
order by OverdueBooks desc ;

--
select patronid , count(LoanID) as Total_loans from loans 
group by patronid 
having Total_loans < 20 
order by  Total_loans asc;

select count(patronid) from less_than_avg_borrowed ;

-- membership 
SELECT p.patronid ,
       concat(firstname , ' ' , lastname ) as full_name ,
       p.email , 
	   count(l.loanid)  as Total_loans,
	   min(l.loandate) as first_date , 
       max(l.loandate) as last_date ,
       datediff(max(l.loandate) ,min(l.loandate)  ) as memebership 
from loans  l inner join patrons p ON l.patronid = p.patronid 
group by p.patronid
order by Total_loans desc ;

-- Top Patrons: List patrons with the highest number of loans, which could highlight your most active users.
select patronid   , count(bookid) as total_borrowed  from loans 
group by patronid  
order by total_borrowed  desc ;  

-- Loyalty For Years 
Create view Loyalty_for_years as (
WITH ActiveBorrowing AS (
    SELECT 
        p.patronid ,
    concat(firstname , ' ' , lastname) AS fullName,
    COUNT(p.patronid ) AS borrow_count
    FROM 
        patrons p
    inner JOIN 
        loans l 
    ON 
        p.patronid = l.patronid

    GROUP BY 
        p.patronid 
),
FrequentBorrowing AS (
    SELECT 
        p.patronid ,
        COUNT( p.patronid) AS total_loans
    FROM 
        patrons p
    inner JOIN 
        loans l 
    ON 
        p.patronid = l.patronid

    GROUP BY 
        p.patronid
),
MembershipDuration AS (
    SELECT 
        patronid ,
       memebership  /365 AS years_of_membership
    FROM 
        memberships222 
)
SELECT 
    ab.patronid ,
    
    (ab.borrow_count * 0.5 + fb.total_loans * 0.3 + md.years_of_membership * 0.2) AS loyalty_score
FROM 
    ActiveBorrowing ab
inner JOIN 
    FrequentBorrowing fb 
ON 
    ab.patronid = fb.patronid
inner JOIN 
    MembershipDuration md 
ON 
    ab.patronid = md.patronid
ORDER BY 
    loyalty_score DESC );

 -- Overdue for each patrons
  create view overdue_for_each_patrons as (
  select  loyalty_score , l.patronid ,   
  concat(firstname , ' ' , lastname ) as Fullname
  from loans l 
  inner join patrons  p 
  ON l.patronid = p.patronid
  inner join Loyalty_for_years lfy
  On  lfy.patronid = p.patronid 
  where Returneddate is null 
  order by loyalty_score desc );  
-- BOOKS 
/*******************************************************/
-- How many books are available in the library?
select count(*) from books ; -- 200 

-- What are the most popular books based on loan frequency?
select l.bookid  , b.title,count(l.loanid) as total_frequency  from loans  as l 
inner join  books as b ON b.bookid = l.bookid 
group by l.bookid  
order by total_frequency desc ; 

-- How many books has each patron borrowed?
select patronid   , count(bookid) as total_borrowed  from loans 
group by patronid  
order by total_borrowed  desc ; 
 --  +++ Title
select title , count(loanid ) as Total_Frequency from loans as l 
inner join books as b ON l.bookid = b.bookid 
group by title 
order by Total_Frequency  desc ;

/* create a report to show how many books were 
published each year.                                    */
select published , count(bookid) as total_published from books 
group by published
order by  published  ; 

/* create a report to show 5 most popular Books to check out */
select l.bookid ,b.Title , b.author , b.published ,count(l.loanid) as total_loans from loans  l 
inner join books b ON l.bookid = b.bookid 
group by l.bookid 
order by total_loans  desc 
limit 5 ; 

-- How many books are available for loan versus how many are currently loaned out?
select count(distinct(bookid)) as loaned_books  from loans 
where ReturnedDate is null ;

SELECT COUNT(*) AS AvailableBooks
FROM Books  as b
WHERE NOT EXISTS (
    select * from loans  as l 
    where b.bookid = l.bookid and ( ReturnedDate is null)
);

-- Which books are most frequently returned late?
select * from loans l 
inner join books b ON l.bookid = b.bookid 
where ReturnedDate > duedate or ReturnedDate is NULl  ; 

-- Are there any correlations between the types of books (e.g., genre, author) and loan frequency?
select Author , count(loanid) as count_loa from loans as l 
inner join books as b ON l.bookid = b.bookid 
group by author 
order by count_loa desc 
; 

-- Most Popular Books:
select title , b.Author ,  count(b.bookid ) as nu_o_loand from loans as l 
inner join books as b ON l.bookid = b.bookid 
group by b.title , b.Author
order by nu_o_loand  desc ;

SELECT 
    Books.Title,
    Books.Author,
    COUNT(Loans.BookID) AS LoanCount
FROM 
    Loans
JOIN 
    Books ON Loans.BookID = Books.BookID
GROUP BY 
    Books.Title, Books.Author
ORDER BY 
    LoanCount DESC
limit 10 ;  -- Adjust the limit as needed

-- 1) A. Top 10 Most Popular Books by Circulation
 
select  b.title  , b.bookid  ,
        count(loanid) as Total_loans 
from loans as l 
inner join books as b 
ON  l.bookid = b.bookid  
group by b.title  , b.bookid  
order by  Total_loans   desc 
limit 10 ; 

-- 2) B. Books with Low Circulation 
select  b.title  , b.bookid  ,
        count(loanid) as Total_loans 
from loans as l 
inner join books as b 
ON  l.bookid = b.bookid  
group by b.title  , b.bookid  
having Total_loans <= 5
order by  Total_loans   desc ; 

 -- 3) D. Books by Author by year 
 select * from books ;
  select   Author , published  , count(bookid)   from books 
 group by  Author , published 
 order by Author , published ; 
 
 -- The_Top_3_books
 select l.bookid  , b.title,count(l.loanid) as total_frequency  from loans  as l 
inner join  books as b ON b.bookid = l.bookid 
group by l.bookid  
order by total_frequency desc
limit 3 ;

-- the_most_Author_over_years
select Author , count(l.loanid )as Total_loans_for_Author from books b 
inner join loans l ON b.bookid = l.bookid  
group by Author 
order by Total_loans_for_Author desc  
limit 3 ; 

-- LOANS 
/*******************************************************/

-- How many loans have been made in the last year?
select count(loanid) from loans
where year(loandate) = ( select  max(year(dueDate)) from loans 
) ;

-- What is the average loan duration (from LoanDate to DueDate)?
SELECT Round(AVG(DATEDIFF(DueDate, LoanDate))) AS AverageLoanDuration
FROM Loans ;

-- How many books are overdue?
select count(distinct(bookid )) as OverdueBooks FROM loans 
where  returneddate is null  or ReturnedDate  > DueDate ;

-- Which patrons have the most overdue books?
select  concat(firstname , lastname ) , p.patronid , count(distinct(bookid )) as OverdueBooks from loans as l 
inner join patrons as p ON l.patronid = p.patronid 
where  returneddate is null  or ReturnedDate  > DueDate
group by p.patronid
order by OverdueBooks desc ;
; 

-- What is the average number of books borrowed per patron?
SELECT AVG(COALESCE(BookCount, 0)) AS AverageBooksPerPatron
FROM (
    SELECT p.PatronID, COUNT(l.BookID) AS BookCount
    FROM Patrons p
    LEFT JOIN Loans l ON p.PatronID = l.PatronID
    GROUP BY p.PatronID
) AS PatronBookCounts;

-- What percentage of loans are returned on time?

SELECT 
    (COUNT(CASE 
                WHEN ReturnedDate IS NOT NULL AND ReturnedDate <= DueDate THEN 1
                ELSE NULL
            END) * 100.0) / COUNT(*) AS PercentageReturnedOnTime
FROM Loans;

-- What time of year do most loans occur? (e.g., seasonal trends)

SELECT 
    year(DueDate) AS LoanMonth,
    COUNT(*) AS NumberOfLoans
FROM 
    Loans
GROUP BY 
    LoanMonth
ORDER BY 
    LoanMonth desc ;
    
SELECT 
    CASE 
        WHEN MONTH(DueDate) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(DueDate) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(DueDate) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(DueDate) IN (9, 10, 11) THEN 'Fall'
    END AS LoanSeason,
    COUNT(*) AS NumberOfLoans
FROM 
    Loans
GROUP BY 
    LoanSeason
ORDER BY 
    FIELD(LoanSeason, 'Winter', 'Spring', 'Summer', 'Fall');
    
-- How does the loan frequency change over time? (e.g., month-over-month or year-over-year comparisons)

-- month_over_month 
SELECT 
    year(DueDate) AS LoanMonth,
    COUNT(*) AS NumberOfLoans     FROM Loans
GROUP BY LoanMonth
ORDER BY LoanMonth desc ;
    -- month_over_monthe
select
    year(DueDate) AS Loanyear,     
    Month(DueDate) as LoanMonth,
    COUNT(*) AS NumberOfLoans  FROM Loans
GROUP BY loanyear  , LoanMonth  
ORDER BY loanyear  , LoanMonth   ;
   
-- Loans by Month for each years :
select   month(loandate) as monthly , count(*)  as countly from loans
group by  monthly
order by monthly ; 
       -- 
select   date_format(loandate , '%Y-%m') as monthly , count(*)  as countly from loans
group by  monthly
order by monthly ;    

-- Query to find patrons who have not borrowed any books in the last six months

set @cutoffdate = date_sub(curdate() , interval 6 month ) ;

select count(*) as count_patrons from patrons p 
where  p.patronid   Not in (
 select distinct( l.patronid) from loans l
 where l.loandate >= @cutoffdate 
);

-- What are the characteristics of our most loyal patrons (e.g., demographics, borrowing habits)?
SELECT patronid ,
	   count(loanid)  as Total_loans,
	   min(loandate) as first_date , 
       max(loandate) as last_date ,
       datediff(max(loandate) ,min(loandate)  ) as memebership 
from loans 
group by patronid
having  Total_loans > 20
order by Total_loans desc ; 

SELECT p.patronid ,
       p.firstname ,
       p.lastname ,
       concat(firstname , ' ' , lastname ) as full_name ,
       p.email , 
	   count(l.loanid)  as Total_loans,
	   min(l.loandate) as first_date , 
       max(l.loandate) as last_date ,
       datediff(max(l.loandate) ,min(l.loandate)  ) as memebership 
from loans  l inner join patrons p ON l.patronid = p.patronid 
group by p.patronid
having  Total_loans > 20
order by Total_loans desc ; 


-- What is the turnover rate of books in our inventory?
-- (i.e., how often books are borrowed compared to how long they remain in the library)
SELECT 
    (SELECT COUNT(*) FROM Loans) AS TotalCheckouts,
    (SELECT COUNT(DISTINCT BookID) FROM Books) AS TotalBooks,
    Round((SELECT COUNT(*) FROM Loans) / NULLIF((SELECT COUNT(DISTINCT BookID) FROM Books), 0)) AS TurnoverRate ;