# Summarize the data for account types of interest
import math
import pandas as pd

# Read the CSV file
df = pd.read_csv('Portfolio_Positions_Nov-01-2025.csv')

# Group by account type and sum
account_types = {'Individual': "Individual", 'BrokerageLink': "BrokerageLink", 'AMAZON 401(K) PLAN': "401k", 'ROTH IRA': "RothIRA", 'Health Savings Account': "HSA"}
account_totals = {}

for account_type in account_types:
    account_totals[account_type] = {'current': 0.0, 'gain': 0.0}

for idx, row in df.iterrows():
    account_name = row['Account Name']
    account_description = row['Description']
    if account_name not in account_types:
        continue

    # Brokeragelink also appears under 401k, don't double count
    if account_description == "BROKERAGELINK":
        continue

    current_value = float(row['Current Value'].replace("$", ""))
    total_gain = row['Total Gain/Loss Dollar']
    if type(total_gain) != type("string"):
        # for cash for example, current value exists but gain is nan, i.e. math.isnan() -> True
        # Add current value to total and continue
        account_totals[account_name]['current'] += current_value
        continue

    total_gain = float(total_gain.replace("$", ""))

    account_totals[account_name]['current'] += current_value
    account_totals[account_name]['gain'] += total_gain

print(",".join(account_types.values()))
for acct_type in account_types:
    curr = account_totals[acct_type]['current']
    gain = account_totals[acct_type]['gain']
    print("{}\t{}".format(round(curr, 2), round(gain, 2)))
