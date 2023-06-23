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
SELECT comp_name,count(*) FROM customer,order_details
WHERE comp_id = customer_id
GROUP BY comp_name,comp_id
HAVING count(*)>2;


-- 2.Display the employee name and the customer name from their respective tables for which employee zipcode and the customer zipcode are equal.
SELECT fname , comp_name , e.zipcode FROM employee e,customer c
WHERE e.zipcode=c.zipcode;


-- 3.DISPLAY THE COUNT OF EMPLOYEES GETTING MORE THAN THE AVERAGE SALARY OF ALL THE EMPLOYEES
SELECT count(SSN) FROM EMPLOYEE
WHERE  SALARY >= (SELECT AVG(SALARY) FROM EMPLOYEE);


-- 4.Find the day difference between the order date and the delivery date for all the orders placed.
 SELECT ORDER_ID,ORD_DATE, ACTUAL_DATE,(ACTUAL_DATE - ORD_DATE) FROM ORDER_DETAILS;


-- 5.Retrieve the order id for which the day difference between the order date and the delivery date is equal to or exceeds 3.
SELECT ORDER_ID,(ACTUAL_DATE - ORD_DATE) FROM ORDER_DETAILS
WHERE (ACTUAL_DATE - ORD_DATE)>=3;


-- 6.retrieve customer id and customer name who have this contact no starting with '997'.
SELECT comp_id, comp_name 
FROM customer
WHERE contactno LIKE '%997%';  


-- 7.DISPLAY THE VEHICLE DETAILS OF THE ORDER WHOSE ORDER NO IS OD22 IS BEING TRANSPORTED.
SELECT VEHICLE_NO , MODEL , type FROM VEHICLE , CONSISTS
WHERE VEHICLENO=VEHICLE_NO AND ORDER_ID='O22';


-- 8.To retrieve the ORDER DETAILS OF CUSTOMER WHOSE COMP_ID IS 011
SELECT COMP_NAME,ORDER_ID,PARCEL_MATERIAL,TOT_AMOUNT,SOURCE_LOC,DEST_LOC FROM ORDER_DETAILS , CUSTOMER
WHERE COMP_ID=CUSTOMER_ID AND CUSTOMER_ID='C11';


-- 9.To retrieve the male employees whose salary is greater than average salary 
SELECT e1.fname FROM employee e1,employee e2
WHERE e1.sex='M'
GROUP BY e1.fname,e1.ssn,e1.salary
HAVING e1.salary > AVG(e2.salary);


-- 10.To retrieve the customer names along with total amount of order ordered by them
SELECT comp_id,comp_name,sum(tot_amount) AS total_amount
FROM customer,order_details
WHERE customer_id = comp_id
GROUP BY comp_name,comp_id
ORDER BY total_amount;


-- 11. To retrieve the total orders which are ordered at least a day prior to the actual day
SELECT DISTINCT comp_id, comp_name FROM order_details,customer
WHERE comp_id = customer_id AND actual_date-ord_date >= 1;


-- 12.DISPLAY THE ORDER DETAILS OF THE ORDER WHICH PAYS THE MAXIMUM TO THE TRANSFER OF THE PARCEL.
SELECT  COMP_NAME,ORDER_ID,PARCEL_MATERIAL,TOT_AMOUNT,SOURCE_LOC,DEST_LOC FROM  ORDER_DETAILS , CUSTOMER
WHERE COMP_ID=CUSTOMER_ID AND TOT_AMOUNT = (SELECT MAX(TOT_AMOUNT) 
                                             FROM ORDER_DETAILS);
                                             

-- 13.Display the order details of the order whose total amount is greater than the total amount of order whose order date is 14-oct-2019. 
SELECT order_id,tot_amount,ord_date,customer_id FROM order_details
WHERE tot_amount > (SELECT AVG(tot_amount)
                    FROM order_details
                    WHERE ord_date='2019-10-14');
                    
                    
-- 14.Retrieve the customer details from the customer table whose name is 'NATCO'
SELECT comp_id, comp_name , contactno ,street , city , state_name , zipcode  FROM customer
WHERE comp_id = (SELECT comp_id 
                 FROM customer
				 WHERE comp_name = 'NATCO');


-- 15. To retrieve the department details  whose employees has at most 11000 salary
SELECT * FROM department
WHERE dnum IN(SELECT e1.dno
               FROM employee e1,employee e2
               GROUP BY e1.salary,e1.ssn,e1.dno
               HAVING MAX(e1.salary)<11000);
               

-- 16.To retrieve the names of clients ,order id ,orderdate where more than 3 order is placed in a day.
select comp_name,order_id,ord_date
from customer,order_details
where comp_id = customer_id and ord_date in(select ord_date
                                             from order_details
                                             group by ord_date
                                             having count(*)>3);
                                             
                                             
-- 17.To retrieve the manager details who have salary greater than average salary of all the managers
select *from employee
where ssn in(select ssn 
             from department 
             where ssn=dmgr_ssn and salary >(select avg(e1.salary)
                                              from employee e1,department 
                                              where e1.ssn=dmgr_ssn));
                                              
                                              
-- 18.To retrieve the second highest salary of the employee
select distinct salary
from employee e1
where 2=(select count(distinct salary)
         from employee e2
         where e1.salary <=e2.salary);
         
         
-- 19.To retrieve the companies who orders that worth greater than average amount of all orders
select distinct comp_name
from customer,order_details o1
where comp_id=o1.customer_id and o1.order_id in (select o1.order_id
                                                from order_details o2
                                                group by o1.order_id, o1.tot_amount
                                                having o1.tot_amount<avg(o2.tot_amount));
                                                
                                                
-- 20.To retrieve the company which gives maximum amount of order
create or replace view amt as
select comp_id,comp_name,sum(tot_amount) as totalamt
from customer,order_details
where comp_id=customer_id
group by comp_id,comp_name;

select a1.comp_id,a1.comp_name ,a1.totalamt
from amt a1,amt a2
group by a1.comp_id,a1.comp_name ,a1.totalamt
having max(a2.totalamt)=a1.totalamt;
                                       
                                       
-- 21.To retrieve the department which offers the least salary using
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


-- 22.To retrieve the employee who handles more  than 2 orders and works for  ADMINISTRATION department

create or replace view view2 as
select ssn,fname,dno ,count(*) as no_of_orders
from employee e,handles h
where e.ssn=h.hssn
group by fname,ssn,dno
having count(*)>2;

select ssn,fname , no_of_orders
from view2,department
where dno = dnum and dname = 'ADMINISTRATION';


-- 23.To retrieve the customer details who totally ordered vehicle to travel more thann 5000 km and at least ordered once between '1-jan-19' and '15-aug-19'
create or replace view view4 as
select comp_name,customer_id,sum(distance) as tot_distance
from customer,order_details
where comp_id = customer_id
group by  customer_id,comp_name;

select distinct comp_name , tot_distance
from view4 v,order_details o
where v.customer_id = o.customer_id and tot_distance >500 and  ord_date between '2019-01-1' and '2019-08-15';


                                             

