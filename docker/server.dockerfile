FROM python:3.9

# Install python
RUN python3 -m pip install poetry

# Install python dependencies
WORKDIR /server
COPY server/pyproject.toml .
COPY server/poetry.lock .
RUN poetry install --no-dev

# Run server
WORKDIR /server
COPY server/data/ data/
COPY server/jackbox_test_server/ jackbox_test_server/

CMD ["poetry", "run", "uvicorn", "jackbox_test_server:app", "--host", "0.0.0.0", "--port", "5001"]
