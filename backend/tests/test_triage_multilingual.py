from app.models.triage import TriageRequest
from app.services.triage_service import TriageService


def test_triage_english():
    req = TriageRequest(
        species="Cow",
        symptoms=["Excessive salivation", "Skin lesions", "Fever"],
        affected_count="3",
        language="en",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    assert res.title == "CRITICAL HEALTH RISK"
    assert "Immediate veterinary attention is required" in res.advice
    assert any("Foot-and-Mouth Disease" in d for d in res.suspected_conditions)


def test_triage_marathi():
    req = TriageRequest(
        species="Cow",
        symptoms=["लाळ", "फोड", "ताप"],
        affected_count="३",
        language="mr",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    # Verify Devanagari script output
    assert "आरोग्य जोखीम" in res.title
    assert "पशुवैद्यकीय मदत" in res.advice
    assert "बाधित जनावराला" in res.recommended_action
    assert any("लाळ्या खुरकूत" in d for d in res.suspected_conditions)


def test_triage_marathi_mortality():
    req = TriageRequest(
        species="Cow",
        symptoms=["Collapse"],
        is_mortality_related=True,
        language="mr",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    assert "मृत्यू" in res.title
    assert "विलगीकरण" in res.recommended_action
    assert any("ॲन्थ्रॅक्स" in d for d in res.suspected_conditions)


def test_triage_hindi():
    req = TriageRequest(
        species="Cow",
        symptoms=["लार", "छाले", "बुखार"],
        affected_count="3",
        language="hi",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    # Verify Devanagari Hindi output
    assert "स्वास्थ्य जोखिम" in res.title
    assert "पशु चिकित्सक" in res.advice
    assert "संगरोध" in res.recommended_action or "अलग" in res.recommended_action
    assert any("खुरपका-मुंहपका" in d for d in res.suspected_conditions)


def test_triage_hindi_mortality():
    req = TriageRequest(
        species="Cow",
        symptoms=[],
        is_mortality_related=True,
        language="hi",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "CRITICAL"
    assert "पशु मृत्यु दर्ज" in res.title
    assert "क्वारंटीन" in res.recommended_action or "संगरोध" in res.recommended_action
    assert any("एंथ्रेक्स" in d for d in res.suspected_conditions)


def test_triage_marathi_medium_risk():
    req = TriageRequest(
        species="Cow",
        symptoms=["ताप"],
        not_eating=True,
        language="mr",
    )
    res = TriageService.assess(req)
    assert res.risk_level == "MEDIUM"
    assert "मध्यम आरोग्य जोखीम" in res.title
    assert "निरीक्षण" in res.advice
