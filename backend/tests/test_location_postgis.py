import pytest
from app.services.case_service import haversine_distance, CaseService


def test_haversine_distance():
    # Uruli Kanchan (18.4870, 74.1330) to Loni Kalbhor (18.4900, 74.0200) ~ 11.9 km
    dist = haversine_distance(18.4870, 74.1330, 18.4900, 74.0200)
    assert 11.0 <= dist <= 13.0

    # Same location -> 0 km
    assert haversine_distance(18.4870, 74.1330, 18.4870, 74.1330) == 0.0

    # Pune City (18.5204, 73.8567) to Uruli Kanchan ~ 29.5 km
    dist_pune = haversine_distance(18.5204, 73.8567, 18.4870, 74.1330)
    assert 27.0 <= dist_pune <= 32.0


def test_case_creation_with_gps_coordinates(client):
    # 1. Login as demo farmer
    login_res = client.post("/api/v1/auth/login", json={"phone_or_id": "9876543210", "password": "farmer123"})
    assert login_res.status_code == 200
    farmer_token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {farmer_token}"}

    # 2. Submit a case with GPS coordinates
    case_payload = {
        "animal_tag": "GPS-COW-01",
        "species": "Cow",
        "breed": "Gir",
        "age": "3 years",
        "gender": "Female",
        "symptoms": ["Fever", "Blisters on mouth"],
        "duration": "1 day",
        "affected_count": "1",
        "village": "Uruli Kanchan",
        "block": "Haveli",
        "district": "Pune",
        "latitude": 18.487123,
        "longitude": 74.133456,
    }
    res = client.post("/api/v1/cases", json=case_payload, headers=headers)
    assert res.status_code == 201
    data = res.json()
    assert data["latitude"] is not None
    assert round(data["latitude"], 4) == round(18.487123, 4)
    assert data["longitude"] is not None
    assert round(data["longitude"], 4) == round(74.133456, 4)


def test_nearby_cases_endpoint(client):
    # 1. Login as demo veterinarian
    vet_login = client.post("/api/v1/auth/login", json={"phone_or_id": "VET001", "password": "vet123"})
    assert vet_login.status_code == 200
    vet_token = vet_login.json()["access_token"]
    headers = {"Authorization": f"Bearer {vet_token}"}

    # 2. Query nearby cases within 15km of Uruli Kanchan
    res = client.get(
        "/api/v1/cases/nearby?latitude=18.4870&longitude=74.1330&radius_km=15.0",
        headers=headers,
    )
    assert res.status_code == 200
    cases = res.json()
    assert isinstance(cases, list)

    # Any returned case within 15km should have distance_km <= 15.0
    for c in cases:
        if c.get("distance_km") is not None:
            assert c["distance_km"] <= 15.0

    # 3. Query distant location with small radius (e.g. Nagpur coords 21.1458, 79.0882 with 1km radius)
    res_distant = client.get(
        "/api/v1/cases/nearby?latitude=21.1458&longitude=79.0882&radius_km=1.0",
        headers=headers,
    )
    assert res_distant.status_code == 200
    distant_cases = res_distant.json()
    assert len(distant_cases) == 0
