
# Smart Livestock Health Surveillance & Decision-Support Backend

FastAPI + Supabase (PostgreSQL) backend connecting:
**Farmers → Field Veterinarians / Para-vets → Diagnostic Laboratories → Government Veterinary Officers**

---

## 🚀 Key Features

1. **Automated Clinical Triage Engine (`POST /api/v1/triage`)**:
   - Immediate clinical risk stratification (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`).
   - Differential disease detection (Foot-and-Mouth Disease, Hemorrhagic Septicemia, Black Quarter, Anthrax).
   - Clear veterinary decision-support disclaimer (`Suspected Condition ≠ Confirmed Diagnosis`).

2. **Full Lifecycle Case State Machine**:
   - Transition pipeline: `SUBMITTED` → `UNDER_REVIEW` → `VET_ASSIGNED` → `VISIT_SCHEDULED` → `INVESTIGATION` → `SAMPLE_COLLECTED` → `LAB_REFERRED` → `RESULT_AVAILABLE` → `TREATMENT_STARTED` → `CONTAINED` / `CASE_CLOSED`.
   - Immutable audit trail with actor tracking (`case_timeline_events`).

3. **Multi-Role RBAC & Row Level Security (RLS)**:
   - Dedicated permissions for `FARMER`, `VETERINARIAN`, `PARAVET`, `LAB_STAFF`, `GOVERNMENT_OFFICER`, and `ADMIN`.

4. **Epidemiological Surveillance & Outbreaks**:
   - Outbreak cluster grouping by village, block, and district coordinates.
   - Government advisory drafting and push alerts.

---

## 📂 Project Structure

```
backend/
├── app/
│   ├── main.py                     # FastAPI entry point, CORS, and OpenAPI docs
│   ├── core/                       # Config, JWT authentication, RBAC dependencies
│   ├── db/                         # Supabase client connector
│   ├── models/                     # Pydantic schemas (Request/Response validation)
│   ├── services/                   # Business logic (Triage, Case, Surveillance)
│   └── api/v1/                     # REST API routers
│       ├── auth.py
│       ├── cases.py
│       ├── animals.py
│       ├── triage.py
│       ├── samples.py
│       ├── vaccinations.py
│       ├── clusters.py
│       ├── advisories.py
│       └── dashboard.py
├── migrations/
│   ├── 001_initial_schema.sql      # 16 PostgreSQL tables, enums & indexes
│   ├── 002_rls_policies.sql        # Supabase Row Level Security policies
│   └── 003_seed_data.sql           # Maharashtra pilot demo dataset
├── tests/                          # Automated Pytest suite
├── requirements.txt                # Python dependencies
├── .env.example                    # Environment variables template
└── README.md
```

---

## 🛠️ Quickstart & Setup

### 1. Create Virtual Environment & Install Dependencies

```bash
cd backend
python -m venv venv
venv\Scripts\activate      # Windows
# or source venv/bin/activate on Linux/macOS

pip install -r requirements.txt
```

### 2. Environment Configuration

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

If connecting to a live Supabase project, supply your credentials in `.env`:
```ini
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_KEY="your-anon-or-service-role-key"
```
*(Note: The backend operates with a built-in memory/demo store when Supabase credentials are not provided, allowing instant testing and development offline).*

### 3. Apply Database Migrations (in Supabase SQL Editor or psql)

Run the SQL migration scripts in order:
1. `migrations/001_initial_schema.sql`
2. `migrations/002_rls_policies.sql`
3. `migrations/003_seed_data.sql`

### 4. Run the API Server

```bash
uvicorn app.main:app --reload --port 8000
```

- **API Base**: `http://localhost:8000/api/v1`
- **Interactive Swagger Docs**: `http://localhost:8000/api/v1/docs`
- **ReDoc**: `http://localhost:8000/api/v1/redoc`

---

## 🧪 Running Automated Tests

Run the test suite with `pytest`:
```bash
pytest tests/ -v
```

---

## 🔑 Demo Credentials

| Role | Username / ID | Password | Context |
|---|---|---|---|
| **Farmer** | `9876543210` | `farmer123` | Ramesh Pawar (Uruli Kanchan, Pune) |
| **Veterinarian** | `VET001` | `vet123` | Dr. Rajesh Kumar (Haveli Block) |
| **Government Officer** | `GOV001` | `gov123` | Dr. Anil Deshmukh (District A.H.O.) |
