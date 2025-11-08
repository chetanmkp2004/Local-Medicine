"""
Lightweight version of predictor using keyword matching.
Falls back to full ML when transformers/torch are available.
"""
from __future__ import annotations

import os
import json
from dataclasses import dataclass
from typing import List
import pandas as pd


DEFAULT_DATASET_PATHS = [
    os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'symptoms_medicines_en.csv'),
    os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'Ai', 'symptoms_medicines_en.csv'),
]


@dataclass
class Suggestion:
    medicine: str
    score: float


class MedicinePredictor:
    """Simple keyword-based predictor. Upgrades to ML when deps available."""
    
    def __init__(self, dataset_path: str | None = None):
        self.dataset_path = dataset_path or self._resolve_dataset_path()
        self.symptoms: List[str] = []
        self.medicines_lists: List[List[str]] = []
        self._load_dataset()

    def _resolve_dataset_path(self) -> str:
        for p in DEFAULT_DATASET_PATHS:
            if os.path.exists(p):
                return p
        raise FileNotFoundError(
            f"symptoms_medicines_en.csv not found. Checked: {DEFAULT_DATASET_PATHS}"
        )

    def _load_dataset(self):
        df = pd.read_csv(self.dataset_path)
        if 'symptoms' not in df.columns or 'medicines' not in df.columns:
            raise ValueError("Dataset must have 'symptoms' and 'medicines' columns")
        self.symptoms = [str(s).lower() for s in df['symptoms'].fillna('')]
        self.medicines_lists = [str(m).split('|') for m in df['medicines'].fillna('')]

    def predict(self, query: str, top_k: int = 5) -> List[Suggestion]:
        """Simple keyword-based matching."""
        if not query.strip():
            return []
        
        query_lower = query.lower()
        query_words = set(query_lower.replace(';', ' ').split())
        
        # Score each row by keyword overlap
        scores = []
        for idx, symptom_text in enumerate(self.symptoms):
            symptom_words = set(symptom_text.replace(';', ' ').split())
            overlap = len(query_words & symptom_words)
            if overlap > 0:
                # Simple score: overlap / total unique words
                score = overlap / max(len(query_words), len(symptom_words))
                scores.append((score, idx))
        
        # Sort by score descending
        scores.sort(reverse=True)
        
        # Collect unique medicines
        results = []
        seen = set()
        for score, idx in scores[:top_k]:
            meds = self.medicines_lists[idx]
            for med in meds:
                med = med.strip()
                if med and med not in seen:
                    seen.add(med)
                    results.append(Suggestion(medicine=med, score=float(score)))
                if len(results) >= top_k:
                    break
            if len(results) >= top_k:
                break
        
        return results
