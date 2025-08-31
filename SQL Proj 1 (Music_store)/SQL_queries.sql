Q1: Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1


Q2: Which country have the most invoices?

select billing_country, count(*) as count from invoice
group by billing_country
order by count desc
limit 1


Q3: What are top 3 values of total invoices?

select total from invoice
order by total desc
limit 


Q4: Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals.

select billing_city, sum(total) as total from invoice
group by billing_city
order by total desc
limit 1


Q5: Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money.

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total 
from invoice i
join customer c on c.customer_id = i.customer_id
group by c.customer_id
order by total desc
limit 1


Q6: Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A.

Solution 1:

with customer_track as (
	select i.customer_id, il.track_id
	from invoice i
	join invoice_line il on il.invoice_id = i.invoice_id),

customer_genre as (
	select ct.customer_id, t.genre_id
	from customer_track as ct
	join track t on t.track_id = ct.track_id),

customer_genre_name as (
	select distinct cg.customer_id, g.name
	from customer_genre cg
	join genre g on g.genre_id = cg.genre_id
	where g.name = 'Rock')

select c.first_name, c.last_name, c.email, cgn.name
from customer_genre_name as cgn
join customer c on c.customer_id = cgn.customer_id
order by c.email

Solution 2:

select distinct c.first_name, c.last_name, c.email
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
where track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock'
)
order by email


Q7: Lets invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands.

select ar.name, count(*) as track_count
from track t
join album a on a.album_id = t.album_id
join artist ar on ar.artist_id = a.artist_id
where genre_id in (
	select genre_id from genre
	where name = 'Rock'
)
group by ar.name
order by track_count desc
limit 10


Q8: Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first.

select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) from track
)
order by milliseconds desc;


Q9: Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent.

with customer_artist as (
	select c.first_name, c.last_name, i.total, a.artist_id
	from customer c
	join invoice i on c.customer_id = i.customer_id
	join invoice_line il on il.invoice_id = i.invoice_id
	join track t on t.track_id = il.track_id
	join album a on a.album_id = t.album_id
)

select ca.first_name, ca.last_name, a.name as artist, sum(ca.total) as total
from customer_artist ca
join artist a on a.artist_id = ca.artist_id
group by ca.first_name, ca.last_name, a.name
order by ca.first_name, ca.last_name, total desc


Q10: We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. 

with genre_country as (
	select i.billing_country as country, g.name as genre_name, sum(il.unit_price * il.quantity) as amount_spent
	from invoice i
	join invoice_line il on il.invoice_id = i.invoice_id
	join track t on il.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by i.billing_country, g.name)

select gc.country, gc.genre_name, gc.amount_spent
from genre_country gc
join (
    select country, max(amount_spent) as max_spent
    from genre_country
    group by country
) max_gc on gc.country = max_gc.country and gc.amount_spent = max_gc.max_spent
order by gc.amount_spent desc;


Q11:  Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. 

with customer_total as (
	select c.customer_id, c.first_name, c.last_name, c.country, sum(i.total) as amount_spent
	from customer c
	join invoice i on i.customer_id = c.customer_id
	group by 1,2,3,4),

top_spender as (
	select customer_id, first_name, last_name, country, amount_spent,
	row_number() over(partition by country order by amount_spent) as rn
	from customer_total
)

select * from top_spender
where rn = 1