USE LOGISTICS_DMS;

SELECT * FROM company;
SELECT * FROM consists;
SELECT * FROM customer;
SELECT * FROM department;
SELECT * FROM dependent;
SELECT * FROM employee;
SELECT * FROM handles;
SELECT * FROM order_details;
SELECT * FROM vehicle;

------------------------------------------------------------------------------------------------------------------------------

/* ============================= PROJECT ===========================================*/

-- 1.To retrieve the client name having more than 2 order
select comp_name,count(*)
from customer,order_details
where comp_id = customer_id
group by comp_name,comp_id
having count(*)>2;


-- 2.Display the employee name and the customer name from their respective tables for which employee zipcode and the customer zipcode are equal.
select fname , comp_name , e.zipcode
from employee e,customer c
where e.zipcode=c.zipcode;


-- 3.DISPLAY THE COUNT OF EMPLOYEES GETTING MORE THAN THE AVERAGE SALARY OF ALL THE EMPLOYEES
SELECT count(SSN)
FROM EMPLOYEE
WHERE  SALARY >= (SELECT AVG(SALARY) FROM EMPLOYEE);


-- 4.Find the day difference between the order date and the delivery date for all the orders placed.
 SELECT ORDER_ID,ORD_DATE, ACTUAL_DATE,(ACTUAL_DATE - ORD_DATE) FROM ORDER_DETAILS;


-- 5.Retrieve the order id for which the day difference between the order date and the delivery date is equal to or exceeds 3.
SELECT ORDER_ID,(ACTUAL_DATE - ORD_DATE)
FROM ORDER_DETAILS
Where (ACTUAL_DATE - ORD_DATE)>=3;


-- 6.retrieve customer id and customer name who have this contact no starting with '997'.
SELECT comp_id, comp_name 
FROM customer
WHERE contactno like '%997%';  


-- 2.DISPLAY THE VEHICLE DETAILS OF THE ORDER WHOSE ORDER NO IS OD22 IS BEING TRANSPORTED.
SELECT VEHICLE_NO , MODEL , TYPE 
FROM VEHICLE , CONSISTS
WHERE VEHICLENO=VEHICLE_NO AND ORDER_ID='O22';


-- 4.To retrieve the ORDER DETAILS OF CUSTOMER WHOSE COMP_ID IS 011
SELECT COMP_NAME,ORDER_ID,PARCEL_MATERIAL,TOT_AMOUNT,SOURCE_LOC,DEST_LOC
FROM ORDER_DETAILS , CUSTOMER
WHERE COMP_ID=CUSTOMER_ID AND CUSTOMER_ID='C11';


-- 1.To retrieve the client name having more than 2 order
select comp_name,count(*) from customer,order_details
where comp_id = customer_id
group by comp_name,comp_id
having count(*)>2
order by count(*) desc;


-- 4.To retrieve the male employees whose salary is greater than average salary 
select e1.fname
from employee e1,employee e2
where e1.sex='M'
group by e1.fname,e1.ssn,e1.salary
having e1.salary>avg(e2.salary);


-- 5.To retrieve the customer names along with total amount of order ordered by them
select comp_id,comp_name,sum(tot_amount) as total_amount
from customer,order_details
where customer_id = comp_id
group by comp_name,comp_id
order by total_amount;


-- 6. To retrieve the total orders which are ordered at least a day prior to the actual day
select distinct comp_id, comp_name
from order_details,customer
where comp_id = customer_id and actual_date-ord_date >= 1;


-- 1.DISPLAY THE ORDER DETAILS OF THE ORDER WHICH PAYS THE MAXIMUM TO THE TRANSFER OF THE PARCEL.
SELECT  COMP_NAME,ORDER_ID,PARCEL_MATERIAL,TOT_AMOUNT,SOURCE_LOC,DEST_LOC
FROM  ORDER_DETAILS , CUSTOMER
WHERE COMP_ID=CUSTOMER_ID AND TOT_AMOUNT = (SELECT MAX(TOT_AMOUNT) 
                                             FROM ORDER_DETAILS);
                                             

