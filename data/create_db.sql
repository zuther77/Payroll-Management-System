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
    paystub_date date, 
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
    id serial ,
    reason varchar(32),
    leave_date date,
    emp_ssn varchar(11) not null,
    foreign key (emp_ssn) references Employees(ssn) on delete cascade,
    primary key (id, emp_ssn)
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


insert into Insurance (id, insurance_type, coverage_percentage) values (1, 'Bronze', .25);
insert into Insurance (id, insurance_type, coverage_percentage) values (2, 'Silver', .5);
insert into Insurance (id, insurance_type, coverage_percentage) values (3, 'Gold', .75);
insert into Insurance (id, insurance_type, coverage_percentage) values (4, 'Platinum', 1);

INSERT INTO Departments (id, department_name) VALUES
    (1, 'HR'),
    (2, 'Engineering'),
    (3, 'Marketing'),
    (4, 'Finance'),
    (5, 'Sales');


INSERT INTO Employees (ssn, employee_name, employment_type, phone_number, department_id, tax_id, insurance_id) VALUES
    ('111-11-1111', 'John Doe', 'Full-time', '1234567890', 1, 1, 4),
    ('222-22-2222', 'Jane Doe', 'Part-time', '0987654321', 2, 2, 2),
    ('333-33-3333', 'Alice Smith', 'Full-time', '1357934680', 3, 3, 3),
    ('444-44-4444', 'Bob Smith', 'Part-time', '1233967890', 4, 4, 4),
    ('555-55-5555', 'Carol Johnson', 'Full-time', '0123456789', 5, 5, 4),
    ('666-66-6666', 'David Johnson', 'Part-time', '9876543210', 1, 1, 1),
    ('777-77-7777', 'Emily Williams', 'Full-time', '9984654321', 2, 2, 2),
    ('888-88-8888', 'Frank Williams', 'Part-time', '1357924680', 3, 3, 3),
    ('999-99-9999', 'Grace Brown', 'Full-time', '2462139790', 4, 4, 4),
    ('000-00-0000', 'Henry Brown', 'Part-time', '2468135790', 5, 5, 2),
    ('123-45-6789', 'Jannet Joe', 'Full-time', '1234567393', 1, 1, 1),
    ('234-56-7890', 'John Roginson', 'Part-time', '6892649179', 1, 2, 2),
    ('345-67-8901', 'Samantha Smith', 'Full-time', '3406731412', 1, 1, 1),
    ('456-78-9012', 'Michael Smith', 'Part-time', '1794652973', 4, 4, 3),
    ('567-89-0123', 'Emily Johnson', 'Full-time', '9878730971', 4, 4, 2),
    ('678-90-1234', 'David Carry', 'Part-time', '8977826871', 4, 3, 2),
    ('789-01-2345', 'Sarah Williams', 'Full-time', '8751973681', 2, 2, 4),
    ('890-12-3456', 'Michael Williams', 'Part-time', '9861673972', 2, 3, 3),
    ('901-23-4567', 'Emily Brown', 'Full-time', '1638269927', 3, 3, 1),
    ('012-34-5678', 'David Brown', 'Part-time', '7826781972', 3, 2, 1);



INSERT INTO Dependents (employee_ssn, dependent_name, dependent_type) VALUES
    ('111-11-1111', 'Sue Doe', 'Child'),
    ('111-11-1111', 'Mark Doe', 'Child'),
    ('111-11-1111', 'Linda Doe', 'Spouse'),
    ('222-22-2222', 'Tom Doe', 'Child'),
    ('222-22-2222', 'Katie Doe', 'Child'),
    ('222-22-2222', 'Bob Doe', 'Spouse'),
    ('333-33-3333', 'Sam Smith', 'Child'),
    ('333-33-3333', 'Lily Smith', 'Child'),
    ('333-33-3333', 'Johana Smith', 'Spouse'),
    ('444-44-4444', 'Mike Smith', 'Child'),
    ('444-44-4444', 'Carol Smith', 'Child'),
    ('444-44-4444', 'Debbie Smith', 'Spouse'),
    ('555-55-5555', 'Sarah Johnson', 'Child'),
    ('555-55-5555', 'George Johnson', 'Child'),
    ('555-55-5555', 'Carol Johnson', 'Spouse'),
    ('666-66-6666', 'Sue Williams', 'Child'),
    ('666-66-6666', 'Mark Williams', 'Child'),
    ('666-66-6666', 'Garry Johnson', 'Spouse'),
    ('777-77-7777', 'Tom Williams', 'Child'),
    ('777-77-7777', 'Katie Williams', 'Child'),
    ('234-56-7890', 'Carry Roginson', 'Spouse'),
    ('234-56-7890' , 'Joe Roginson' , 'Child');



