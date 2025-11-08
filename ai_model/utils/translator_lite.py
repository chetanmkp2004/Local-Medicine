"""
Lightweight translator - no ML dependencies required.
Returns text as-is (identity function) for development/testing.
For real translation, install: pip install transformers sentencepiece torch
"""
from functools import lru_cache


class TranslatorService:
    """
    Lightweight translator service without ML dependencies.
    
    In lite mode:
    - Telugu to English: Returns original text with note
    - English to Telugu: Returns original text
    
    To enable real translation, ensure transformers + sentencepiece are installed.
    """

    def __init__(self,
                 te_to_en_model: str = "Helsinki-NLP/opus-mt-te-en",
                 en_to_te_model: str = "Helsinki-NLP/opus-mt-en-te"):
        # Lite mode - no actual translation
        self._mode = "lite"

    @lru_cache(maxsize=256)
    def te_to_en(self, text: str) -> str:
        """
        In lite mode: Returns text as-is with a note.
        Telugu input will be processed by keyword matching in English dataset.
        """
        # For development: just return the text
        # The predictor will still work with Telugu keywords if they match
        return text

    @lru_cache(maxsize=256)
    def en_to_te(self, text: str) -> str:
        """
        In lite mode: Returns text as-is.
        English medicine names stay in English.
        """
        return text
