import requests
import json
import time

def test_service():
    url = "http://localhost:8001"
    
    # First test health endpoint
    print("Testing health endpoint...")
    try:
        resp = requests.get(f"{url}/health", timeout=5)
        print(f"✓ Health check: {resp.json()}")
    except Exception as e:
        print(f"✗ Health check failed: {e}")
        return
    
    # Test English symptoms
    print("\nTesting English symptoms...")
    try:
        resp = requests.post(
            f"{url}/predict_medicine",
            json={"symptoms": "fever and headache"},
            timeout=10
        )
        print(f"Status: {resp.status_code}")
        if resp.ok:
            data = resp.json()
            print(json.dumps(data, indent=2))
        else:
            print(f"Error: {resp.text}")
    except Exception as e:
        print(f"✗ Request failed: {e}")

if __name__ == "__main__":
    print("Waiting 2 seconds for service to be ready...")
    time.sleep(2)
    test_service()
