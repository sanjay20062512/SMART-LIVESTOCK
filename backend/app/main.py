from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.router import api_router
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="""
    # Smart Livestock Health Surveillance & Decision-Support System
    Connecting Farmers → Field Veterinarians → Diagnostic Laboratories → Government Veterinary Officers.

    ## Key Capabilities:
    - **Early Disease Reporting**: Multi-symptom collection with photo and voice evidence.
    - **Automated Clinical Triage Engine**: Immediate rule-based epidemiological risk evaluation (LOW to CRITICAL).
    - **Veterinary Casework Pipeline**: Investigation, on-site visit scheduling, clinical observation, and treatment tracking.
    - **Laboratory Referrals**: Biological sample tracking and diagnostic result confirmation.
    - **Government Outbreak Surveillance**: Geospatial outbreak cluster detection and regional health advisory broadcasts.
    """,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API v1 Router
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", tags=["Health Check"])
def health_check():
    return {
        "status": "online",
        "system": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "docs": f"{settings.API_V1_STR}/docs",
    }
