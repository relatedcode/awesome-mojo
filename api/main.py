import re
import time
import datetime

from collections import Counter

# ---------------------------------------------------------------------------------------------------------------------
from sqlmodel import SQLModel, Field
from sqlmodel import create_engine
from sqlmodel import Session, select
from sqlalchemy.sql import func

# ---------------------------------------------------------------------------------------------------------------------
from fastapi import FastAPI
from fastapi import HTTPException
from fastapi.middleware.cors import CORSMiddleware

# ---------------------------------------------------------------------------------------------------------------------

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# ---------------------------------------------------------------------------------------------------------------------

started_at = datetime.datetime.now()

# ---------------------------------------------------------------------------------------------------------------------

class DBItem(SQLModel, table=True):
    __tablename__ = "DBItem"

    objectId: str = Field(primary_key=True)
    ratio: float
    prompt: str
    createdAt: str

class DBSearch(SQLModel, table=True):
    __tablename__ = "DBSearch"

    objectId: str = Field(primary_key=True)
    ratio: float
    prompt: str

class DBWord(SQLModel, table=True):
    __tablename__ = "DBWord"

    objectId: str = Field(primary_key=True)
    word: str
    counter: int

# ---------------------------------------------------------------------------------------------------------------------

engine = create_engine("sqlite:///sqlite/database.sqlite")

# ---------------------------------------------------------------------------------------------------------------------

def sanitize(query: str) -> str:

    sanitized = re.sub(r'[^\w\s]', '', query)
    sanitized = ' '.join(sanitized.split())

    if query.endswith(' '):
        sanitized += ' '

    return sanitized

# ---------------------------------------------------------------------------------------------------------------------

def duration(started: float) -> int:

    return int((time.time() - started) * 1000)

# ---------------------------------------------------------------------------------------------------------------------
# Root Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get('/')
@app.head('/')
async def root() -> dict:
    uptime = datetime.datetime.now() - started_at
    return { "status": "running", "uptime": str(uptime) }

# ---------------------------------------------------------------------------------------------------------------------
# Latest Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/latest")
async def latest(page: int = 0, limit: int = 5) -> dict:

    started = time.time()

    with Session(engine) as session:
        statement = select(DBItem).order_by(DBItem.createdAt.desc()).offset(page * limit).limit(limit)
        items = session.exec(statement).all()

        return {
            "data": items,
            "count": len(items),
            "duration": duration(started)
        }

# ---------------------------------------------------------------------------------------------------------------------
# Items Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/items")
async def items(query: str, page: int = 0, limit: int = 5) -> dict:

    started = time.time()
    cleared = sanitize(query)

    if not cleared:
        raise HTTPException(status_code=400, detail="Invalid query parameter")

    with Session(engine) as session:
        statement = select(DBSearch).where(DBSearch.prompt.match(cleared)).offset(page * limit).limit(limit)
        items = session.exec(statement).all()

        statement = select(func.count()).select_from(DBSearch).where(DBSearch.prompt.match(cleared))
        total = session.exec(statement).first()

        return {
            "data": items,
            "count": len(items),
            "total": total,
            "duration": duration(started)
        }

# ---------------------------------------------------------------------------------------------------------------------
# Search Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/search")
async def search(query: str, limit: int = 5) -> dict:

    started = time.time()
    cleared = sanitize(query)

    if not cleared:
        raise HTTPException(status_code=400, detail="Invalid query parameter")

    text = cleared.lower()

    with Session(engine) as session:
        statement = select(DBSearch).where(DBSearch.prompt.match(text + '*')).limit(10000)
        rows = session.exec(statement).all()

        result = suggestions(rows, text, limit)

        return {
            "suggestions": result,
            "count": len(result),
            "duration": duration(started)
        }

# ---------------------------------------------------------------------------------------------------------------------

def suggestions(rows: list[DBSearch], text: str, limit: int) -> list[str]:

    counter = Counter()

    for row in rows:
        prompt = re.sub(r'[^\w\s]|_', '', row.prompt.lower())
        if text in prompt:
            upper_bound = prompt.index(text) + len(text)
            if upper_bound <= len(prompt):
                remaining_text = prompt[upper_bound:]
                if ' ' in remaining_text:
                    next_space = remaining_text.index(' ')
                    next_word = remaining_text[:next_space]
                    suggestion = f"{text}{next_word}"
                    counter[suggestion] += 1

    return sorted(counter, key=counter.get, reverse=True)[:limit]

# ---------------------------------------------------------------------------------------------------------------------
# Random Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/random")
async def random() -> dict:

    started = time.time()

    with Session(engine) as session:
        statement = select(DBWord).order_by(func.random()).limit(1)
        result = session.exec(statement).first()

        if not result:
            raise HTTPException(status_code=404, detail="No words found")

        return {
            "word": result.word,
            "count": result.counter,
            "duration": duration(started)
        }

# ---------------------------------------------------------------------------------------------------------------------
