import pandas as pd
from psycopg2 import create_engine
import os
import glob

def load_data(conn, filepath, table_name):
    # open song file
    dataframe = pd.read_csv(filepath)
    dataframe.to_sql(table_name, con=conn, index=False, if_exists='replace')


def process_data(conn, filepath, func):
    # get all files matching extension from directory
    all_files = []
    for root, dirs, files in os.walk(filepath):
        files = glob.glob(os.path.join(root, '*.csv'))
        for f in files:
            all_files.append(os.path.abspath(f))

    # get total number of files found
    num_files = len(all_files)
    print('{} files found in {}'.format(num_files, filepath))

    # Change list items to preferred table names
    datasetNames = ['covidDeaths', 'covidVaccinations']

    # iterate over files and process
    for i, datafile in enumerate(all_files, 1):
        func(conn, datafile, datasetNames[i])
        print('{}/{} files processed.'.format(i, num_files))

def main():
    engine = create_engine("postgresql://postgres:superuser@localhost/covidDataAnalytics")
    conn = engine.connect()
    
    process_data(conn, filepath='../datasets', func=load_data)

    conn.close()


if __name__ == "__main__":
    main()