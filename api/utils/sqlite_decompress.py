import os
import configparser

# -------------------------------------------------------------------------------------------------

config = configparser.ConfigParser()
config.read('config.ini')

dir_sqlite = config['default'].get('dir_sqlite')
file_sqlite = config['default'].get('file_sqlite')

# -------------------------------------------------------------------------------------------------

print("> Decompressing database...")
os.system(f"gunzip -f {dir_sqlite}/{file_sqlite}.gz")
