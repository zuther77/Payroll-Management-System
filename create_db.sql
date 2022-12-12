drop table if exists Employees cascade;
drop table if exists Paystubs cascade;
drop table if exists Taxes cascade;
drop table if exists Dependents cascade;
drop table if exists Takes_Leaves cascade;
drop table if exists Bonuses cascade;
drop table if exists Immigration cascade;
drop table if exists Departments cascade;
drop table if exists Insurance cascade;
 
create table Taxes (
    id integer unique not null,
    federal_percent numeric,
    state_percent numeric,
    primary key (id, federal_percent, state_percent)
);

create table Departments (
    id integer primary key,
    department_name varchar(32)
);

create table Insurance (
    id integer primary key,
    insurance_type varchar(32),
    coverage_percentage numeric
);

create table Employees (
    ssn varchar(11) primary key,
    employee_name varchar(32),
    employment_type varchar(32),
    phone_number varchar(10),
    leaves_count integer,
    department_id integer not null,
    tax_id integer not null,
    insurance_id integer not null,
    foreign key (tax_id) references Taxes(id),
    foreign key (department_id) references Departments(id),
    foreign key (insurance_id) references Insurance(id)
);

create table Paystubs (
    id integer,
    base_pay integer,
    number_regular_hours integer,
    number_overtime_hours integer,
    tax_id integer not null,
    federal_percent numeric,
    state_percent numeric,
    ssn varchar(11),
    total_pay numeric GENERATED ALWAYS as 
    ( ((number_regular_hours * base_pay) + (number_overtime_hours * (base_pay * 1.5)))
    - (((number_regular_hours * base_pay) + (number_overtime_hours * (base_pay * 1.5))) * federal_percent)
    - (((number_regular_hours * base_pay) + (number_overtime_hours * (base_pay * 1.5))) * state_percent) 
    ) STORED,
    foreign key (tax_id, federal_percent, state_percent) references Taxes(id, federal_percent, state_percent),
    foreign key (ssn) references Employees(ssn),
    primary key (id, ssn)
);

create table Dependents (
    employee_ssn varchar(11),
    dependent_name varchar(32),
    dependent_type varchar(32),
    foreign key (employee_ssn) references Employees(ssn) on delete cascade,
    primary key (employee_ssn, dependent_name, dependent_type)
);

create table Takes_Leaves (
    id integer,
    reason varchar(32),
    leave_date date,
    ssn varchar(11) not null,
    foreign key (ssn) references Employees(ssn) on delete cascade,
    primary key (id, ssn)
);

create table Bonuses (
    id integer,
    amount integer,
    bonus_type varchar(32),
    ssn varchar(11) not null,
    foreign key (ssn) references Employees(ssn),
    primary key (id, ssn)
);

create table Immigration (
    ssn varchar(11) primary key,
    sponsorship_status varchar(32),
    immigration_type varchar(32),
    foreign key (ssn) references Employees(ssn) on delete cascade
);

insert into Taxes (id, federal_percent, state_percent) values (1, .1, .04);
insert into Taxes (id, federal_percent, state_percent) values (2, .12, .045);
insert into Taxes (id, federal_percent, state_percent) values (3, .22, .06);
insert into Taxes (id, federal_percent, state_percent) values (4, .32, .075);
insert into Taxes (id, federal_percent, state_percent) values (5, .37, .1);

insert into Departments (id, department_name) values (1, 'Sales');
insert into Departments (id, department_name) values (2, 'Accounting');
insert into Departments (id, department_name) values (3, 'Management');

insert into Insurance (id, insurance_type, coverage_percentage) values (1, 'Bronze', .25);
insert into Insurance (id, insurance_type, coverage_percentage) values (2, 'Silver', .5);
insert into Insurance (id, insurance_type, coverage_percentage) values (3, 'Gold', .75);
insert into Insurance (id, insurance_type, coverage_percentage) values (4, 'Platinum', 1);

insert into Employees (ssn, employee_name, employment_type, phone_number, leaves_count, department_id, tax_id, insurance_id) values 
('000000000', 'John Johnson', 'Salesperson', '2121111111', 10, 1, 3, 3),
('111111111', 'James Jameson', 'Big Boss', '2122222222', 100, 3, 5, 4),
('222222222', 'Alice Allison', 'Accountant', '2123333333', 5, 2, 2, 1),
('333333333', 'Jeffrey Jefferson', 'Accountant', '2124444444', 5, 2, 2, 1),
('444444444', 'Stacy Stacerson', 'Accountant', '2125555555', 5, 2, 4, 2);

insert into Dependents (employee_ssn, dependent_name, dependent_type) values 
('000000000', 'Sally Johnson', 'Child'),
('000000000', 'Jonny Johnson', 'Child'),
('000000000', 'Jeffy Johnson', 'Child'),
('000000000', 'Bobby Johnson', 'Child'),
('111111111', 'Wendy Jameson', 'Spouse');

insert into Takes_Leaves (id, reason, leave_date, ssn) values 
(1, 'Sick', '2022-12-01', '000000000'),
(2, 'Sick', '2022-12-02', '000000000'),
(1, 'Sick', '2022-11-01', '111111111'),
(2, 'Didnt feel like it', '2022-11-15', '111111111'),
(3, 'Tired', '2022-11-16', '111111111');

insert into Paystubs (id, base_pay, number_regular_hours, number_overtime_hours, tax_id, federal_percent, state_percent, ssn) values
(1, 15, 40, 20, 3, .22, .06, '000000000'),
(2, 15, 40, 0, 3, .22, .06, '000000000'),
(3, 15, 40, 10, 3, .22, .06, '000000000'),
(1, 30, 40, 0, 5, .37, .1, '111111111'),
(2, 30, 40, 0, 5, .37, .1, '111111111'),
(3, 30, 40, 0, 5, .37, .1, '111111111'),
(1, 12, 40, 0, 2, .12, .045, '222222222'),
(2, 12, 40, 40, 2, .12, .045, '222222222'),
(3, 12, 40, 0, 2, .12, .045, '222222222'),
(1, 18, 40, 0, 2, .12, .045, '333333333'),
(2, 18, 40, 30, 2, .12, .045, '333333333'),
(3, 18, 40, 0, 2, .12, .045, '333333333'),
(1, 20, 40, 0, 4, .32, .075, '444444444'),
(2, 20, 40, 60, 4, .32, .075, '444444444'),
(3, 20, 40, 0, 4, .32, .075, '444444444');

insert into Bonuses (id, amount, bonus_type, ssn) values
(1, 1000, 'Signing', '000000000'),
(2, 3000, 'Holiday', '000000000'),
(1, 7000, 'Holiday', '111111111'),
(1, 2000, 'Holiday', '222222222'),
(1, 2000, 'Holiday', '333333333'),
(1, 2000, 'Holiday', '444444444');

insert into Immigration (ssn, sponsorship_status, immigration_type) values 
('000000000', 'Sponsored', 'EB-3'),
('444444444', 'Sponsored', 'H1-B');