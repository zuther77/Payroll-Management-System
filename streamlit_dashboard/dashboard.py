import pandas as pd
import psycopg2
import streamlit as st
from configparser import ConfigParser


@st.cache
def get_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}


@st.cache(allow_output_mutation=True)
def query_db(sql: str):
    # print(f"Running query_db(): {sql}")

    db_info = get_config()

    # Connect to an existing database
    conn = psycopg2.connect(**db_info)

    # print(conn)

    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Execute a command: this creates a new table
    cur.execute(sql)

    # Obtain data
    data = cur.fetchall()

    column_names = [desc[0] for desc in cur.description]

    # Make the changes to the database persistent
    conn.commit()

    # Close communication with the database
    cur.close()
    conn.close()

    df = pd.DataFrame(data=data, columns=column_names, dtype=None)

    return df


all_employees = "Select employee_name from Employees"


"# Demo: Payroll Managemnet system"

"#### Get most recent 3 paystubs of an employee"

try:
    query_names_1 = query_db(all_employees)["employee_name"].tolist()
    query_selectbox_1 = st.selectbox(
        "Choose an employee", query_names_1, key=1)
except:
    st.write("Sorry! Something went wrong with your query, please try again.")

if query_selectbox_1:

    sql_table_1 = f"SELECT to_char(P.paystub_date, 'MM/DD/YYYY') as \"Paystub_date\", P.number_overtime_hours as \"Overtime_Hours\", P.total_pay, P.total_tax, P.total_pay - P.total_tax as Gross_Amount from Employees E, Paystubs P Where E.ssn = P.ssn and E.employee_name = '{query_selectbox_1}' Order by Paystub_date DESC LIMIT 3;"
    try:
        df1 = query_db(sql_table_1)
        df1["total_pay"] = df1["total_pay"].astype('float')
        df1["total_tax"] = df1["total_tax"].astype('float')
        df1["gross_amount"] = df1["gross_amount"].astype('float')
        st.dataframe(df1)
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again."
        )


"#### Payroll being given from each department"

