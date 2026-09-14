# Smart Livestock (Pashu Seva) — Technical Architecture

This document details the end-to-end technical architecture of the **Smart Livestock Animal Health Surveillance System**, covering the multi-role Flutter frontend, the FastAPI backend services, the AI/Rule-based Risk & Triage Engine, and the Supabase cloud persistence layer.

---

## 1. System Architecture Overview

```mermaid
graph TB
    subgraph ClientLayer ["1. CLIENT PRESENTATION LAYER (Flutter Multiplatform)"]
        direction TB
        subgraph RoleSelect ["Entry Point & Common Core"]
            RS["Role Selection Screen"]
            LS["Language Engine (En/Hi/Ta/Te)"]
            AS["FarmerDataService / Local Cache"]
        end

        subgraph FarmerMod ["Module 1: Farmer Portal"]
            F1["Animal Registry & Profile"]
            F2["Symptom Reporting Wizard"]
            F3["Offline Triage Engine (Client)"]
            F4["Case Tracking & Reports"]
            F5["Voice Notes & Media Upload"]
        end

        subgraph VetMod ["Module 2: Field Veterinary Portal"]
            V1["Pending Case Triage Queue"]
            V2["Visit Scheduling & Calendar"]
            V3["Sample Collection & Lab Ref"]
            V4["Diagnosis & Treatment Log"]
            V5["Regional Case Escalation"]
        end

        subgraph GovtMod ["Module 3: Government Surveillance Portal"]
            G1["Executive Surveillance Dashboard"]
            G2["Interactive District Outbreak Map"]
            G3["Cluster Detection & Trends"]
            G4["Vaccination Campaign Manager"]
            G5["Advisory Broadcast Engine"]
        end
    end

    subgraph Gateway ["2. API GATEWAY & ROUTING"]
        direction TB
        CORS["FastAPI CORS & Middleware"]
        AUTH["JWT / RBAC Security Layer"]
        ROUTER["API Router (/api/v1/*)"]
    end

    subgraph BackendLayer ["3. BUSINESS LOGIC & APPLICATION SERVICES (FastAPI)"]
        direction TB
        CS["Case Service\n(Lifecycle & State Machine)"]
        TS["Triage & Risk Engine\n(Severity & Differential Scoring)"]
        SS["Surveillance Service\n(Metrics & Cross-Module Sync)"]
        CL["Cluster Detection Service\n(Spatial & Herd Aggregation)"]
        ADV["Advisory & Campaign Service\n(Broadcast & Compliance)"]
        ANM["Animal Registry Service\n(Tagging & History)"]
    end

    subgraph DataLayer ["4. PERSISTENCE & CLOUD INFRASTRUCTURE (Supabase)"]
        direction TB
        subgraph PostgresDB ["PostgreSQL Relational DB"]
            T_CASES[("cases")]
            T_ANIMALS[("animals")]
            T_CLUSTERS[("outbreak_clusters")]
            T_ALERTS[("alerts")]
            T_ADVISORIES[("advisories")]
            T_CAMPAIGNS[("vaccination_campaigns")]
        end
        subgraph CloudStorage ["Object Storage"]
            S_MEDIA["Photo & Voice Note Evidence"]
        end
    end

    %% Connections
    FarmerMod --> CORS
    VetMod --> CORS
    GovtMod --> CORS
    CORS --> AUTH --> ROUTER

    ROUTER --> CS
    ROUTER --> TS
    ROUTER --> SS
    ROUTER --> CL
    ROUTER --> ADV
    ROUTER --> ANM

    CS <--> TS
    CS --> T_CASES
    CS --> T_ALERTS
    ANM --> T_ANIMALS
    CL --> T_CLUSTERS
    SS --> T_CASES
    SS --> T_CLUSTERS
    ADV --> T_ADVISORIES
    ADV --> T_CAMPAIGNS
    F5 --> S_MEDIA
```

---

## 2. Risk Engine & Case Lifecycle Data Flow

The diagram below details the continuous feedback loop between the **Farmer**, the **Risk Engine**, the **Field Veterinarian**, and the **Government Surveillance Authority**:

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farmer
    participant App as Mobile App (Flutter)
    participant API as FastAPI Backend
    participant Risk as Triage & Risk Engine
    participant DB as Supabase PostgreSQL
    actor Vet as Veterinarian
    actor Govt as Government Officer

    Farmer->>App: Submits symptoms, affected count, eating/drinking
    App->>App: Client-side instant offline triage assessment
    App->>API: POST /api/v1/cases (Health Report)
    API->>Risk: Assess symptoms & mortality indicators
    Risk->>Risk: Calculate risk score (0-100), differential diagnoses, lab flags
    Risk-->>API: Risk Assessment (CRITICAL / HIGH / MEDIUM / LOW)
    API->>DB: INSERT into cases & generate urgent alerts

    alt High / Critical Risk Detected
        API->>Vet: Real-time Alert & push to Triage Review Queue
        API->>Govt: High-Risk Alert & updates District Heatmap
    end

    Vet->>API: Claims case & schedules field visit
    API->>DB: UPDATE case status = VISIT_SCHEDULED
    DB-->>Farmer: Notification: "Vet visit scheduled"

    Vet->>API: Collects sample & records clinical diagnosis
    API->>DB: UPDATE status = LAB_REFERRED / DIAGNOSED
    
    alt Disease Outbreak Detected
        Vet->>API: Escalates case to Regional Alert
        API->>Govt: Cluster Outbreak Alert triggered
        Govt->>API: Launches Ring Vaccination Campaign & publishes Advisory
        API->>DB: Broadcast advisory to affected district
        DB-->>Farmer: District Advisory Banner & voice alert
    end
```

---

## 3. Core Component Descriptions

### A. Presentation Layer (Flutter Multiplatform)
- **Unified Engine**: Single codebase deployed to Android, iOS, Windows Desktop, and Web.
- **Role-Based Architecture**: Dynamically switches view shells (`FarmerShell`, `VetShell`, `GovtShell`) based on user credentials.
- **Multilingual Support**: Real-time localization (`LocalizationService`) supporting English, Hindi, Tamil, and Telugu.
- **Offline-First Resilience**: Local caching in `FarmerDataService` with graceful fallback when connectivity drops.

### B. Business Logic Layer (FastAPI)
- **TriageService**: Evaluates mortality, respiratory/salivation indicators, and herd transmission count to generate standardized risk scores.
- **CaseService**: Implements a deterministic state machine for clinical reports (`SUBMITTED` $\to$ `UNDER_REVIEW` $\to$ `VISIT_SCHEDULED` $\to$ `SAMPLE_COLLECTED` $\to$ `TREATMENT_STARTED` $\to$ `RESOLVED`).
- **SurveillanceService**: Aggregates spatial data to provide statistical summaries, cluster warnings, and district risk percentages.

### C. Data & Infrastructure Layer (Supabase)
- **Relational Integrity**: Foreign-key linked schemas tracking animals, case timelines, laboratory results, and district coordinates.
- **Row-Level Security (RLS)**: Enforces access boundaries between public farmers, certified veterinarians, and state administrators.
- **Binary Evidence Storage**: Buckets for farmer audio notes, symptom photos, and laboratory reports.
