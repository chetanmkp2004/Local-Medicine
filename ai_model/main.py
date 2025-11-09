import sys
import os

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import uvicorn
import os

if __name__ == "__main__":
    # Respect PORT env var (used by Hugging Face Spaces). Default to 8001 locally.
    port = int(os.environ.get("PORT", "8001"))
    reload = os.environ.get("RELOAD", "true").lower() == "true"
    uvicorn.run("app.api:app", host="0.0.0.0", port=port, reload=reload)
