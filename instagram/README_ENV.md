# Environment setup for API keys

This project uses `flutter_dotenv` to load sensitive configuration from a local `.env` file.

1. Install dependencies:

```bash
flutter pub get
```

2. Create a `.env` file in the project root (do NOT commit it):

```
OPENROUTER_API_KEY=sk-...
OPENROUTER_ENDPOINT=https://openrouter.ai/api/v1/chat/completions
```

3. Run the app:

```bash
flutter run -d chrome
```

4. To test the endpoint with your API key (PowerShell example):

```powershell
$env:OPENROUTER_API_KEY = "sk-...";
$body = '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"hello"}],"max_tokens":50}';
Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" -Method Post -Headers @{"Authorization" = "Bearer $env:OPENROUTER_API_KEY"; "Content-Type" = "application/json"} -Body $body
```

If the endpoint returns 404, try replacing `OPENROUTER_ENDPOINT` with the vendor-provided endpoint (for example, `https://api.openrouter.ai/v1/chat/completions`) in your `.env`.
