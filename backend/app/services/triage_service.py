from typing import List, Optional, Dict
from app.models.triage import TriageRequest, TriageResponse

CRITICAL_SYMPTOMS = [
    "breathing problem",
    "breathing difficulty",
    "excessive salivation",
    "salivation",
    "weakness",
    "skin lesions",
    "lesions",
    "bleeding",
    "श्वास",
    "सांस",
    "लाळ",
    "लार",
    "अशक्त",
    "कमजोरी",
    "फोड",
    "छाले",
    "रक्त",
    "खून",
]

DISEASE_KNOWLEDGE_BASE = [
    {
        "disease": "Foot-and-Mouth Disease (FMD)",
        "symptoms": ["salivation", "excessive salivation", "lesions", "skin lesions", "fever", "difficulty walking", "लाळ", "लार", "फोड", "छाले", "ताप", "बुखार"],
        "species": ["cow", "cattle", "buffalo", "goat", "sheep"],
    },
    {
        "disease": "Hemorrhagic Septicemia (HS)",
        "symptoms": ["fever", "breathing problem", "breathing difficulty", "salivation", "weakness", "श्वास", "सांस", "ताप", "बुखार", "लाळ", "लार"],
        "species": ["cow", "cattle", "buffalo"],
    },
    {
        "disease": "Black Quarter (BQ)",
        "symptoms": ["fever", "difficulty walking", "weakness", "swelling", "ताप", "बुखार", "लंगडणे", "लंगड़ाना"],
        "species": ["cow", "cattle", "sheep"],
    },
    {
        "disease": "Anthrax",
        "symptoms": ["bleeding", "fever", "collapse", "weakness", "रक्त", "खून", "ताप", "बुखार"],
        "species": ["cow", "cattle", "sheep", "goat"],
    },
]

DISEASE_TRANSLATIONS: Dict[str, Dict[str, str]] = {
    "Foot-and-Mouth Disease (FMD)": {
        "mr": "लाळ्या खुरकूत (FMD)",
        "hi": "खुरपका-मुंहपका रोग (FMD)",
        "en": "Foot-and-Mouth Disease (FMD)",
    },
    "Hemorrhagic Septicemia (HS)": {
        "mr": "घटसर्प (HS)",
        "hi": "गलघोंटू (HS)",
        "en": "Hemorrhagic Septicemia (HS)",
    },
    "Black Quarter (BQ)": {
        "mr": "एकटांग्या / फऱ्या (Black Quarter)",
        "hi": "लंगड़ा बुखार (BQ)",
        "en": "Black Quarter (BQ)",
    },
    "Anthrax": {
        "mr": "ॲन्थ्रॅक्स (Anthrax)",
        "hi": "एंथ्रेक्स (Anthrax)",
        "en": "Anthrax",
    },
    "Acute Toxicosis": {
        "mr": "तीव्र विषबाधा",
        "hi": "तीव्र विषाक्तता",
        "en": "Acute Toxicosis",
    },
    "Acute Febrile Illness": {
        "mr": "तीव्र संसर्गजन्य ताप",
        "hi": "तीव्र संक्रामक ज्वर",
        "en": "Acute Febrile Illness",
    },
    "Infectious Bovine Rhinotracheitis": {
        "mr": "संसर्गजन्य श्वसन आजार (IBR)",
        "hi": "संक्रामक श्वसन रोग (IBR)",
        "en": "Infectious Bovine Rhinotracheitis",
    },
    "Mild Digestive Upset": {
        "mr": "किरकोळ पचन बिघाड",
        "hi": "हल्का पाचन विकार",
        "en": "Mild Digestive Upset",
    },
    "General Infection": {
        "mr": "सामान्य संसर्ग",
        "hi": "सामान्य संक्रमण",
        "en": "General Infection",
    },
}

