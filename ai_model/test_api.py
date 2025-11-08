import requests
import json

# Test English symptoms
print("=== Test 1: English Symptoms ===")
response = requests.post(
    "http://localhost:8001/predict_medicine",
    json={"symptoms": "fever and headache"}
)
print(f"Status: {response.status_code}")
print(json.dumps(response.json(), indent=2))

print("\n=== Test 2: Telugu Symptoms ===")
response = requests.post(
    "http://localhost:8001/predict_medicine",
    json={"symptoms": "జ్వరం మరియు తలనొప్పి"}
)
print(f"Status: {response.status_code}")
print(json.dumps(response.json(), indent=2))

print("\n=== Test 3: Mixed Language ===")
response = requests.post(
    "http://localhost:8001/predict_medicine",
    json={"symptoms": "fever తలనొప్పి and cough"}
)
print(f"Status: {response.status_code}")
print(json.dumps(response.json(), indent=2))

print("\n=== Test 4: Health Check ===")
response = requests.get("http://localhost:8001/health")
print(f"Status: {response.status_code}")
print(json.dumps(response.json(), indent=2))
