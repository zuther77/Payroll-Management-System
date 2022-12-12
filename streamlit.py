import pandas as pd
import psycopg2
import streamlit as st
from configparser import ConfigParser

@st.cache
def get_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}

@st.cache
def query_db(sql: str):
    # print(f"Running query_db(): {sql}")

    db_info = get_config()

    # Connect to an existing database
    conn = psycopg2.connect(**db_info)

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

    df = pd.DataFrame(data=data, columns=column_names)

    return df

"## Read tables"

sql_all_table_names = "SELECT relname FROM pg_class WHERE relkind='r' AND relname !~ '^(pg_|sql_)';"
try:
    all_table_names = query_db(sql_all_table_names)["relname"].tolist()
    table_name = st.selectbox("Choose a table", all_table_names)
except:
    st.write("Sorry! Something went wrong with your query, please try again.")

if table_name:
    f"Display the table"

    sql_table = f"SELECT * FROM {table_name};"
    try:
        df = query_db(sql_table)
        st.dataframe(df)
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again."
        )

"## Query by employees"

sql_employee_names = "SELECT employee_name FROM employees;"
try:
    employee_names = query_db(sql_employee_names)["employee_name"].tolist()
    employee_name = st.selectbox("Choose an employee", employee_names)
except:
    st.write("Sorry! Something went wrong with your query, please try again.")

if employee_name:
    sql_employee = f"SELECT * FROM employees WHERE employee_name = '{employee_name}';"
    try:
        employee_info = query_db(sql_employee).loc[0]
        department, type, insurance = (
            employee_info["department_id"],
            employee_info["employment_type"],
            employee_info["insurance_id"],
        )
        st.write(
            f"{employee_name} is a part of the {department} department, is a {type} employee, and has insurance plan {insurance}."
        )
    except:
        st.write(
            "Sorry! Something went wrong with your query, please try again."
        )
