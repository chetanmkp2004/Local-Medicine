from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.language_detector import detect_language

# Use lite versions that work without heavy ML deps
try:
    from utils.predictor import MedicinePredictor
    ML_AVAILABLE = True
except ImportError:
    from utils.predictor_lite import MedicinePredictor
    ML_AVAILABLE = False

# Always use lite translator for now (no sentencepiece)
from utils.translator_lite import TranslatorService

app = FastAPI(title="Local Medicine AI Service", version="1.0.0")

translator = TranslatorService()
predictor = MedicinePredictor()


class PredictRequest(BaseModel):
    symptoms: str


class SuggestionOut(BaseModel):
    medicine: str
    score: float


class PredictResponse(BaseModel):
    input_language: str
    normalized_symptoms_en: str
    suggestions: List[SuggestionOut]


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/predict_medicine", response_model=PredictResponse)
def predict(req: PredictRequest):
    text = req.symptoms.strip()
    lang = detect_language(text)

    query_en = text
    if lang in ("te", "mixed"):
        query_en = translator.te_to_en(text)

    suggestions = predictor.predict(query_en, top_k=5)
    # If original input was Telugu/mixed, translate medicine names back to Telugu
    if lang in ("te", "mixed"):
        translated = []
        for s in suggestions:
            te_name = translator.en_to_te(s.medicine)
            translated.append(SuggestionOut(medicine=te_name, score=s.score))
        out_suggestions = translated
    else:
        out_suggestions = [SuggestionOut(medicine=s.medicine, score=s.score) for s in suggestions]

    return PredictResponse(
        input_language=lang,
        normalized_symptoms_en=query_en,
        suggestions=out_suggestions,
    )
