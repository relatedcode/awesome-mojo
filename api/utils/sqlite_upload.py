import os
import configparser

# -------------------------------------------------------------------------------------------------

config = configparser.ConfigParser()
config.read('config.ini')

user = config['default'].get('user')
host = config['default'].get('host')

dir_server = config['default'].get('dir_server')
dir_sqlite = config['default'].get('dir_sqlite')
file_sqlite = config['default'].get('file_sqlite')

# -------------------------------------------------------------------------------------------------

print("> Uploading database...")
os.system(f"rsync -avz --progress {dir_sqlite}/{file_sqlite}.gz {user}@{host}:{dir_server}/{dir_sqlite}")
