# Fintrack API

Fintrack API is a FastAPI + SQLAlchemy backend implementing:
- Remediated Transaction module
- Expense Splitting feature with equal/custom split support
- Pending balance and net-per-person summary APIs

## Tech Stack
- Python 3.11+
- FastAPI
- SQLAlchemy ORM
- Pydantic
- SQLite (default)
- Pytest

## Setup
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn src.main:app --reload
```

## Run Tests
```bash
pytest -q
```
