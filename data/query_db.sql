-- Get 3 most recent pay stubs for particular employee
select top 3 paystub_date, total_pay, total_tax from Paystubs
where ssn = '000000000'
order by paystub_date;

-- Get before-tax pay, after-tax pay, and tax paid for particular employee
select sum(P.total_pay) as Total_Pay, sum(P.total_tax) as Total_Tax, sum(P.total_pay)-sum(P.total_tax) as After_Tax_Pay, E.employee_name from Paystubs P, Employees E
where P.ssn = E.ssn
and P.ssn = '111-11-1111'
group by P.ssn, E.employee_name;

-- Get number of employees for a particular department
select count(E), D.id, D.department_name from Employees E, Departments D
where D.id = '2'
and D.id = E.department_id
group by D.id, D.department_name;

-- Get all employees for a particular department
select ssn, employee_name, department_id from Employees
where department_id = '2';

-- Get before-tax pay of all employees of a particular department
select sum(P.total_pay)-sum(P.total_tax) Expenses, D.id Department from Paystubs P, Departments D, Employees E
where P.ssn = E.ssn
and E.department_id = D.id
group by D.id
order by D.id;

-- Get number of employees who need some form of visa sponsorship
select count(*) from Immigration;

-- Get all employees who need some form of visa sponsorship
select ssn, employee_name from Employees
where ssn in (select ssn from Immigration);

-- Get before-tax pay of all employees who need some form of visa sponsorship
select sum(P.total_pay)-sum(P.total_tax) from Paystubs P, Employees E
where P.ssn = E.ssn
and P.ssn in (select ssn from Immigration);

-- Get total amount of bonuses dispersed to a given employee
select sum(amount) from Bonuses
where ssn = '000000000';

--  Group employees based on tax bracket

-- Count dependents for each employee

-- Count leaves for each employee - could group by month

-- Get total compensation - show salary, bonuses, and insurance benefits
