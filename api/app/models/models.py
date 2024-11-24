from sqlmodel import SQLModel
from sqlmodel import Field

# ---------------------------------------------------------------------------------------------------------------------

class DBItem(SQLModel, table=True):
    __tablename__ = "DBItem"

    objectId: str = Field(primary_key=True)
    ratio: float
    prompt: str
    createdAt: str

# ---------------------------------------------------------------------------------------------------------------------

class DBSearch(SQLModel, table=True):
    __tablename__ = "DBSearch"

    objectId: str = Field(primary_key=True)
    ratio: float
    prompt: str

# ---------------------------------------------------------------------------------------------------------------------

class DBWord(SQLModel, table=True):
    __tablename__ = "DBWord"

    objectId: str = Field(primary_key=True)
    word: str
    counter: int

# ---------------------------------------------------------------------------------------------------------------------
