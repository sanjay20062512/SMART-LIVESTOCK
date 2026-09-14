def test_health_check(client):
    res = client.get("/")
    assert res.status_code == 200
    assert res.json()["status"] == "online"


def test_triage_api_endpoint(client):
    payload = {
        "species": "Cow",
        "symptoms": ["Fever", "Excessive salivation", "Skin lesions"],
        "affected_count": "2–5",
    }
    res = client.post("/api/v1/triage", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["risk_level"] == "CRITICAL"
    assert data["requires_lab_test"] is True


def test_case_creation_and_lifecycle(client):
    # 1. Login as demo farmer
    login_res = client.post("/api/v1/auth/login", json={"phone_or_id": "9876543210", "password": "farmer123"})
    assert login_res.status_code == 200
    farmer_token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {farmer_token}"}

    # 2. Submit a new case
    case_payload = {
        "animal_tag": "C003",
        "species": "Cow",
        "breed": "Jersey",
        "age": "2–5 years",
        "gender": "Female",
        "symptoms": ["Fever", "Not eating", "Diarrhea"],
        "duration": "1–2 days",
        "affected_count": "2",
        "village": "Uruli Kanchan",
        "block": "Haveli",
        "district": "Pune",
    }
    case_res = client.post("/api/v1/cases", json=case_payload, headers=headers)
    assert case_res.status_code == 201
    created_case = case_res.json()
    case_id = created_case["id"]
    assert created_case["status"] == "SUBMITTED"
    assert created_case["risk_level"] in ["HIGH", "CRITICAL"]
    assert len(created_case["timeline"]) >= 2

    # 3. Login as demo veterinarian
    vet_login = client.post("/api/v1/auth/login", json={"phone_or_id": "VET001", "password": "vet123"})
    assert vet_login.status_code == 200
    vet_token = vet_login.json()["access_token"]
    vet_headers = {"Authorization": f"Bearer {vet_token}"}

    # 4. Vet claims case
    assign_res = client.post(
        f"/api/v1/cases/{case_id}/assign",
        json={"vet_id": "22222222-2222-2222-2222-222222222202", "vet_name": "Dr. Rajesh Kumar"},
        headers=vet_headers,
    )
    assert assign_res.status_code == 200
    assert assign_res.json()["status"] == "VET_ASSIGNED"

    # 5. Vet collects and refers sample
    sample_payload = {
        "case_id": case_id,
        "animal_tag": "C003",
        "sample_type": "Blood",
        "laboratory": "Maharashtra Animal Disease Investigation Laboratory, Pune",
        "reason": "Suspected viral serology confirmation",
    }
    sample_res = client.post("/api/v1/samples", json=sample_payload, headers=vet_headers)
    assert sample_res.status_code == 201
    sample_id = sample_res.json()["id"]

    # 6. Verify case status auto-advanced to LAB_REFERRED
    updated_case_res = client.get(f"/api/v1/cases/{case_id}", headers=vet_headers)
    assert updated_case_res.status_code == 200
    assert updated_case_res.json()["status"] == "LAB_REFERRED"

    # 7. Lab uploads test result
    result_payload = {
        "status": "RESULT_AVAILABLE",
        "result_summary": "Positive for Foot-and-Mouth Disease (FMD Type O)",
    }
    result_res = client.put(f"/api/v1/samples/{sample_id}/result", json=result_payload, headers=vet_headers)
    assert result_res.status_code == 200

    # 8. Verify final case status reflects result
    final_case = client.get(f"/api/v1/cases/{case_id}", headers=vet_headers).json()
    assert final_case["status"] == "RESULT_AVAILABLE"