insert into Paystubs (paystub_date, base_pay, number_regular_hours, number_overtime_hours, tax_id, federal_percent, state_percent, ssn) values
('2022-03-12', 55, 80, 5, 4, 0.32, 0.075, '456-78-9012'),
('2022-07-30', 35, 80, 10, 1, 0.1, 0.04, '345-67-8901'),  
('2022-03-12', 35, 80, 25, 1, 0.1, 0.04, '111-11-1111'),    
('2022-06-04', 40, 80, 10, 5, 0.37, 0.1, '000-00-0000'),  
('2022-06-04', 55, 80, 15, 4, 0.32, 0.075, '999-99-9999'),
('2022-08-27', 55, 80, 25, 3, 0.22, 0.06, '678-90-1234'), 
('2022-11-19', 55, 80, 5, 4, 0.32, 0.075, '456-78-9012'), 
('2022-03-26', 35, 80, 10, 2, 0.12, 0.045, '012-34-5678'),
('2022-02-12', 55, 80, 5, 4, 0.32, 0.075, '444-44-4444'),  
('2022-05-21', 55, 80, 25, 4, 0.32, 0.075, '567-89-0123'),
('2022-06-18', 35, 80, 35, 2, 0.12, 0.045, '012-34-5678'),
('2022-08-27', 55, 80, 10, 3, 0.22, 0.06, '890-12-3456'), 
('2022-05-07', 55, 80, 10, 4, 0.32, 0.075, '999-99-9999'),
('2022-03-26', 35, 80, 35, 2, 0.12, 0.045, '234-56-7890'),
('2022-09-10', 40, 80, 30, 5, 0.37, 0.1, '000-00-0000'),
('2022-01-01', 55, 80, 10, 4, 0.32, 0.075, '567-89-0123'),
('2022-05-07', 40, 80, 15, 5, 0.37, 0.1, '000-00-0000'),
('2022-08-13', 55, 80, 5, 4, 0.32, 0.075, '999-99-9999'),
('2022-06-04', 35, 80, 40, 1, 0.1, 0.04, '111-11-1111'),
('2022-04-09', 55, 80, 40, 4, 0.32, 0.075, '567-89-0123'),
('2022-06-18', 35, 80, 15, 2, 0.12, 0.045, '234-56-7890'),
('2022-06-04', 35, 80, 40, 1, 0.1, 0.04, '111-11-1111'),
('2022-07-30', 35, 80, 35, 3, 0.22, 0.06, '888-88-8888'),
('2022-06-18', 55, 80, 35, 4, 0.32, 0.075, '999-99-9999'),
('2022-01-29', 40, 80, 25, 5, 0.37, 0.1, '555-55-5555'),
('2022-03-26', 55, 80, 20, 3, 0.22, 0.06, '678-90-1234'),
('2022-02-26', 35, 80, 25, 1, 0.1, 0.04, '123-45-6789'),
('2022-11-19', 35, 80, 20, 3, 0.22, 0.06, '901-23-4567'),
('2022-10-08', 35, 80, 20, 3, 0.22, 0.06, '888-88-8888'),
('2022-10-22', 35, 80, 20, 1, 0.1, 0.04, '111-11-1111');

insert into Bonuses (amount, bonus_type, ssn) values
    ( 1000, 'Signing', '123-45-6789'),
    ( 3000, 'Holiday', '111-11-1111'),
    ( 7000, 'Holiday', '222-22-2222'),
    ( 2000, 'Holiday', '333-33-3333'),
    ( 2000, 'Holiday', '444-44-4444'),
    ( 2000, 'Holiday', '555-55-5555'),
    ( 2000, 'Holiday', '666-66-6666'),
    ( 2000, 'Signing', '777-77-7777'),
    ( 2000, 'Signing', '888-88-8888'),
    ( 2000, 'Holiday', '999-99-9999'),
    ( 2000, 'Signing', '000-00-0000'),
    ( 3000, 'Holiday', '234-56-7890'),
    ( 1000, 'Holiday', '345-67-8901'),
    ( 3000, 'Signing', '456-78-9012'),
    ( 2000, 'Signing', '567-89-0123'),
    ( 3000, 'Holiday', '890-12-3456'),
    ( 5000, 'Signing', '678-90-1234'),
    (4000, 'Signing','789-01-2345'),
    (1200, 'Holiday', '901-23-4567'),
    (2000, 'Holiday' , '012-34-5678'),
    (4500, 'Holiday', '111-11-1111'),
    (2000, 'Holiday', '222-22-2222'),
    (1000, 'Signing', '333-33-3333'),
    (2000, 'Holiday', '444-44-4444'),
    (1000, 'Holiday', '555-55-5555'),
    (1000, 'Holiday', '666-66-6666'),
    (4500, 'Holiday', '777-77-7777'),
    (2500, 'Holiday', '888-88-8888'),
    (3500, 'Holiday', '999-99-9999'),
    (3500, 'Signing', '000-00-0000'),
    (3500, 'Signing', '123-45-6789'),
    (2000, 'Holiday', '234-56-7890'),
    (4000, 'Signing', '345-67-8901'),
    (4500, 'Signing', '456-78-9012'),
    (2500, 'Holiday', '567-89-0123'),
    (3000, 'Signing', '678-90-1234'),
    (3500, 'Holiday', '789-01-2345'),
    (4500, 'Holiday', '890-12-3456'),
    (3500, 'Holiday', '901-23-4567'),
    (4500, 'Holiday', '012-34-5678');

