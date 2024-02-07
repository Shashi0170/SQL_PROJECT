CREATE DATABASE	MUSIC_DATABASE;	
USE MUSIC_DATABASE;
SHOW TABLES;

/* Q1: Who is the senior most employee based on job title? */
SELECT * FROM EMPLOYEE;
SELECT EMPLOYEE_ID,LEVELS,CONCAT(FIRST_NAME,LAST_NAME) NAME FROM EMPLOYEE WHERE LEVELS="L6";
#OR
SELECT EMPLOYEE_ID,LEVELS,CONCAT(FIRST_NAME,LAST_NAME) NAME FROM EMPLOYEE ORDER BY LEVELS DESC LIMIT 1;

/* Q2: Which countries have the most Invoices? */
SELECT * FROM INVOICE;
SELECT BILLING_COUNTRY,COUNT(INVOICE_ID) FROM INVOICE GROUP BY BILLING_COUNTRY ORDER BY COUNT(INVOICE_ID) DESC LIMIT 1 ;

/* Q3: What are top 3 values of total invoice? */
SELECT * FROM INVOICE;
SELECT * FROM 
(SELECT TOTAL,DENSE_RANK()OVER(ORDER BY TOTAL DESC ) AS rnk FROM INVOICE) TEMP WHERE rnk =1 OR rnk =2 OR rnk =3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT * FROM INVOICE;
SELECT BILLING_CITY,SUM(TOTAL) FROM INVOICE GROUP BY BILLING_CITY ORDER BY SUM(TOTAL) DESC LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT * FROM INVOICE;
SELECT * FROM CUSTOMER;

SELECT C.CUSTOMER_ID,SUM(TOTAL),FIRST_NAME FROM INVOICE I JOIN CUSTOMER C ON I.CUSTOMER_ID=C.CUSTOMER_ID 
GROUP BY CUSTOMER_ID,FIRST_NAME ORDER BY SUM(TOTAL) DESC LIMIT 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT * FROM GENRE;

SELECT FIRST_NAME,LAST_NAME,EMAIL FROM CUSTOMER WHERE CUSTOMER_ID IN
(SELECT CUSTOMER_ID FROM INVOICE WHERE INVOICE_ID IN
(SELECT INVOICE_ID FROM INVOICE_LINE WHERE TRACK_ID IN
(SELECT TRACK_ID FROM TRACK WHERE GENRE_ID IN
(SELECT GENRE_ID FROM GENRE WHERE NAME LIKE "ROCK")))) ORDER BY EMAIL;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT * FROM ARTIST;
SELECT * FROM TRACK;

SELECT AR.NAME,ARTIST_ID,COUNT(AR.ARTIST_ID) AS SONG_COUNTS FROM TRACK T 
JOIN ALBUM2 AL USING(ALBUM_ID) 
JOIN ARTIST AR USING(ARTIST_ID)
JOIN GENRE G USING(GENRE_ID) GROUP BY AR.ARTIST_ID,ARTIST_ID,AR.NAME ORDER BY SONG_COUNTS DESC LIMIT 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT * FROM TRACK;

SELECT NAME,MILLISECONDS FROM TRACK WHERE MILLISECONDS >
(SELECT AVG(MILLISECONDS) FROM TRACK) ORDER BY MILLISECONDS DESC;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
SELECT C.FIRST_NAME,C.LAST_NAME,AR.NAME AS ARTIST_NAME,SUM(il.unit_price*il.quantity) AS amount_spent
FROM ARTIST AR JOIN ALBUM2 USING(ARTIST_ID)
JOIN TRACK T USING(ALBUM_ID)
JOIN INVOICE_LINE IL USING(TRACK_ID)
JOIN INVOICE USING(INVOICE_ID)
JOIN CUSTOMER C USING(CUSTOMER_ID) 
GROUP BY C.FIRST_NAME,C.LAST_NAME,AR.NAME
ORDER BY AMOUNT_SPENT DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
SELECT * FROM GENRE;
SELECT * FROM CUSTOMER;
SELECT * FROM TRACK;

WITH POPULAR_GENRE AS (
	SELECT COUNT(IL.QUANTITY) PURCHASE,C.COUNTRY,GENRE_ID,
	ROW_NUMBER()OVER(PARTITION BY C.COUNTRY ORDER BY COUNT(IL.QUANTITY) DESC)  AS ROW_NO
	FROM TRACK T JOIN INVOICE_LINE IL USING(TRACK_ID)
	JOIN INVOICE I USING(INVOICE_ID)
	JOIN CUSTOMER C USING(CUSTOMER_ID)
	GROUP BY C.COUNTRY,GENRE_ID ORDER BY PURCHASE DESC
)
SELECT * FROM POPULAR_GENRE WHERE ROW_NO <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
SELECT * FROM INVOICE;
WITH CUSTOMER AS
(
SELECT C.FIRST_NAME,SUM(TOTAL),BILLING_COUNTRY,
ROW_NUMBER()OVER(PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL)) ROW_NO
FROM INVOICE I JOIN CUSTOMER C USING(CUSTOMER_ID) GROUP BY 
BILLING_COUNTRY,C.FIRST_NAME ORDER BY SUM(TOTAL) DESC
)
SELECT * FROM CUSTOMER WHERE ROW_NO =1;




 
 

