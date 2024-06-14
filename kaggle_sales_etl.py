import zipfile
import pandas as pd
from sqlalchemy import create_engine

# urllib.parse: Used to encode the database password safely.
import urllib.parse
import kaggle

# Downloading and Extracting Data:
kaggle datasets download ankitbansal06/retail-orders -f orders.csv
zip_ref = zipfile.ZipFile('orders.csv.zip')
zip_ref.extractall()
zip_ref.close()

# Reading and Initial Data Cleaning:
df = pd.read_csv('orders.csv', na_values=['Not Available', 'unknown'])
pd.set_option('display.max_columns', None)
pd.set_option('display.width', 1000)  # Set width to a large number to prevent wrapping
# print(df['Ship Mode'].unique())

# Data Transformation:
df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ', '_')

# New Metric Calculation:
df['discount_price'] = df['list_price'] * df['discount_percent'] * 0.01
df['sale_price'] = df['list_price'] - df['discount_price']
df['profit'] = df['sale_price'] - df['list_price']
df['order_date'] = pd.to_datetime(df['order_date'], format="%Y-%m-%d")
df.drop(columns=['cost_price', 'discount_percent'], inplace=True)
# print(df.dtypes)

# Database Connection setup
# Define the connection parameters
username = 'root'
password = urllib.parse.quote_plus('a3Jpc2g=')  # Use urllib.parse.quote_plus to encode the password if it contains
# special characters
host = 'localhost'  # or your MySQL server IP
port = '3306'  # default MySQL port is 3306
database = 'sys'
driver = 'pymysql'

# Construct the connection URL
connection_url = f"mysql+{driver}://{username}:{password}@{host}:{port}/{database}"

# Create the engine
engine = create_engine(connection_url)

# Loading Data into MySQL:
conn = engine.connect()
print("Connection successful!")
print(df.columns)
df.to_sql("orders", con=conn, index=False, if_exists='append')
print("created")
# print(df.columns)
# print(df.head(5))
