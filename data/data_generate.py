import random
import csv
from datetime import datetime
from dateutil.rrule import rrule, DAILY, WEEKLY, MONTHLY


ssn_list = ['111-11-1111', '222-22-2222', '333-33-3333', '444-44-4444', '555-55-5555', '666-66-6666', '777-77-7777', '888-88-8888', '999-99-9999', '000-00-0000',
            '123-45-6789', '234-56-7890', '345-67-8901', '456-78-9012', '567-89-0123', '678-90-1234', '789-01-2345', '890-12-3456', '901-23-4567', '012-34-5678']
sponsorship_status = ['Sponsored', 'Unsponsored']
taxids = [1, 2, 3, 4, 5]
ssn_to_department = {
    '111-11-1111': ['1', '1', '1'],
    '222-22-2222': ['2', '2', '2'],
    '333-33-3333': ['3', '3', '3'],
    '444-44-4444': ['4', '4', '4'],
    '555-55-5555': ['5', '5', '4'],
    '666-66-6666': ['1', '1', '1'],
    '777-77-7777': ['2', '2', '2'],
    '888-88-8888': ['3', '3', '3'],
    '999-99-9999': ['4', '4', '4'],
    '000-00-0000': ['5', '5', '2'],
    '123-45-6789': ['1', '1', '1'],
    '234-56-7890': ['1', '2', '2'],
    '345-67-8901': ['1', '1', '1'],
    '456-78-9012': ['4', '4', '3'],
    '567-89-0123': ['4', '4', '2'],
    '678-90-1234': ['4', '3', '2'],
    '789-01-2345': ['2', '2', '4'],
    '890-12-3456': ['2', '3', '3'],
    '901-23-4567': ['3', '3', '1'],
    '012-34-5678': ['3', '2', '1']
}

depart_to_pay = {
    '1': 35,
    '2': 55,
    '3': 35,
    '4': 55,
    '5': 40
}


tax = {
    '1': [0.1, 0.04],
    '2': [0.12, 0.045],
    '3': [0.22, 0.06],
    '4': [0.32, 0.075],
    '5': [.37, 0.1]
}

start_date = datetime(2022, 1, 1)
dates = list(rrule(WEEKLY, dtstart=start_date, count=24, interval=2))


def generate_immigration():
    with open('immigration.csv', 'w', newline='') as target:
        writer = csv.writer(
            target, delimiter=',', quoting=csv.QUOTE_NONE, escapechar='', quotechar='\n')

        writer.writerow(["ssn", "sponsorship_status", "immigration_type"])

        for i in range(len(ssn_list)):
            a = ssn_list[i]
            b = random.choice(sponsorship_status)
            if b == "Sponsored":
                c = random.choice(['H1-B', 'O-1', 'J-1', 'E-3'])
            else:
                c = "Citizen"

            # immigration.append((a, b, c))
            writer.writerow([a, b, c])


def generate_bonus_table():
    with open("bonus.csv", "w", newline='') as target:
        writer = csv.writer(
            target, delimiter=',', quoting=csv.QUOTE_NONE, escapechar='', quotechar='\n')

        writer.writerow(["amount", "bonus_type", "ssn"])

        for i in range(len(ssn_list)):
            a = random.choice([1000, 2000, 3000, 4000, 2500, 4500, 3500])
            b = random.choice(["Signing", "Holiday"])
            c = ssn_list[i]
            writer.writerow([a, b, c])


def generate_paystub_table():
    with open("paystubs.csv", 'w', newline='') as target:
        writer = csv.writer(
            target, delimiter=',', quoting=csv.QUOTE_NONE, escapechar='', quotechar='\n')
        writer.writerow(["id", "pay_date", "base_pay", "number_regular_hours", "number_overtime_hours",
                        "tax_id", "federal_percent", "state_percent", "ssn"])
        counter = 1
        for ssn in ssn_list:
            for payday in dates:
                # base_pay, number_regular_hours, number_overtime_hours, tax_id, federal_percent, state_percent, ssn
                employee_ssn = ssn
                date = str(payday.date())
                department_id = ssn_to_department[employee_ssn][0]
                base_pay = depart_to_pay[department_id]
                number_of_hours = 80
                overtime_hours = random.choice([10, 20, 30, 35, 5, 15, 25, 40])
                taxid = ssn_to_department[ssn][1]
                fedral = tax[taxid][0]
                state = tax[taxid][1]

                row = (counter, date, base_pay, number_of_hours,
                       overtime_hours, taxid, fedral, state, employee_ssn)
                # print(row, end=',\n')
                # temp.append(row)
                writer.writerow(row)
                counter += 1


def generate_take_leaves():
    pass


if __name__ == "__main__":
    # generate_immigration()
    # generate_bonus_table()
    generate_paystub_table()
