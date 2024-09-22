import re
import time
import datetime

from databases import Database
from collections import Counter

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

database = Database("sqlite:///sqlite/database.sqlite")

@app.on_event("startup")
async def startup():
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

# ---------------------------------------------------------------------------------------------------------------------

async def fetchall(query: str, values: dict = None):
    rows = await database.fetch_all(query=query, values=values)
    return [dict(row) for row in rows]

# ---------------------------------------------------------------------------------------------------------------------
# Root Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get('/')
@app.head('/')
async def root():
    uptime = datetime.datetime.now() - started_at
    return { "status": "running", "uptime": str(uptime) }

# ---------------------------------------------------------------------------------------------------------------------
# Latest Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/latest")
async def latest(page: int = 0, limit: int = 50):

    started = time.time()

    items = await fetchall(
        "SELECT objectId, ratio, prompt FROM DBItem ORDER BY createdAt DESC LIMIT :limit OFFSET :offset",
        {"limit": limit, "offset": page * limit}
    )

    duration = int((time.time() - started) * 1000)

    return {
        "data": items,
        "count": len(items),
        "duration": duration
    }

# ---------------------------------------------------------------------------------------------------------------------
# Items Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/items")
async def items(query: str, page: int = 0, limit: int = 50):

    if not query:
        raise HTTPException(status_code=400, detail="Missing query parameter")

    started = time.time()

    items = await fetchall(
        "SELECT * FROM DBSearch WHERE prompt MATCH :query LIMIT :limit OFFSET :offset",
        {"query": query, "limit": limit, "offset": page * limit}
    )

    total = await fetchall(
        "SELECT COUNT(*) AS count FROM DBSearch WHERE prompt MATCH :query",
        {"query": query}
    )

    duration = int((time.time() - started) * 1000)

    return {
        "data": items,
        "count": len(items),
        "total": total[0]["count"],
        "duration": duration
    }

# ---------------------------------------------------------------------------------------------------------------------
# Search Endpoint
# ---------------------------------------------------------------------------------------------------------------------

@app.get("/search")
async def search_items(query: str, limit: int = 50):

    if not query:
        raise HTTPException(status_code=400, detail="Missing query parameter")

    started = time.time()

    text = query.lower()
    rows = await fetchall(
        "SELECT * FROM DBSearch WHERE prompt MATCH :query LIMIT 10000",
        {"query": text + '*'}
    )

    suggestion_counts = Counter()

    for row in rows:
        prompt = re.sub(r'[^\w\s]|_', '', row['prompt'].lower())
        if text in prompt:
            upper_bound = prompt.index(text) + len(text)
            if upper_bound <= len(prompt):
                remaining_text = prompt[upper_bound:]
                if ' ' in remaining_text:
                    next_space = remaining_text.index(' ')
                    next_word = remaining_text[:next_space]
                    suggestion = f"{text}{next_word}"
                    suggestion_counts[suggestion] += 1

    suggestions = sorted(suggestion_counts, key=suggestion_counts.get, reverse=True)[:limit]

    duration = int((time.time() - started) * 1000)

    return {
        "suggestions": suggestions,
        "count": len(suggestions),
        "duration": duration
    }

# ---------------------------------------------------------------------------------------------------------------------
