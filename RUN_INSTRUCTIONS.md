# HealthAI — Complete Run Instructions

## Prerequisites

- Flutter SDK ≥ 3.2.0
- Python 3.11+
- MySQL 8.0+
- Redis (for Celery background tasks)
- Android Studio / Xcode (for mobile emulator)

---

## 1. DATABASE SETUP

```sql
-- Run the schema file:
mysql -u root -p < health_backend/database/schema.sql
```

---

## 2. BACKEND SETUP

```bash
cd health_backend

# Create virtual environment
python -m venv venv
source venv/bin/activate        # Linux/Mac
venv\Scripts\activate           # Windows

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env: set DATABASE_URL, SECRET_KEY

# Train the ML model (required before first use)
python -m app.ml.train

# Start the API server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

API docs available at: http://localhost:8000/docs

---

## 3. FLUTTER SETUP

```bash
cd health_app

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

> Note: Update `AppConstants.baseUrl` in
> `lib/core/constants/app_constants.dart` to match your backend IP
> (e.g., `http://10.0.2.2:8000/api/v1` for Android emulator).

---

## 4. EXAMPLE API CALLS

### Register
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass1234","full_name":"Jane Doe"}'
```

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"pass1234"}'
```

### Log Symptoms
```bash
curl -X POST http://localhost:8000/api/v1/symptoms \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": [
      {"name": "Fever", "severity": 7},
      {"name": "Cough", "severity": 5}
    ],
    "notes": "Started yesterday"
  }'
```

### Get AI Prediction
```bash
curl -X POST http://localhost:8000/api/v1/predict \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": [
      {"name": "Fever", "severity": 8},
      {"name": "Fatigue", "severity": 7},
      {"name": "Cough", "severity": 6}
    ]
  }'
```

### Log Water
```bash
curl -X POST http://localhost:8000/api/v1/water \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"amount_ml": 250}'
```

### Log Sleep
```bash
curl -X POST http://localhost:8000/api/v1/sleep \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "sleep_start": "2026-04-14T23:00:00",
    "sleep_end": "2026-04-15T07:00:00",
    "quality": 4
  }'
```

### Add Medication
```bash
curl -X POST http://localhost:8000/api/v1/medications \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Amoxicillin",
    "dosage": "500mg",
    "frequency": "three_times_daily",
    "schedule_times": ["08:00", "14:00", "20:00"],
    "start_date": "2026-04-15"
  }'
```

### Get Analytics
```bash
curl http://localhost:8000/api/v1/analytics \
  -H "Authorization: Bearer <token>"
```

---

## 5. PROJECT STRUCTURE

```
.
├── health_app/                 # Flutter frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── theme/          # Design system & colors
│   │   │   ├── router/         # GoRouter navigation
│   │   │   ├── constants/      # App-wide constants
│   │   │   └── network/        # Dio HTTP client
│   │   ├── features/
│   │   │   ├── auth/           # Login, register, providers
│   │   │   ├── onboarding/     # Welcome, profile setup
│   │   │   ├── dashboard/      # Home screen, character widget
│   │   │   ├── symptoms/       # Symptom logger, AI insights
│   │   │   ├── analytics/      # fl_chart visualizations
│   │   │   ├── medications/    # Med list & add form
│   │   │   ├── profile/        # User profile
│   │   │   ├── water/          # Water tracker widget
│   │   │   └── sleep/          # Sleep logger
│   │   └── shared/
│   │       └── widgets/        # Reusable UI components
│   └── pubspec.yaml
│
├── health_backend/             # FastAPI backend
│   ├── app/
│   │   ├── main.py             # FastAPI app + lifespan
│   │   ├── core/
│   │   │   ├── config.py       # Settings (Pydantic)
│   │   │   ├── security.py     # JWT + bcrypt
│   │   │   └── database.py     # SQLAlchemy async engine
│   │   ├── models/             # SQLAlchemy ORM models
│   │   ├── schemas/            # Pydantic request/response
│   │   ├── api/v1/             # All REST endpoints
│   │   ├── services/           # Health score engine
│   │   └── ml/
│   │       ├── features.py     # Feature engineering
│   │       ├── train.py        # Model training script
│   │       └── predict.py      # Inference + fallback
│   ├── database/
│   │   └── schema.sql          # MySQL schema
│   ├── requirements.txt
│   └── .env.example
│
└── RUN_INSTRUCTIONS.md
```

---

## 6. ANDROID EMULATOR NOTE

For Android emulator to reach localhost backend:
```dart
// lib/core/constants/app_constants.dart
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
```

For physical device, use your machine's local IP:
```dart
static const String baseUrl = 'http://192.168.1.x:8000/api/v1';
```
