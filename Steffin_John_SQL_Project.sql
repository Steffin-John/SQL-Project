use orders;

/*1. Write a query to display customer full name with their title (Mr/Ms), both first name and
last name are in upper case, customer email id, customer creation date and display
customer’s category after applying below categorization rules:
i. IF customer creation date Year <2005 Then Category A
ii. IF customer creation date Year >=2005 and <2011 Then Category B
iii. iii)IF customer creation date Year>= 2011 Then Category C
Hint: Use CASE statement, no permanent change in table required.
[NOTE: TABLES to be used - ONLINE_CUSTOMER TABLE]
*/

SELECT concat(( CASE WHEN CUSTOMER_GENDER = 'M'
					 THEN 'Mr.'
                     ELSE 'Ms.'
                     END
				),
                CONCAT_WS(" ", UPPER(CUSTOMER_FNAME)," ", UPPER(CUSTOMER_LNAME))
                ) 
                AS Full_Name,CUSTOMER_EMAIL,CUSTOMER_CREATION_DATE,
CASE
	WHEN CUSTOMER_CREATION_DATE<'2005-01-01' THEN 'Category A'
    WHEN CUSTOMER_CREATION_DATE>= '2005-01-01' AND CUSTOMER_CREATION_DATE <'2011-01-01' THEN 'Category B'
    WHEN CUSTOMER_CREATION_DATE>= '2011-01-01' THEN 'Category C'
END AS Customers_Category
FROM online_customer;

/*2. Write a query to display the following information for the products, which have not
been sold: product_id, product_desc, product_quantity_avail, product_price, inventory
values (product_quantity_avail*product_price), New_Price after applying discount as per
below criteria. Sort the output with respect to decreasing value of Inventory_Value.
i) IF Product Price > 20,000 then apply 20% discount
ii) IF Product Price > 10,000 then apply 15% discount
iii) IF Product Price =< 10,000 then apply 10% discount
# Hint: Use CASE statement, no permanent change in table required.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
*/

select p.PRODUCT_ID,p.PRODUCT_DESC,p.PRODUCT_QUANTITY_AVAIL,p.PRODUCT_PRICE,
(p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE) AS Inventory_Values,
CASE
	WHEN p.PRODUCT_PRICE> 20000 THEN p.PRODUCT_PRICE*0.80
    WHEN p.PRODUCT_PRICE> 10000 THEN p.PRODUCT_PRICE*0.85
    WHEN p.PRODUCT_PRICE <= 10000 THEN p.PRODUCT_PRICE*0.90
END AS NEW_PRICE
from product p
where not exists (  
select oi.PRODUCT_ID from order_items oi
where oi.PRODUCT_ID = p.PRODUCT_ID);

/*
3. Write a query to display Product_class_code, Product_class_description, Count of
Product type in each product class, Inventory Value
(product_quantity_avail*product_price).
Information should be displayed for only those product_class_code which have more than
1,00,000. Inventory Value. Sort the output with respect to decreasing value of
Inventory_Value.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
*/

select p.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC, count(PRODUCT_CLASS_DESC),
 sum(p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE) as Inventory_value
from product p
join product_class pc
on pc.PRODUCT_CLASS_CODE = p.PRODUCT_CLASS_CODE
group by p.PRODUCT_CLASS_CODE, pc.PRODUCT_CLASS_DESC
having sum(p.PRODUCT_QUANTITY_AVAIL*p.PRODUCT_PRICE) > 100000
order by Inventory_value desc; 

/*4. Write a query to display customer_id, full name, customer_email, customer_phone and
country of customers who have cancelled all the orders placed by them (USE SUBQUERY)
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
*/
select oc.CUSTOMER_ID, concat(oc.CUSTOMER_FNAME,' ',oc.CUSTOMER_LNAME) as Full_name,oc.CUSTOMER_EMAIL,oc.CUSTOMER_PHONE,
ad.COUNTRY
from online_customer oc
join  address ad
on ad.ADDRESS_ID = oc.ADDRESS_ID
where oc.CUSTOMER_ID in (
select oh.CUSTOMER_ID from order_header oh
where oh.ORDER_STATUS = 'Cancelled'
);


