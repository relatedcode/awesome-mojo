FROM python:3.12-alpine

ENV PYTHONUNBUFFERED=True

COPY --from=ghcr.io/astral-sh/uv:0.5.4 /uv /bin/

ENV UV_SYSTEM_PYTHON=1

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN uv pip install -r /code/requirements.txt

COPY ./app /code/app
