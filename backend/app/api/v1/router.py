from fastapi import APIRouter
from app.api.v1.advisories import router as advisories_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.animals import router as animals_router
from app.api.v1.auth import router as auth_router
from app.api.v1.cases import router as cases_router
from app.api.v1.clusters import router as clusters_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.v1.samples import router as samples_router
from app.api.v1.triage import router as triage_router
from app.api.v1.vaccinations import router as vaccinations_router

api_router = APIRouter()

api_router.include_router(auth_router)
api_router.include_router(cases_router)
api_router.include_router(triage_router)
api_router.include_router(animals_router)
api_router.include_router(samples_router)
api_router.include_router(vaccinations_router)
api_router.include_router(clusters_router)
api_router.include_router(advisories_router)
api_router.include_router(dashboard_router)
api_router.include_router(alerts_router)
