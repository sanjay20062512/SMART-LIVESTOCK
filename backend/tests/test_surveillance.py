def test_farmer_dashboard(client):
    res = client.get("/api/v1/dashboard/farmer")
    assert res.status_code == 200
    data = res.json()
    assert "total_animals" in data
    assert "active_cases" in data


def test_vet_dashboard(client):
    res = client.get("/api/v1/dashboard/vet")
    assert res.status_code == 200
    data = res.json()
    assert "total_assigned_cases" in data
    assert "active_outbreak_clusters" in data


def test_govt_surveillance_and_advisory(client):
    # 1. Login as Govt Officer
    gov_login = client.post("/api/v1/auth/login", json={"phone_or_id": "GOV001", "password": "gov123"})
    assert gov_login.status_code == 200
    gov_token = gov_login.json()["access_token"]
    gov_headers = {"Authorization": f"Bearer {gov_token}"}

    # 2. Check Govt Dashboard KPIs
    res = client.get("/api/v1/dashboard/govt", headers=gov_headers)
    assert res.status_code == 200
    data = res.json()
    assert data["high_risk_clusters_count"] >= 1
    assert "Pune" in data["districts_breakdown"]

    # 3. Publish advisory
    adv_payload = {
        "title": "Outbreak Containment Order: Haveli Block",
        "message": "Immediate livestock quarantine within 5km radius of Uruli Kanchan.",
        "target": "BLOCK",
        "target_location": "Haveli",
        "language": "en",
    }
    adv_res = client.post("/api/v1/advisories", json=adv_payload, headers=gov_headers)
    assert adv_res.status_code == 201
    assert adv_res.json()["status"] == "PUBLISHED"
