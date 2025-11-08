from langdetect import detect
import re

TELUGU_RANGE = re.compile(r"[\u0C00-\u0C7F]")


def detect_language(text: str) -> str:
    """
    Detect language label: 'en', 'te', or 'mixed'.
    - Uses langdetect primary signal
    - Uses Telugu unicode block presence to detect te/mixed
    """
    text = text.strip()
    if not text:
        return 'en'

    has_te_chars = bool(TELUGU_RANGE.search(text))

    try:
        lang = detect(text)
    except Exception:
        # Fallback to unicode heuristic
        return 'te' if has_te_chars else 'en'

    if has_te_chars and lang != 'te':
        return 'mixed'

    if lang == 'te':
        return 'te'

    return 'en'
