import os
import paramiko
import configparser

# -------------------------------------------------------------------------------------------------

config = configparser.ConfigParser()
config.read('config.ini')

user = config['default'].get('user')
host = config['default'].get('host')

dir_server = config['default'].get('dir_server')
dir_sqlite = config['default'].get('dir_sqlite')

# -------------------------------------------------------------------------------------------------

temp = ' '.join([
    ".dockerignore",
    "app.py",
    "build.py",
    "Caddyfile",
    "config.ini",
    "docker-compose.dev.yml",
    "docker-compose.yml",
    "Dockerfile",
    "requirements.txt",
    "utils",
    "xdocker"
])

print("> Uploading repository...")
os.system(f"rsync -avz {temp} {user}@{host}:{dir_server}")

# -------------------------------------------------------------------------------------------------

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    print("> Connecting to Server...")
    ssh.connect(host, port=22, username=user)

    print("> Creating directories...")
    ssh.exec_command(f"mkdir -p {dir_server}/{dir_sqlite}")

except Exception as e:
    print(f"Error: {e}")

finally:
    print("> Closing connection.")
    ssh.close()
