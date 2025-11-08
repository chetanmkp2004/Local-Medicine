# AI Medicine Recommendation Service

Multi-language (Telugu/English) symptom-to-medicine recommendation API.

## Features

- 🌐 **Multilingual**: Accepts Telugu, English, or mixed input
- 🤖 **Smart Matching**: Keyword-based retrieval (upgradeable to ML embeddings)
- 🔄 **Auto Translation**: Language detection and translation (when ML models installed)
- ⚡ **Lightweight**: Works without heavy ML dependencies for quick testing

## Quick Start

### 1. Install Dependencies

```bash
cd ai_model
pip install -r requirements.txt
```

**Note**: For full ML translation support, you'll need to install transformers and sentencepiece separately. The service works in lite mode without them.

###  2. Run the Service

**Option A**: Using the batch file (recommended):
```bash
cd ..
run_ai_only.bat
```

**Option B**: Using Python directly:
```bash
cd ai_model
python main.py
```

The service will start on **http://localhost:8001**

### 3. Test the API

**Health Check**:
```bash
curl http://localhost:8001/health
```

**Predict Medicine** (English):
```bash
curl -X POST http://localhost:8001/predict_medicine \
  -H "Content-Type: application/json" \
  -d '{"symptoms": "fever and headache"}'
```

**Predict Medicine** (Telugu):
```bash
curl -X POST http://localhost:8001/predict_medicine \
  -H "Content-Type: application/json" \
  -d '{"symptoms": "జ్వరం మరియు తలనొప్పి"}'
```

**View API Docs**: http://localhost:8001/docs

## Architecture

```
Pipeline:
1. Language Detection (langdetect + Telugu Unicode)
2. Translation (Telugu → English if needed)
3. Medicine Prediction (keyword matching)
4. Output Translation (English → Telugu if input was Telugu)
```

### Components

- **`app/api.py`**: FastAPI endpoints
- **`utils/language_detector.py`**: Detects 'en', 'te', or 'mixed'
- **`utils/translator_lite.py`**: Lightweight translator (fallback mode)
- **`utils/translator.py`**: Full MarianMT translator (requires sentencepiece)
- **`utils/predictor_lite.py`**: Keyword-based matching
- **`utils/predictor.py`**: ML embeddings-based (requires sentence-transformers + torch)
- **`data/symptoms_medicines_en.csv`**: Training dataset

## Dataset Format

CSV with two columns:
```csv
symptoms,medicines
fever; headache,Paracetamol 500mg|Dolo 650|Crocin Advance
cough; cold,Benadryl Syrup|Cetrizine 10mg
```

- **symptoms**: Semicolon-separated symptom keywords
- **medicines**: Pipe-separated medicine names

## Upgrade to Full ML

For better accuracy, install the full ML stack:

```bash
pip install torch transformers sentencepiece sentence-transformers
```

Then restart the service. It will automatically:
- Use SentenceTransformer embeddings for retrieval
- Enable Telugu↔English neural translation
- Cache embeddings to `models/medicine_predictor.pt`

## API Reference

### POST /predict_medicine

**Request**:
```json
{
  "symptoms": "జ్వరం మరియు తలనొప్పి"
}
```

**Response**:
```json
{
  "input_language": "te",
  "normalized_symptoms_en": "fever and headache",
  "suggestions": [
    {
      "medicine": "పారాసిటమాల్ 500మిగ్రా",
      "score": 0.85
    },
    {
      "medicine": "డోలో 650",
      "score": 0.75
    }
  ]
}
```

### GET /health

Returns `{"status": "ok"}` if service is running.

## Integration with Flutter

The AI service runs on port 8001, separate from the Django backend (port 8000).

To call from Flutter:
```dart
final response = await http.post(
  Uri.parse('http://localhost:8001/predict_medicine'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'symptoms': userInput}),
);
```

## Troubleshooting

**Import errors on startup**:
- The service uses lite mode by default
- Install full dependencies only if you need ML features

**No translations**:
- Lite mode returns English output for Telugu input
- Install transformers + sentencepiece for translation

**Low accuracy**:
- Expand the dataset in `data/symptoms_medicines_en.csv`
- Add more symptom synonyms
- Upgrade to full ML mode with embeddings

## Performance

- **Lite mode**: <100ms response time
- **Full ML mode** (first query): 2-5s (model loading)
- **Full ML mode** (cached): 200-500ms

## Future Enhancements

- Fine-tune translation models on medical Telugu corpus
- Add caching layer (Redis) for common queries
- Implement feedback loop for accuracy improvement
- Support for batch predictions
- Add confidence thresholds and fallback responses
