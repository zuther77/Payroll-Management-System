psql -d sample_db -a -f Payroll-management-system/create_db.sql
cat Payroll-management-system/data/paystubs.csv | psql -U postgres -d sample_db -c "COPY PAYSTUBS from STDIN CSV HEADER"