/*
5. Write a query to display Shipper name, City to which it is catering, number of customer
catered by the shipper in the city and number of consignments delivered to that city for
Shipper DHL
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS,
ORDER_HEADER]
*/


select s.SHIPPER_NAME,ad.CITY, count(distinct oc.CUSTOMER_ID) as No_of_Customers_Cartered, count(oh.ORDER_ID) as Consignment_Delivered,oh.ORDER_STATUS
from online_customer oc
join order_header oh
on oc.CUSTOMER_ID = oh.CUSTOMER_ID
join shipper s
on s.SHIPPER_ID = oh.SHIPPER_ID
join address ad
on ad.ADDRESS_ID = oc.ADDRESS_ID
where s.SHIPPER_NAME = 'DHL'
group by s.SHIPPER_NAME,ad.CITY,oh.ORDER_STATUS;


/*6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold
and show inventory Status of products as below as per below condition:

i. For Electronics and Computer categories, if sales till date is Zero then show 'No
Sales in past, give discount to reduce inventory', if inventory quantity is less than
10% of quantity sold, show 'Low inventory, need to add inventory', if inventory
quantity is less than 50% of quantity sold, show 'Medium inventory, need to add
some inventory', if inventory quantity is more or equal to 50% of quantity sold,
show 'Sufficient inventory'

ii. For Mobiles and Watches categories, if sales till date is Zero then show 'No Sales in
past, give discount to reduce inventory', if inventory quantity is less than 20% of
quantity sold, show 'Low inventory, need to add inventory', if inventory quantity is
less than 60% of quantity sold, show 'Medium inventory, need to add some
inventory', if inventory quantity is more or equal to 60% of quantity sold, show
'Sufficient inventory'

iii. Rest of the categories, if sales till date is Zero then show 'No Sales in past, give
discount to reduce inventory', if inventory quantity is less than 30% of quantity
sold, show 'Low inventory, need to add inventory', if inventory quantity is less than
70% of quantity sold, show 'Medium inventory, need to add some inventory', if
inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient
inventory'
(USE SUB-QUERY)
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
*/

select 
	p.PRODUCT_ID,
    p.PRODUCT_DESC,
    pro_class.PRODUCT_CLASS_DESC,
    p.PRODUCT_QUANTITY_AVAIL,
    oi.qty_Sold,
case
	when oi.qty_Sold is null then 'No Sales in past, give discount to reduce inventory'
    else 
		case 
        when pro_class.PRODUCT_CLASS_DESC in ('Electronics','Computer')
        then 
			case
			when (oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) >= 0.5
				then 'Sufficient Inventory' 
            when ((oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) < 0.5 and (oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) >= 0.1)
				then 'Medium Inventory, need to add some Inventory'
			else 'Low Inventory, need to add Inventory'
			end
		when pro_class.PRODUCT_CLASS_DESC in ('Mobiles','Watches')
        then
			case 
            when (oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) >= 0.6
				then 'Sufficient Inventory' 
            when ((oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) < 0.6 and (oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) < 0.2)
				then 'Medium Inventory, need to add some Inventory'
			else 'Low Inventory, need to add Inventory'
			end 
            when pro_class.PRODUCT_CLASS_DESC not in ('Electronics','Computer','Mobiles','Watches')
        then
			case 
            when (oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) >= 0.7
				then 'Sufficient Inventory' 
            when ((oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) < 0.7 and (oi.qty_Sold/p.PRODUCT_QUANTITY_AVAIL) < 0.3)
				then 'Medium Inventory, need to add some Inventory'
			else 'Low Inventory, need to add Inventory' 
            end
		end
end Inventory_Status   
from product p
inner join 	product_class pro_class
on pro_class.PRODUCT_CLASS_CODE = p.PRODUCT_CLASS_CODE
left join (select product_id, sum(product_quantity) qty_sold from order_items
group by PRODUCT_ID) oi
on p.PRODUCT_ID= oi.PRODUCT_ID;