LOCALIZED_CONTENT = {
    "mr": {
        "mortality": {
            "title": "गंभीर आरोग्य जोखीम — जनावराचा मृत्यू नोंदवला",
            "advice": "जनावराचा मृत्यू नोंदवला गेला आहे. कृपया बाधित भागातून इतर जनावरांना हलवणे त्वरित थांबवा.",
            "action": "उर्वरित जनावरांचे काटेकोर विलगीकरण करा. तपासणी व शवविच्छेदनासाठी स्थानिक पशुवैद्यकीय दवाखान्याशी संपर्क साधा.",
            "explanation": "कमी वेळेत जनावरांचा मृत्यू होणे हे संसर्गजन्य आजाराचे लक्षण असू शकते. तात्काळ पाळत व विलगीकरण आवश्यक आहे.",
        },
        "empty": {
            "title": "कमी आरोग्य जोखीम",
            "advice": "जनावराचे नियमित निरीक्षण सुरू ठेवा.",
            "action": "स्वच्छ पाणी आणि सकस आहार द्या. दिवसातून दोनदा निरीक्षण करा.",
            "explanation": "कोणतीही गंभीर लक्षणे आढळली नाहीत. सर्वसाधारण काळजी घेण्याचा सल्ला दिला आहे.",
        },
        "critical": {
            "title": "गंभीर आरोग्य जोखीम",
            "advice": "त्वरित पशुवैद्यकीय मदत आवश्यक आहे. बाधित जनावराला आत्ताच वेगळे करा.",
            "action": "बाधित जनावराला कळपापासून पूर्णपणे वेगळे ठेवा. तातडीने पशुवैद्यकीय सल्ला घेणे अनिवार्य आहे.",
            "explanation": "एकाधिक गंभीर प्रणालीगत लक्षणे आढळली आहेत, ज्यामुळे कळपात रोग पसरण्याचा मोठा धोका आहे.",
        },
        "high": {
            "title": "उच्च आरोग्य जोखीम",
            "advice": "कृपया बाधित जनावराला वेगळे करा आणि पशुवैद्यकीय तपासणीची विनंती करा.",
            "action": "रोग प्रसार रोखण्यासाठी या जनावराला वेगळे ठेवा. स्थानिक पशुवैद्यकाशी त्वरित संपर्क साधा.",
            "explanation": "गंभीर लक्षणांची उपस्थिती किंवा तीव्र क्लिनिकल लक्षणांचे संयोजन दिसून आले आहे.",
        },
        "medium": {
            "title": "मध्यम आरोग्य जोखीम",
            "advice": "जनावराचे बारकाईने निरीक्षण करा आणि लक्षणे कायम राहिल्यास पशुवैद्यकाशी संपर्क साधा.",
            "action": "दिवसातून दोनदा जनावराची स्थिती तपासा. पुरेसे पाणी, इलेक्ट्रोलाइट्स आणि निवारा द्या.",
            "explanation": "मध्यम स्वरूपाची लक्षणे आढळली आहेत. स्थिती आणखी बिघडू नये म्हणून काळजीपूर्वक देखरेख आवश्यक आहे.",
        },
        "low": {
            "title": "कमी आरोग्य जोखीम",
            "advice": "जनावराचे निरीक्षण सुरू ठेवा.",
            "action": "कोणतीही तातडीची गरज नाही. नियमित निरीक्षण चालू ठेवा.",
            "explanation": "कोणत्याही गंभीर लक्षणांशिवाय सौम्य स्थिती दिसून येत आहे.",
        },
    },
    "hi": {
        "mortality": {
            "title": "गंभीर स्वास्थ्य जोखिम — पशु मृत्यु दर्ज",
            "advice": "पशु मृत्यु की सूचना मिली है। कृपया प्रभावित क्षेत्र से पशुओं का आवागमन तुरंत रोकें।",
            "action": "शेष पशुओं का सख्त संगरोध (क्वारंटीन) करें। जांच के लिए तुरंत स्थानीय पशु चिकित्सालय से संपर्क करें।",
            "explanation": "पशु की अचानक मृत्यु गंभीर संक्रामक रोग का संकेत हो सकती है। त्वरित संगरोध अनिवार्य है।",
        },
        "empty": {
            "title": "कम स्वास्थ्य जोखिम",
            "advice": "पशु की सामान्य निगरानी जारी रखें।",
            "action": "स्वच्छ पानी और चारा उपलब्ध कराएं। दिन में दो बार पशु का निरीक्षण करें।",
            "explanation": "कोई चिंताजनक लक्षण दर्ज नहीं हुआ। सामान्य देखभाल की सलाह दी जाती है।",
        },
        "critical": {
            "title": "गंभीर स्वास्थ्य जोखिम",
            "advice": "तत्काल पशु चिकित्सक की आवश्यकता है। पशु को तुरंत अलग करें।",
            "action": "संक्रमण रोकने के लिए प्रभावित पशु को झुंड से अलग रखें। तत्काल डॉक्टर की सलाह लें।",
            "explanation": "एकाधिक गंभीर लक्षण पाए गए हैं, जिससे झुंड में तेजी से संक्रमण फैलने का खतरा है।",
        },
        "high": {
            "title": "उच्च स्वास्थ्य जोखिम",
            "advice": "कृपया प्रभावित पशु को अलग करें और पशु चिकित्सक से जांच का अनुरोध करें।",
            "action": "रोग प्रसार रोकने के लिए पशु को अलग करें। नजदीकी पशु चिकित्सक से तुरंत संपर्क करें।",
            "explanation": "गंभीर स्वास्थ्य संकेतकों की उपस्थिति के कारण चिकित्सकीय ध्यान आवश्यक है।",
        },
        "medium": {
            "title": "मध्यम स्वास्थ्य जोखिम",
            "advice": "पशु की बारीकी से निगरानी करें और लक्षण बने रहने पर पशु चिकित्सक से संपर्क करें।",
            "action": "दिन में दो बार पशु की जांच करें। पर्याप्त स्वच्छ पानी और सुपाच्य चारा दें।",
            "explanation": "मध्यम नैदानिक संकेत। स्थिति बिगड़ने से रोकने के लिए नियमित निगरानी आवश्यक है।",
        },
        "low": {
            "title": "कम स्वास्थ्य जोखिम",
            "advice": "पशु की सामान्य निगरानी जारी रखें।",
            "action": "किसी आपातकालीन कदम की आवश्यकता नहीं है। सामान्य देखभाल और निगरानी जारी रखें।",
            "explanation": "हल्के लक्षण बिना किसी प्रणालीगत परेशानी के संकेत दे रहे हैं।",
        },
    },
    "en": {
        "mortality": {
            "title": "CRITICAL HEALTH RISK — MORTALITY REPORTED",
            "advice": "Immediate livestock mortality reported. Prevent movement of animals from the farm perimeter.",
            "action": "Strict quarantine of remaining animals. Contact local veterinary hospital immediately for autopsy/investigation.",
            "explanation": "Animal death with rapid onset requires urgent disease containment and veterinary investigation.",
        },
        "empty": {
            "title": "LOW HEALTH RISK",
            "advice": "Continue regular herd monitoring.",
            "action": "Maintain clean water and feed. Observe animal twice daily.",
            "explanation": "No alarming symptoms reported. General observation advised.",
        },
        "critical": {
            "title": "CRITICAL HEALTH RISK",
            "advice": "Immediate veterinary attention is required. Isolate the animal now.",
            "action": "Keep affected animal completely separated from the herd. Urgent veterinary referral mandatory.",
            "explanation": "Multiple critical systemic symptoms observed with cluster risk potential.",
        },
        "high": {
            "title": "HIGH HEALTH RISK",
            "advice": "Please isolate the affected animal and request veterinarian review.",
            "action": "Separate this animal to prevent contagion. Contact field veterinarian immediately.",
            "explanation": "Presence of critical indicators or combination of severe clinical symptoms.",
        },
        "medium": {
            "title": "MEDIUM HEALTH RISK",
            "advice": "Monitor animal closely and prepare to contact a veterinarian if symptoms persist.",
            "action": "Check vitals twice daily. Provide adequate electrolytes, water, and shelter.",
            "explanation": "Moderate clinical signs. Monitoring advised to prevent deterioration.",
        },
        "low": {
            "title": "LOW HEALTH RISK",
            "advice": "Continue monitoring the animal.",
            "action": "No emergency action needed. Keep observing.",
            "explanation": "Mild isolated symptoms without signs of systemic distress.",
        },
    },
}


