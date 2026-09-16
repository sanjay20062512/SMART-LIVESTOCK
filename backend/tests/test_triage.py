from app.models.triage import TriageRequest
from app.services.triage_service import TriageService


def test_triage_empty_symptoms():
    req = TriageRequest(symptoms=[])
    res = TriageService.assess(req)
    assert res.risk_level == "LOW"
    assert res.requires_vet_review is False


def test_triage_critical_multiple_symptoms():
    # Salivation and lesions indicate FMD critical risk
    req = TriageRequest(
        species="Cow",
        symptoms=["Excessive salivation", "Skin lesions", "Fever"],
        affected_count="3",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    assert res.requires_vet_review is True
    assert res.requires_lab_test is True
    assert any("Foot-and-Mouth" in d for d in res.suspected_conditions)


def test_triage_high_risk_symptom():
    req = TriageRequest(
        species="Cow",
        symptoms=["Breathing problem", "Fever"],
        affected_count="1",
    )
    res = TriageService.assess(req)
    assert res.risk_level in ["HIGH", "CRITICAL"]
    assert res.requires_vet_review is True


def test_triage_mortality_automatic_critical():
    req = TriageRequest(
        species="Cow",
        symptoms=["Collapse"],
        is_mortality_related=True,
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    assert res.risk_score >= 90
    assert "MORTALITY" in res.title
