"""Integration tests for transaction and expense splitting APIs."""

from fastapi.testclient import TestClient

from src.core.database import Base, engine
from src.main import app

client = TestClient(app)


def reset_db() -> None:
    """Reset database tables for test isolation."""
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)


def test_equal_split_among_three_participants() -> None:
    reset_db()
    payload = {
        "description": "Dinner",
        "total_amount": 120,
        "split_type": "equal",
        "participants": [
            {"user_id": "u1"},
            {"user_id": "u2"},
            {"user_id": "u3"},
        ],
    }
    response = client.post("/shared-expenses", json=payload, headers={"X-User-Id": "u1"})
    assert response.status_code == 201
    data = response.json()
    assert len(data["participants"]) == 3
    shares = sorted(p["share_amount"] for p in data["participants"])
    assert shares == [40.0, 40.0, 40.0]


def test_custom_split_with_matching_total() -> None:
    reset_db()
    payload = {
        "description": "Trip",
        "total_amount": 100,
        "split_type": "custom",
        "participants": [
            {"user_id": "u1", "share_amount": 20},
            {"user_id": "u2", "share_amount": 30},
            {"user_id": "u3", "share_amount": 50},
        ],
    }
    response = client.post("/shared-expenses", json=payload, headers={"X-User-Id": "u1"})
    assert response.status_code == 201
    shares = {p["user_id"]: p["share_amount"] for p in response.json()["participants"]}
    assert shares == {"u1": 20.0, "u2": 30.0, "u3": 50.0}


def test_custom_split_mismatch_should_fail() -> None:
    reset_db()
    payload = {
        "description": "Rent",
        "total_amount": 100,
        "split_type": "custom",
        "participants": [
            {"user_id": "u1", "share_amount": 20},
            {"user_id": "u2", "share_amount": 20},
            {"user_id": "u3", "share_amount": 20},
        ],
    }
    response = client.post("/shared-expenses", json=payload, headers={"X-User-Id": "u1"})
    assert response.status_code == 400
    assert "sum" in response.json()["detail"].lower()


def test_net_balance_between_two_users_multiple_expenses() -> None:
    reset_db()
    first = {
        "description": "Dinner",
        "total_amount": 60,
        "split_type": "custom",
        "participants": [
            {"user_id": "u1", "share_amount": 30},
            {"user_id": "u2", "share_amount": 30},
        ],
    }
    second = {
        "description": "Movie",
        "total_amount": 20,
        "split_type": "custom",
        "participants": [
            {"user_id": "u2", "share_amount": 10},
            {"user_id": "u1", "share_amount": 10},
        ],
    }
    assert client.post("/shared-expenses", json=first, headers={"X-User-Id": "u1"}).status_code == 201
    assert client.post("/shared-expenses", json=second, headers={"X-User-Id": "u2"}).status_code == 201

    response = client.get("/balances", headers={"X-User-Id": "u1"})
    assert response.status_code == 200
    row = response.json()[0]
    assert row["counterparty"] == "u2"
    assert row["owed_to_them"] == 10.0
    assert row["they_owe_you"] == 30.0
    assert row["net"] == 20.0


def test_expense_with_single_participant_fails() -> None:
    reset_db()
    payload = {
        "description": "Solo",
        "total_amount": 50,
        "split_type": "equal",
        "participants": [{"user_id": "u1"}],
    }
    response = client.post("/shared-expenses", json=payload, headers={"X-User-Id": "u1"})
    assert response.status_code == 400
    assert "at least 2 participants" in response.json()["detail"].lower()


def test_unauthorized_access_attempt() -> None:
    reset_db()
    response = client.get("/balances")
    assert response.status_code == 401


def test_users_can_only_access_their_transactions() -> None:
    reset_db()
    create_response = client.post(
        "/transactions",
        json={"description": "Coffee", "amount": 5},
        headers={"X-User-Id": "u1"},
    )
    assert create_response.status_code == 201

    other_user_response = client.get("/transactions", headers={"X-User-Id": "u2"})
    assert other_user_response.status_code == 200
    assert other_user_response.json() == []
