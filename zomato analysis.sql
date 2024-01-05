CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


select * from product;
select * from sales;

-----total spent by each customer 
select s.userid, sum(p.price) as total_spent
from sales s
inner join product p on s.product_id=p.product_id
group by s.userid;

-----how many days each custoer visited zomato?
select userid, count(distinct created_date) as days
from sales
group by userid;

----what was the first product purchased by each customer?
with cte as (select s.*, p.product_name, p.price
from sales s
inner join product p on s.product_id=p.product_id)
,ranked as (select *,
rank() over(partition by userid order by created_date asc) as rnk
from cte)
select * from ranked
where rnk=1;

----what is the most purchased item on the menu and how many times was it purchased by all customer?

select * from sales;
select product_id
from sales
group by product_id order by count(product_id) desc;


select userid, count(product_id) cnt from sales
where product_id=(select top 1 product_id
from sales
group by product_id order by count(product_id) desc)
group by userid;


----which item was the most popular for each customer?
select * from sales;
select userid, product_id, count(product_id) cnt
from sales 
group by userid, product_id order by userid, cnt desc;


----which item was purchased first by the customer after they became a gold member?

with gold_user as (select s.*, g.gold_signup_date
from sales s inner join goldusers_signup g
on s.userid=g.userid and s.created_date>=g.gold_signup_date)
,ranking as (select *,
rank() over(partition by gu.userid order by gu.created_date) as rnk
from gold_user gu)
select * from ranking
where rnk=1;

---which item was purchased first by the customer before they became a gold member?
with gold_user as (select s.*, g.gold_signup_date
from sales s inner join goldusers_signup g
on s.userid=g.userid and s.created_date<=g.gold_signup_date)
,ranking as (select *,
rank() over(partition by gu.userid order by gu.created_date desc) as rnk
from gold_user gu)
select * from ranking
where rnk=1;

---what is the total orders and amount spent for each member before they became a gold member?
with cte as (select s.*, g.gold_signup_date,p.product_name,p.price
from sales s inner join goldusers_signup g
on s.userid=g.userid inner join product p
on s.product_id=p.product_id and s.created_date<=g.gold_signup_date)
select c.userid,count(c.created_date)as cnt, sum(c.price) as total_amt 
from cte c
group by c.userid;

---if buying each product generates points for eg. 5 rs = 2 zomato points and each product has different purchasing points for eg for p1 5rs = 1 zomato point,
---for p2 10rs = 5 zomato points, fro p3 5 rs =1 zomato point.
---calculate points collected by each customers and for which product most points have been given till now ?

select * from sales;
select * from product;

with total as (select s.userid, p.product_id, sum(p.price) as amt
from sales s 
inner join product p on s.product_id=p.product_id
group by s.userid, p.product_id)
select t.userid, t.product_id,t.amt,
(case when t.product_id=1 then t.amt/5 
 when t.product_id=2 then (t.amt/10)*5 
 when t.product_id=3 then t.amt/5 end) as points
from total t;


---for which product most points have been given till now ?

with total as (select s.userid, p.product_id, sum(p.price) as amt
from sales s 
inner join product p on s.product_id=p.product_id
group by s.userid, p.product_id)
,points as (select t.userid, t.product_id,t.amt,
(case when t.product_id=1 then t.amt/5 
 when t.product_id=2 then (t.amt/10)*5 
 when t.product_id=3 then t.amt/5 end) as points
from total t)
select p.product_id,sum(p.points) total_points
from points p
group by p.product_id
order by total_points desc;

---In the first one year after a customer joins the gold program (including their join date) irrespective 
---of what the customer has purchased they earn 5 points for every 10 rs spent
---who earned more 1 or 3 and what was their points earnings in their first yr?
--
---1 point =2rs
---0.5 point = 1rs

select s.*, p.price, g.gold_signup_date, p.price*0.5 as points
from sales s inner join goldusers_signup g
on s.userid=g.userid and s.created_date>=g.gold_signup_date
and s.created_date<=dateadd(year,1,g.gold_signup_date)
inner join product p on s.product_id=p.product_id;

---rank all the transaction of the customers

select *,
rank() over(partition by userid order by created_date) as rnk 
from sales;

---rank all the transactions for each member whenever they are gold member for every non gold member transaction mark as na

select * from sales ;

with cte as (select s.*, g.gold_signup_date
from sales s left join goldusers_signup g
on s.userid=g.userid and s.created_date>=g.gold_signup_date)
select *,
CAST((CASE WHEN gold_signup_date IS NULL THEN 'NA' ELSE CAST(RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS VARCHAR(10)) END) AS VARCHAR(10)) AS rnk
from cte;