insert into Immigration (ssn, sponsorship_status, immigration_type) values 
('111-11-1111', 'Unsponsored', 'Citizen'),
('222-22-2222', 'Unsponsored', 'Citizen'),
('333-33-3333', 'Unsponsored', 'Citizen'),
('444-44-4444', 'Sponsored', 'H1-B'),
('555-55-5555', 'Unsponsored', 'Citizen'),
('666-66-6666', 'Unsponsored', 'Citizen'),
('777-77-7777', 'Sponsored', 'H1-B'),
('888-88-8888', 'Sponsored', 'O-1'),
('999-99-9999', 'Unsponsored', 'Citizen'),
('000-00-0000', 'Sponsored', 'H1-B'),
('123-45-6789', 'Unsponsored', 'Citizen'),
('234-56-7890', 'Unsponsored', 'Citizen'),
('345-67-8901', 'Unsponsored', 'Citizen'),
('456-78-9012', 'Unsponsored', 'Citizen'),
('567-89-0123', 'Unsponsored', 'Citizen'),
('678-90-1234', 'Sponsored', 'H1-B'),
('789-01-2345', 'Sponsored', 'J-1'),
('890-12-3456', 'Sponsored', 'E-3'),
('901-23-4567', 'Unsponsored', 'Citizen'),
('012-34-5678', 'Sponsored', 'O-1');


insert into Takes_Leaves (reason, leave_date, emp_ssn) values 
('Sick', '2022-11-01', '111-11-1111'),
('Sick', '2022-11-06', '222-22-2222'),
( 'Sick', '2022-12-07', '222-22-2222'),
( 'Tired', '2022-03-16', '444-44-4444'),
( 'Sick', '2022-03-17', '222-22-2222'),
( 'Sick', '2022-07-18', '345-67-8901'),
( 'Sick', '2022-07-19', '456-78-9012'),
( 'Tired', '2022-05-21', '111-11-1111'),
( 'Tired', '2022-08-10', '345-67-8901'),
( 'Sick', '2022-04-03', '456-78-9012'),
( 'Sick', '2022-04-02', '111-11-1111'),
( 'Sick', '2022-04-01', '333-33-3333'),
( 'Sick', '2022-11-13', '222-22-2222'),
( 'Tired', '2022-10-24', '456-78-9012'),
( 'Sick', '2022-10-02', '345-67-8901'),
( 'Didnt feel like it', '2022-03-28', '000-00-0000'),
( 'Didnt feel like it', '2022-06-12', '000-00-0000'),
( 'Didnt feel like it', '2022-08-11', '222-22-2222'),
( 'Didnt feel like it', '2022-09-12', '000-00-0000'),
( 'Didnt feel like it', '2022-03-18', '222-22-2222'),
( 'Sick', '2022-10-02', '456-78-9012'),
( 'Sick', '2022-11-22', '222-22-2222'),
( 'Sick', '2022-10-22', '456-78-9012'),
( 'Sick', '2022-11-02', '901-23-4567'),
( 'Tired', '2022-05-20', '111-11-1111'),
( 'Tired', '2022-01-27', '456-78-9012'),
( 'Tired', '2022-03-29', '678-90-1234'),
( 'Tired', '2022-08-11', '890-12-3456'),
( 'Tired', '2022-04-11', '890-12-3456'),
( 'Tired', '2022-05-09', '890-12-3456'),
( 'Tired', '2022-01-05', '234-56-7890'),
( 'Tired', '2022-02-17', '901-23-4567'),
( 'Tired', '2022-04-18', '890-12-3456'),
( 'Tired', '2022-09-26', '234-56-7890'),
( 'Tired', '2022-07-02', '901-23-4567'),
( 'Sick', '2022-01-12', '111-11-1111'),
( 'Sick', '2022-04-14', '890-12-3456'),
( 'Sick', '2022-08-12', '678-90-1234'),
( 'Sick', '2022-02-02', '678-90-1234'),
( 'Sick', '2022-05-10', '555-55-5555'),
( 'Sick', '2022-06-28', '555-55-5555'),
( 'Sick', '2022-09-30', '234-56-7890'),
( 'Didnt feel like it', '2022-08-21', '555-55-5555'),
( 'Didnt feel like it', '2022-08-22', '999-99-9999'),
( 'Didnt feel like it', '2022-08-23', '555-55-5555'),
( 'Didnt feel like it', '2022-04-11', '999-99-9999');

22-02-02', '678-90-1234'),
( 'Sick', '2022-05-10', '555-55-5555'),
( 'Sick', '2022-06-28', '555-55-5555'),
( 'Sick', '2022-09-30', '234-56-7890'),
( 'Didnt feel like it', '2022-08-21', '555-55-5555'),
( 'Didnt feel like it', '2022-08-22', '999-99-9999'),
( 'Didnt feel like it', '2022-08-23', '555-55-5555'),
( 'Didnt feel like it', '2022-04-11', '999-99-9999');

