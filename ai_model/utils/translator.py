from functools import lru_cache

from transformers import MarianMTModel, MarianTokenizer


class MarianTranslator:
    def __init__(self, model_name: str):
        self.model_name = model_name
        self.tokenizer = MarianTokenizer.from_pretrained(model_name)
        self.model = MarianMTModel.from_pretrained(model_name)

    @lru_cache(maxsize=256)
    def translate_text(self, text: str) -> str:
        batch = self.tokenizer([text], return_tensors="pt", padding=True)
        gen = self.model.generate(**batch, max_length=256)
        out = self.tokenizer.batch_decode(gen, skip_special_tokens=True)
        return out[0]


class TranslatorService:
    """Bidirectional English<->Telugu translator using MarianMT models."""

    def __init__(self,
                 te_to_en_model: str = "Helsinki-NLP/opus-mt-te-en",
                 en_to_te_model: str = "Helsinki-NLP/opus-mt-en-te"):
        self._te_en = MarianTranslator(te_to_en_model)
        self._en_te = MarianTranslator(en_to_te_model)

    def te_to_en(self, text: str) -> str:
        return self._te_en.translate_text(text)

    def en_to_te(self, text: str) -> str:
        return self._en_te.translate_text(text)