/*7. Write a query to display order_id and volume of the biggest order (in terms of volume)
that can fit in carton id 10
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
*/

select * from
(select oi.order_id,
sum(p.LEN*p.WIDTH*p.HEIGHT*oi.PRODUCT_QUANTITY) tot_vol
from order_items oi , product p
where oi.PRODUCT_ID = p.PRODUCT_ID
group by oi.ORDER_ID
) order_vol
where tot_vol <= (select LEN*WIDTH*HEIGHT from carton where CARTON_ID = 10)
order by tot_vol desc;

/*8. Write a query to display customer id, customer full name, total quantity and total value
(quantity*price) shipped where mode of payment is Cash and customer last name starts
with 'G'
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT,
ORDER_HEADER]
*/

select oc.CUSTOMER_ID, concat(oc.CUSTOMER_FNAME,' ', oc.CUSTOMER_LNAME) as Full_name,
sum(oi.PRODUCT_QUANTITY*p.PRODUCT_PRICE) as Total_value,
sum(oi.PRODUCT_QUANTITY) as Total_quantity,
oh.PAYMENT_MODE
from online_customer oc inner join order_header oh
	 on oc.CUSTOMER_ID = oh.CUSTOMER_ID join 
     order_items oi
     on oh.ORDER_ID = oi.ORDER_ID join
     product p
     on oi.PRODUCT_ID = p.PRODUCT_ID
     where oc.CUSTOMER_LNAME like 'G%'
	and oh.PAYMENT_MODE = 'Cash'
    group by oc.CUSTOMER_ID,oh.PAYMENT_MODE;
	
/*9. Write a query to display product_id, product_desc and total quantity of products which
are sold together with product id 201 and are not shipped to city Bangalore and New
Delhi. Display the output in descending order with respect to the tot_qty.
(USE SUB-QUERY)
[NOTE: TABLES to be used – ORDER_ITEMS, PRODUCT, ORDER_HEADER,
ONLINE_CUSTOMER, ADDRESS]
*/

select distinct
	p.PRODUCT_ID,
	p.PRODUCT_DESC,
    sum(oi.PRODUCT_QUANTITY) as Tot_qty
	from
		order_items oi,
        product p,
        (select distinct order_id from address ad,online_customer oc,order_header oh
			where ad.city not in ('Bangalore','New Delhi')
            and oc.ADDRESS_ID = ad.ADDRESS_ID
            and oh.CUSTOMER_ID = oc.CUSTOMER_ID
        ) order_tbl
where 
p.PRODUCT_ID = oi.PRODUCT_ID
and oi.ORDER_ID in
(select distinct oi.ORDER_ID from order_items oi
where product_id = 201
)
and order_tbl.ORDER_ID = oi.ORDER_ID
group by p.PRODUCT_ID,p.PRODUCT_DESC
order by 3 desc;
    

/*10. Write a query to display the order_id,customer_id and customer fullname, total
quantity of products shipped for order ids which are even and shipped to address where
pincode is not starting with "5"
[NOTE: TABLES to be used – ONLINE_CUSTOMER, ORDER_HEADER,
ORDER_ITEMS, ADDRESS]
*/

select oh.ORDER_ID,oc.CUSTOMER_ID,concat(oc.CUSTOMER_FNAME,' ',CUSTOMER_LNAME) as Full_Name,
sum(oi.PRODUCT_QUANTITY) as Total_Qty_Product_Shipped,ad.PINCODE
from online_customer oc
join address ad
on ad.ADDRESS_ID = oc.ADDRESS_ID
join order_header oh 
on oh.CUSTOMER_ID = oc.CUSTOMER_ID 
join order_items oi
on oh.ORDER_ID = oi.ORDER_ID
where oh.ORDER_STATUS = 'shipped'
and oh.ORDER_ID in (select oh.ORDER_ID from order_header oh where oh.ORDER_ID % 2 = 0)
group by oh.ORDER_ID,oc.CUSTOMER_ID,ad.PINCODE 
having ad.PINCODE not like '5%';
