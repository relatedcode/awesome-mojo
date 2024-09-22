import os
import configparser

# -------------------------------------------------------------------------------------------------

config = configparser.ConfigParser()
config.read('config.ini')

dir_sqlite = config['default'].get('dir_sqlite')
file_sqlite = config['default'].get('file_sqlite')

# -------------------------------------------------------------------------------------------------

sql = """
DROP TABLE IF EXISTS DBSearch;
CREATE VIRTUAL TABLE DBSearch USING fts5(objectId, title, description);
INSERT INTO DBSearch SELECT objectId, title, description FROM DBItem;
"""

print("> Preparing FTS...")
os.system(f'echo "{sql}" | sqlite3 {dir_sqlite}/{file_sqlite}')

# -------------------------------------------------------------------------------------------------

sql = """
CREATE INDEX IF NOT EXISTS idx_dbitem_createdat ON DBItem(createdAt);
"""

print("> Preparing Indexes...")
os.system(f'echo "{sql}" | sqlite3 {dir_sqlite}/{file_sqlite}')

# -------------------------------------------------------------------------------------------------