try:
    method_3 = st.radio(
        "How do you want to view the data", ('Cummulative', 'Monthly'))
    if method_3 == 'Monthly':
        try:
            query_selectbox_3 = st.selectbox(
                "Choose month", list(["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]), key=3)
            st.write(query_selectbox_3)
        except:
            st.write(
                "Sorry! Something went wrong with your query, please try again.")
except:
    st.write(
        "Sorry! Something went wrong with your query, please try again.")

if method_3:
    if method_3 == "Cummulative":
        try:
            sql_3_1 = f"SELECT A.department_name, sum(B.pay) as total_payroll from (SELECT D.department_name, E.ssn From Employees E, Departments D Where E.department_id=D.id group by D.department_name, E.ssn Order By D.department_name) as A JOIN (SELECT P.ssn, sum(P.total_pay) as pay from Paystubs P group by P.ssn) as B ON A.ssn = B.ssn Group by A.department_name;"
            df3_1 = query_db(sql_3_1)
            df3_1["total_payroll"] = df3_1["total_payroll"].astype('float')
            st.dataframe(df3_1)

        except:
            st.write(
                "Sorry! Something went wrong with your query, please try again.")
    if method_3 == "Monthly":
        try:
            sql3_2 = "SELECT A.department_name , sum(B.pay) as total_payroll from (SELECT D.department_name , E.ssn From Employees E , Departments D Where E.department_id = D.id group by D.department_name, E.ssn Order By D.department_name) as A JOIN (SELECT P.ssn , sum(P.total_pay) as pay from Paystubs P where to_char(P.paystub_date, 'Mon') = " + \
                "'" + query_selectbox_3 + "'" + \
                " group by P.ssn) as B ON A.ssn = B.ssn Group by A.department_name;"
            df3_2 = query_db(sql3_2)
            df3_2["total_payroll"] = df3_2["total_payroll"].astype('float')

            st.dataframe(df3_2)
        except:
            st.write(
                "Sorry! Something went wrong with your query, please try again.")


"#### Tax being paid from each department"

try:
    method_2 = st.radio("How do you want to view the data",
                        ('Cummulative', 'Monthly'), key=2)
    if method_2 == 'Monthly':
        try:
            query_textbox_2 = st.text_input(
                "Enter Month ", key=22)
        except:
            st.write(
                "Sorry! Something went wrong with your query, please try again.")
except:
    st.write(
        "Sorry! Something went wrong with your query, please try again.")

if method_2 == "Cummulative":
    try:

        sql2_1 = f"SELECT A.department_name,  sum(B.tax) as total_tax, count(num_employees) from (SELECT D.department_name, E.ssn, count(E.ssn) as num_employees From Employees E, Departments D Where E.department_id=D.id group by D.department_name, E.ssn Order By D.department_name) as A JOIN (SELECT P.ssn, sum(P.total_tax) as tax from Paystubs P group by P.ssn) as B ON A.ssn = B.ssn Group by A.department_name;"
        df2_1 = query_db(sql2_1)
        df2_1["total_tax"] = df2_1["total_tax"].astype('float')
        st.dataframe(df2_1)

    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again.")
if method_2 == "Monthly":
    try:

        sql2_2 = f"SELECT A.department_name,  sum(B.tax) as total_tax, count(num_employees) from (SELECT D.department_name, E.ssn, count(E.ssn) as num_employees From Employees E, Departments D Where E.department_id=D.id group by D.department_name, E.ssn Order By D.department_name) as A JOIN (SELECT P.ssn, sum(P.total_tax) as tax from Paystubs P where to_char(P.paystub_date, 'Mon')='{query_textbox_2}' group by P.ssn) as B ON A.ssn = B.ssn Group by A.department_name;"
        df2_2 = query_db(sql2_2)
        df2_2["total_tax"] = df2_2["total_tax"].astype('float')

        st.dataframe(df2_2)
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again.")


"#### Bonus and insurance type given to each employee"
try:
    query_names_4 = query_db(all_employees)["employee_name"].tolist()
    query_selectbox_4 = st.selectbox(
        "Choose an employee", query_names_4, key=4)

except:
    st.write("Sorry! Something went wrong with your query, please try again.")

if query_selectbox_4:
    f"Display the table"

    sql_table_4 = f"SELECT E.employee_name as Name, sum(B.amount) as Bonus_amount, I.insurance_type FROM Employees E JOIN Insurance I ON E.insurance_id=I.id JOIN Bonuses B   ON B.ssn=E.ssn WHERE E.employee_name = '{query_selectbox_4}' GROUP BY E.employee_name, I.insurance_type ORDER BY E.employee_name;"
    try:
        df = query_db(sql_table_4)
        st.dataframe(df)
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again."
        )

"#### Find tax brackets for employee based on Immigration."

try:
    sponsorship = st.radio(
        "Select Immigartion Category", ('Sponsored', 'Unsponsored'))
except:
    st.write("Sorry! Something went wrong with your query, please try again.")


if sponsorship:
    f"Display the table"

    sql_table_5 = f"SELECT E.employee_name as Name, Tx.federal_percent * 100 as \"Federal_Tax in %\", Tx.state_percent * 100 as \"State_Tax in %\" From Employees E JOIN Taxes Tx ON E.tax_id = Tx.id JOIN Immigration I  ON I.ssn = E.ssn Where I.sponsorship_status = '{sponsorship}' order By E.employee_name "
    try:
        df5 = query_db(sql_table_5)
        df5["Federal_Tax in %"] = df5["Federal_Tax in %"].astype('int')
        df5["State_Tax in %"] = df5["State_Tax in %"].astype('int')

        st.dataframe(df5)
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again."
        )

"#### Count Dependents for each employee"

try:
    query_names_6 = query_db(all_employees)["employee_name"].tolist()
    query_selectbox_6 = st.selectbox(
        "Choose an employee", query_names_6, key=6)
except:
    st.write("Sorry! Something went wrong with your query, please try again.")

if query_selectbox_6:
    sql_6 = f"Select A.name as Employee_name, A.dependent_name as Spouse_name, B.count as \"No.of Children\" from (SELECT E1.employee_name as name, D1.dependent_name from Employees E1, Dependents D1 Where E1.ssn=D1.employee_ssn and D1.dependent_type='Spouse') as A JOIN(SELECT E2.employee_name as name, count(D2.dependent_type) From Employees E2 JOIN Dependents D2 ON E2.ssn=D2.employee_ssn Where D2.dependent_type='Child' Group By E2.employee_name) as B ON A.name = B.name Where A.name = '{query_selectbox_6}'"
    try:
        df6 = query_db(sql_6)

        if len(df6.index):
            st.dataframe(df6)
        else:
            st.write(query_selectbox_6 + " has  no Dependents")
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again."
        )


"#### Get Leaves by a particular employee"

query7_textbox = st.text_input("Enter name of Employee", key=7)
query_names_7 = query_db(all_employees)["employee_name"].tolist()


if query7_textbox:
    if query7_textbox not in query_names_7:
        st.write("No such employee in database")
    else:
        sql_7 = f"SELECT to_char(leave_date, \'Month\') as Month,  count(TL.reason) as count_leaves FROM Takes_Leaves TL, Employees E Where TL.emp_ssn = E.ssn and E.employee_name = '{query7_textbox}' GROUP BY Month, extract(month from TL.leave_date) Order By extract(month from TL.leave_date);"
        try:
            df7 = query_db(sql_7)
            if len(df7.index):
                st.dataframe(df7)
            else:
                st.write(query7_textbox + " has taken no Leaves this year")
        except:
            st.write(
                "Sorry! Something went wrong with your query, please try again."
            )
