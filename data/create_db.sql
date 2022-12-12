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
    department_id integer not null,
    tax_id integer not null,
    insurance_id integer not null,
    foreign key (tax_id) references Taxes(id),
    foreign key (department_id) references Departments(id),
    foreign key (insurance_id) references Insurance(id)
);

create table Paystubs (
    id serial,
    base_pay integer,
    number_regular_hours integer,
    number_overtime_hours integer,
    tax_id integer not null,
    federal_percent numeric,
    state_percent numeric,
    ssn varchar(11),
    total_tax numeric GENERATED ALWAYS as 
    ((((number_regular_hours * base_pay) + (number_overtime_hours * (base_pay * 1.5))) * federal_percent)
    + (((number_regular_hours * base_pay) + (number_overtime_hours * (base_pay * 1.5))) * state_percent) 
    ) STORED,
    total_pay numeric GENERATED ALWAYS as 
    ( ((number_regular_hours * base_pay) + (number_overtime_hours * (base_pay * 1.5)))
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
    id serial,
    reason varchar(32),
    leave_date date,
    ssn varchar(11) not null,
    foreign key (ssn) references Employees(ssn) on delete cascade,
    primary key (id, ssn)
);

create table Bonuses (
    id serial,
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

insert into Employees (ssn, employee_name, employment_type, phone_number, department_id, tax_id, insurance_id) values 
('000000000', 'John Johnson', 'Full-time', '2121111111', 1, 3, 3),
('111111111', 'James Jameson', 'Full-time', '2122222222', 3, 5, 4),
('222222222', 'Alice Allison', 'Full-time', '2123333333', 2, 2, 1),
('333333333', 'Jeffrey Jefferson', 'Part-time', '2124444444', 2, 5, 1),
('444444444', 'Stacy Stacerson', 'Part-time', '2125555555', 2, 4, 2);

insert into Dependents (employee_ssn, dependent_name, dependent_type) values 
('000000000', 'Sally Johnson', 'Child'),
('000000000', 'Jonny Johnson', 'Child'),
('000000000', 'Jeffy Johnson', 'Child'),
('000000000', 'Bobby Johnson', 'Child'),
('111111111', 'Wendy Jameson', 'Spouse');

insert into Takes_Leaves (reason, leave_date, ssn) values 
('Sick', '2022-12-01', '000000000'),
('Sick', '2022-12-02', '000000000'),
('Sick', '2022-11-01', '111111111'),
('Didnt feel like it', '2022-11-15', '111111111'),
('Tired', '2022-11-16', '111111111');

insert into Paystubs (base_pay, number_regular_hours, number_overtime_hours, tax_id, federal_percent, state_percent, ssn) values
(15, 40, 20, 3, .22, .06, '000000000'),
(15, 40, 0, 3, .22, .06, '000000000'),
(15, 40, 10, 3, .22, .06, '000000000'),
(30, 40, 0, 5, .37, .1, '111111111'),
(30, 40, 0, 5, .37, .1, '111111111'),
(30, 40, 0, 5, .37, .1, '111111111'),
(12, 40, 0, 2, .12, .045, '222222222'),
(12, 40, 40, 2, .12, .045, '222222222'),
(12, 40, 0, 2, .12, .045, '222222222'),
(18, 40, 0, 2, .12, .045, '333333333'),
(18, 40, 30, 2, .12, .045, '333333333'),
(18, 40, 0, 2, .12, .045, '333333333'),
(20, 40, 0, 4, .32, .075, '444444444'),
(20, 40, 60, 4, .32, .075, '444444444'),
(20, 40, 0, 4, .32, .075, '444444444');

insert into Bonuses (id, amount, bonus_type, ssn) values
(1000, 'Signing', '000000000'),
(3000, 'Holiday', '000000000'),
(7000, 'Holiday', '111111111'),
(2000, 'Holiday', '222222222'),
(2000, 'Holiday', '333333333'),
(2000, 'Holiday', '444444444');

insert into Immigration (ssn, sponsorship_status, immigration_type) values 
('000000000', 'Sponsored', 'EB-3'),
('444444444', 'Sponsored', 'H1-B');