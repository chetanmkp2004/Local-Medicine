import requests
import json

BASE_URL = "http://localhost:8001"

def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def test_health():
    print_section("Health Check")
    resp = requests.get(f"{BASE_URL}/health")
    print(f"Status: {resp.status_code}")
    print(json.dumps(resp.json(), indent=2))
    return resp.ok

def test_english_symptoms():
    print_section("Test 1: English Symptoms")
    symptoms = "fever and headache"
    print(f"Input: '{symptoms}'")
    resp = requests.post(
        f"{BASE_URL}/predict_medicine",
        json={"symptoms": symptoms}
    )
    print(f"\nStatus: {resp.status_code}")
    data = resp.json()
    print(json.dumps(data, indent=2))
    return resp.ok

def test_telugu_symptoms():
    print_section("Test 2: Telugu Symptoms")
    symptoms = "జ్వరం మరియు తలనొప్పి"  # fever and headache in Telugu
    print(f"Input: '{symptoms}'")
    resp = requests.post(
        f"{BASE_URL}/predict_medicine",
        json={"symptoms": symptoms}
    )
    print(f"\nStatus: {resp.status_code}")
    data = resp.json()
    print(f"Detected Language: {data['input_language']}")
    print(f"\nNote: In Lite Mode, Telugu text is not translated.")
    print(f"Normalized (EN): {data['normalized_symptoms_en']}")
    print(f"\nSuggestions: {len(data['suggestions'])} found")
    for i, sug in enumerate(data['suggestions'][:3], 1):
        print(f"  {i}. {sug['medicine']} (score: {sug['score']:.3f})")
    return resp.ok

def test_mixed_language():
    print_section("Test 3: Mixed Language (English + Telugu)")
    symptoms = "fever తలనొప్పి cough"
    print(f"Input: '{symptoms}'")
    resp = requests.post(
        f"{BASE_URL}/predict_medicine",
        json={"symptoms": symptoms}
    )
    print(f"\nStatus: {resp.status_code}")
    data = resp.json()
    print(f"Detected Language: {data['input_language']}")
    print(f"Suggestions: {len(data['suggestions'])} found")
    for i, sug in enumerate(data['suggestions'][:3], 1):
        print(f"  {i}. {sug['medicine']} (score: {sug['score']:.3f})")
    return resp.ok

def test_cough_cold():
    print_section("Test 4: Cough and Cold")
    symptoms = "cough and cold"
    print(f"Input: '{symptoms}'")
    resp = requests.post(
        f"{BASE_URL}/predict_medicine",
        json={"symptoms": symptoms}
    )
    print(f"\nStatus: {resp.status_code}")
    data = resp.json()
    print(f"Suggestions:")
    for i, sug in enumerate(data['suggestions'][:5], 1):
        print(f"  {i}. {sug['medicine']} (score: {sug['score']:.3f})")
    return resp.ok

def test_stomach_pain():
    print_section("Test 5: Stomach Issues")
    symptoms = "stomach pain and diarrhea"
    print(f"Input: '{symptoms}'")
    resp = requests.post(
        f"{BASE_URL}/predict_medicine",
        json={"symptoms": symptoms}
    )
    print(f"\nStatus: {resp.status_code}")
    data = resp.json()
    print(f"Suggestions:")
    for i, sug in enumerate(data['suggestions'][:5], 1):
        print(f"  {i}. {sug['medicine']} (score: {sug['score']:.3f})")
    return resp.ok

def test_empty_input():
    print_section("Test 6: Edge Case - Empty Input")
    symptoms = ""
    print(f"Input: ''")
    resp = requests.post(
        f"{BASE_URL}/predict_medicine",
        json={"symptoms": symptoms}
    )
    print(f"\nStatus: {resp.status_code}")
    data = resp.json()
    print(f"Suggestions: {len(data['suggestions'])} found")
    return resp.ok

def main():
    print("\n")
    print("╔" + "="*58 + "╗")
    print("║" + " "*10 + "AI MEDICINE RECOMMENDATION SERVICE" + " "*14 + "║")
    print("║" + " "*20 + "COMPREHENSIVE TEST SUITE" + " "*15 + "║")
    print("╚" + "="*58 + "╝")
    
    tests = [
        ("Health Check", test_health),
        ("English Symptoms", test_english_symptoms),
        ("Telugu Symptoms", test_telugu_symptoms),
        ("Mixed Language", test_mixed_language),
        ("Cough & Cold", test_cough_cold),
        ("Stomach Issues", test_stomach_pain),
        ("Empty Input", test_empty_input),
    ]
    
    results = []
    for name, test_func in tests:
        try:
            success = test_func()
            results.append((name, "✓ PASS" if success else "✗ FAIL"))
        except Exception as e:
            print(f"\n✗ ERROR: {e}")
            results.append((name, "✗ ERROR"))
    
    print_section("TEST SUMMARY")
    for name, status in results:
        print(f"{status:10s} - {name}")
    
    passed = sum(1 for _, status in results if "PASS" in status)
    total = len(results)
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! AI service is fully operational.")
    else:
        print("\n⚠️ Some tests failed. Check errors above.")
    
    print("\n" + "="*60)
    print("Service running at:", BASE_URL)
    print("API Docs:", f"{BASE_URL}/docs")
    print("="*60 + "\n")

if __name__ == "__main__":
    main()