-- 2.Display the order details of the order whose total amount is greater than the total amount of order whose order date is 14-oct-2019. 
SELECT order_id,tot_amount,ord_date,customer_id
FROM order_details
WHERE tot_amount > (SELECT AVG(tot_amount)
                    FROM order_details
                    WHERE ord_date='2019-10-14');
                    
                    
-- 4.Retrieve the customer details from the customer table whose name is 'NATCO'
SELECT comp_id, comp_name , contactno ,street , city , state_name , zipcode 
FROM customer
WHERE comp_id = 
(SELECT comp_id 
FROM customer
WHERE comp_name = 'NATCO');


-- 2. To retrieve the department details  whose employees has at most 11000 salary
select *from department
where dnum in(select e1.dno
               from employee e1,employee e2
               group by e1.salary,e1.ssn,e1.dno
               having max(e1.salary)<11000);
               

-- 3.To retrieve the names of clients ,order id ,orderdate where more than 3 order is placed in a day.
select comp_name,order_id,ord_date
from customer,order_details
where comp_id = customer_id and ord_date in(select ord_date
                                             from order_details
                                             group by ord_date
                                             having count(*)>3);
                                             
                                             
-- 1.To retrieve the manager details who have salary greater than average salary of all the managers
select *from employee
where ssn in(select ssn 
             from department 
             where ssn=dmgr_ssn and salary >(select avg(e1.salary)
                                              from employee e1,department 
                                              where e1.ssn=dmgr_ssn));
                                              
                                              
-- 2.To retrieve the second highest salary of the employee
select distinct salary
from employee e1
where 2=(select count(distinct salary)
         from employee e2
         where e1.salary <=e2.salary);
         
         
-- 3.To retrieve the companies who orders that worth greater than average amount of all orders
select distinct comp_name
from customer,order_details o1
where comp_id=o1.customer_id and o1.order_id in (select o1.order_id
                                                from order_details o2
                                                group by o1.order_id, o1.tot_amount
                                                having o1.tot_amount<avg(o2.tot_amount));
                                                
                                                
-- 1.To retrieve the company which gives maximum amount of order
create or replace view amt as
select comp_id,comp_name,sum(tot_amount) as totalamt
from customer,order_details
where comp_id=customer_id
group by comp_id,comp_name;

select a1.comp_id,a1.comp_name ,a1.totalamt
from amt a1,amt a2
group by a1.comp_id,a1.comp_name ,a1.totalamt
having max(a2.totalamt)=a1.totalamt;
                                       
                                       
-- 2.To retrieve the department which offers the least salary using
create or replace view least_sal
as select dnum,dname,min(salary) as least_salary
from employee,department
where dnum=dno
group by dnum,dname
order by least_salary asc;

SELECT dnum, dname, least_salary
FROM least_sal
ORDER BY least_salary
LIMIT 1;


-- 3.To retrieve the employee who handles more  than 2 orders and works for  ADMINISTRATION department

create or replace view view2 as
select ssn,fname,dno ,count(*) as no_of_orders
from employee e,handles h
where e.ssn=h.hssn
group by fname,ssn,dno
having count(*)>2;

select ssn,fname , no_of_orders
from view2,department
where dno = dnum and dname = 'ADMINISTRATION';


-- 4.To retrieve the customer details who totally ordered vehicle to travel more thann 5000 km and at least ordered once between '1-jan-19' and '15-aug-19'
create or replace view view4 as
select comp_name,customer_id,sum(distance) as tot_distance
from customer,order_details
where comp_id = customer_id
group by  customer_id,comp_name;

select distinct comp_name , tot_distance
from view4 v,order_details o
where v.customer_id = o.customer_id and tot_distance >500 and  ord_date between '2019-01-1' and '2019-08-15';


                                             

