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