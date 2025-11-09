# Deploy AI Service to Hugging Face Spaces (Docker)

This guides you to deploy the AI symptom-to-medicine API (FastAPI) as a separate Space.

## 1) Create a new Space

- Go to https://huggingface.co/new-space
- Name: `local-medicine-ai` (or your choice)
- Hardware: CPU Basic is enough
- Space SDK: `Docker`
- Visibility: Public or Private
- Create Space

## 2) Push code from this repo

Initialize the Space as a Git repo and push only the `ai_model/` folder contents and the Dockerfile inside it.

```bash
# In the root of your repo
cd ai_model

# Initialize and push (replace <your-username>/<space-name>.git)
git init
git branch -M main
git remote add origin https://huggingface.co/spaces/<your-username>/<space-name>

git add .
git commit -m "Deploy AI service"
git push -u origin main
```

Notes:
- Ensure the `Dockerfile` lives at the root of the Space (which is `ai_model/` in this case).
- The Space will automatically build the image and run `python -m main` exposing `PORT`.

## 3) Verify health

After build completes, open the Space URL:
- Health: `https://<space-name>.<your-username>.hf.space/health`
- Docs: `https://<space-name>.<your-username>.hf.space/docs`

You should get `{ "status": "ok" }` from `/health`.

## 4) Connect Flutter

Set the AI base URL when running Flutter. You can use the provided script:

- Windows PowerShell:
  - Using run script in repo root:
    ```powershell
    .\run_with_remote_backend.bat
    ```
    Or pass explicit AI URL:
    ```powershell
    .\run_with_remote_backend.bat "https://<space-name>.<your-username>.hf.space"
    ```

- Manually:
  ```powershell
  flutter run `
    --dart-define BACKEND_BASE_URL=https://chetan2710-local-medicine.hf.space `
    --dart-define AI_BASE_URL=https://<space-name>.<your-username>.hf.space
  ```

Release builds will automatically use the hosted backend URL for BACKEND_BASE_URL. For the AI service, set `AI_BASE_URL` explicitly if you want the hosted AI service in release too.

## 5) Environment notes

- The container uses `PORT` provided by HF (default 7860). Our app reads PORT and starts Uvicorn on it.
- We install a lightweight stack plus ML packages (torch/transformers). If build takes too long, you can temporarily remove heavy ML packages in `requirements.txt` and rely on lite mode.

## 6) Troubleshooting

- Build timeouts: reduce dependencies in `requirements.txt` (comment out torch/transformers/sentence-transformers)
- 404 at root: Use `/health` or open `/docs`
- CORS: Since Flutter calls the AI service directly from the app, typical CORS issues are minimal on mobile. For web, enable CORS in FastAPI if needed.

## 7) Optional: Enable CORS for Web

If you plan to call AI service from a Flutter Web app, add this snippet to `ai_model/app/api.py`:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

Then rebuild the Space by pushing a new commit.
