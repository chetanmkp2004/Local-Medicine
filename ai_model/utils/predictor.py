from __future__ import annotations

import os
import json
from dataclasses import dataclass
from typing import List

import pandas as pd
import torch
from sentence_transformers import SentenceTransformer, util


DEFAULT_DATASET_PATHS = [
    os.path.join(os.path.dirname(os.path.dirname(__file__)), 'data', 'symptoms_medicines_en.csv'),
    os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 'Ai', 'symptoms_medicines_en.csv'),
]

MODEL_NAME = 'sentence-transformers/all-MiniLM-L6-v2'
EMB_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'models', 'medicine_predictor.pt')
META_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'models', 'medicine_predictor_meta.json')


@dataclass
class Suggestion:
    medicine: str
    score: float


class MedicinePredictor:
    def __init__(self, dataset_path: str | None = None, device: str | None = None):
        self.dataset_path = dataset_path or self._resolve_dataset_path()
        self.device = device or ('cuda' if torch.cuda.is_available() else 'cpu')
        self.model = SentenceTransformer(MODEL_NAME, device=self.device)
        self.symptoms: List[str] = []
        self.medicines_lists: List[List[str]] = []
        self.embeddings: torch.Tensor | None = None
        self._load_or_build()

    def _resolve_dataset_path(self) -> str:
        for p in DEFAULT_DATASET_PATHS:
            if os.path.exists(p):
                return p
        raise FileNotFoundError(
            f"symptoms_medicines_en.csv not found. Checked: {DEFAULT_DATASET_PATHS}"
        )

    def _load_dataset(self):
        df = pd.read_csv(self.dataset_path)
        # expected columns: symptoms, medicines; medicines are pipe-separated
        if 'symptoms' not in df.columns or 'medicines' not in df.columns:
            raise ValueError("Dataset must have 'symptoms' and 'medicines' columns")
        self.symptoms = [str(s) for s in df['symptoms'].fillna('')]
        self.medicines_lists = [str(m).split('|') for m in df['medicines'].fillna('')]

    def _load_or_build(self):
        try:
            if os.path.exists(EMB_PATH) and os.path.exists(META_PATH):
                data = torch.load(EMB_PATH, map_location='cpu')
                self.embeddings = data
                with open(META_PATH, 'r', encoding='utf-8') as f:
                    meta = json.load(f)
                self.symptoms = meta['symptoms']
                self.medicines_lists = meta['medicines_lists']
                return
        except Exception:
            # fall through to rebuild
            pass

        # build from dataset
        self._load_dataset()
        emb = self.model.encode(self.symptoms, convert_to_tensor=True, show_progress_bar=False)
        self.embeddings = emb.cpu()
        torch.save(self.embeddings, EMB_PATH)
        with open(META_PATH, 'w', encoding='utf-8') as f:
            json.dump({'symptoms': self.symptoms, 'medicines_lists': self.medicines_lists}, f, ensure_ascii=False)

    def predict(self, query: str, top_k: int = 5) -> List[Suggestion]:
        if not query.strip():
            return []
        if self.embeddings is None:
            return []
        q_emb = self.model.encode([query], convert_to_tensor=True, show_progress_bar=False)
        cos_scores = util.cos_sim(q_emb, self.embeddings)[0]
        top_k = min(top_k, len(self.symptoms))
        top_results = torch.topk(cos_scores, k=top_k)
        # Aggregate medicines from top rows, keep unique order by best score
        agg = []
        seen = set()
        for score, idx in zip(top_results.values.tolist(), top_results.indices.tolist()):
            meds = self.medicines_lists[idx]
            for med in meds:
                med = med.strip()
                if med and med not in seen:
                    seen.add(med)
                    agg.append(Suggestion(medicine=med, score=float(score)))
                if len(agg) >= top_k:
                    break
            if len(agg) >= top_k:
                break
        return agg