class TriageService:
    @staticmethod
    def _translate_disease(disease: str, lang: str) -> str:
        if disease in DISEASE_TRANSLATIONS:
            return DISEASE_TRANSLATIONS[disease].get(lang, disease)
        return disease

    @staticmethod
    def assess(req: TriageRequest) -> TriageResponse:
        lang = (req.language or "en").lower().strip()
        if lang not in ["mr", "hi", "en"]:
            lang = "en"

        content = LOCALIZED_CONTENT.get(lang, LOCALIZED_CONTENT["en"])

        symptoms_clean = [s.strip().lower() for s in req.symptoms]
        is_multiple = False
        if req.affected_count:
            c = str(req.affected_count)
            if any(x in c for x in ["2–5", "6–10", "more than 10", "2-5", "6-10", "10", "3", "२–५", "६–१०", "१०"]):
                is_multiple = True

        # 1. Immediate Critical check on mortality
        if req.is_mortality_related:
            c_data = content["mortality"]
            suspected = [
                TriageService._translate_disease("Anthrax", lang),
                TriageService._translate_disease("Hemorrhagic Septicemia (HS)", lang),
                TriageService._translate_disease("Acute Toxicosis", lang),
            ]
            return TriageResponse(
                risk_score=95,
                risk_level="CRITICAL",
                title=c_data["title"],
                advice=c_data["advice"],
                recommended_action=c_data["action"],
                suspected_conditions=suspected,
                requires_vet_review=True,
                requires_lab_test=True,
                explanation=c_data["explanation"],
            )

        if not symptoms_clean:
            c_data = content["empty"]
            return TriageResponse(
                risk_score=10,
                risk_level="LOW",
                title=c_data["title"],
                advice=c_data["advice"],
                recommended_action=c_data["action"],
                suspected_conditions=[],
                requires_vet_review=False,
                requires_lab_test=False,
                explanation=c_data["explanation"],
            )

        # Count critical symptom matches
        critical_count = 0
        for s in symptoms_clean:
            if any(cs in s or s in cs for cs in CRITICAL_SYMPTOMS):
                critical_count += 1

        # Match differential suspected diseases
        raw_suspected: List[str] = []
        species_lower = (req.species or "cow").lower()
        for item in DISEASE_KNOWLEDGE_BASE:
            if species_lower in item["species"] or any(s in species_lower for s in item["species"]):
                match_count = sum(1 for sym in item["symptoms"] if any(sym in s or s in sym for s in symptoms_clean))
                if match_count >= 2:
                    raw_suspected.append(item["disease"])

        # Determine Risk Level & Score
        if critical_count >= 2 or (critical_count >= 1 and is_multiple):
            score = 85 + min(15, critical_count * 5)
            level = "CRITICAL"
            c_data = content["critical"]
            req_vet = True
            req_lab = True
        elif critical_count >= 1 or len(symptoms_clean) >= 3 or is_multiple or (req.not_eating and req.not_drinking):
            score = 70 + min(15, len(symptoms_clean) * 3)
            level = "HIGH"
            c_data = content["high"]
            req_vet = True
            req_lab = True if critical_count >= 1 else False
        elif len(symptoms_clean) >= 2 or req.not_eating or req.not_drinking:
            score = 45
            level = "MEDIUM"
            c_data = content["medium"]
            req_vet = False
            req_lab = False
        else:
            score = 25
            level = "LOW"
            c_data = content["low"]
            req_vet = False
            req_lab = False

        if not raw_suspected:
            if level in ["HIGH", "CRITICAL"]:
                raw_suspected = ["Acute Febrile Illness", "Infectious Bovine Rhinotracheitis"]
            else:
                raw_suspected = ["Mild Digestive Upset", "General Infection"]

        suspected = [TriageService._translate_disease(d, lang) for d in raw_suspected]

        return TriageResponse(
            risk_score=score,
            risk_level=level,
            title=c_data["title"],
            advice=c_data["advice"],
            recommended_action=c_data["action"],
            suspected_conditions=suspected,
            requires_vet_review=req_vet,
            requires_lab_test=req_lab,
            explanation=c_data["explanation"],
        )
