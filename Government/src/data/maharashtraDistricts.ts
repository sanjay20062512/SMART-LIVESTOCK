/**
 * Maharashtra District Animal Disease Surveillance Intelligence Data
 * 
 * NOTICE:
 * Last synchronized: Demo surveillance data
 * Demo surveillance data based on state animal husbandry epidemiological trends.
 * TODO: Connect to official live API endpoint (e.g. GET /api/v1/surveillance/maharashtra/districts)
 * when veterinary cloud backend is active.
 */

import type { DistrictRiskData, RiskLevel } from '@/types/disease';

export const MAHARASHTRA_DISTRICT_RISK_DATA: DistrictRiskData[] = [
  // ─── PUNE DIVISION ──────────────────────────────────────────
  {
    id: 'pune',
    districtName: 'Pune',
    marathiName: 'पुणे',
    division: 'Pune',
    riskPercentage: 78,
    riskLevel: 'Critical',
    primaryDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 128,
    mortalityReports: 7,
    vaccinationCoverage: 61.2,
    affectedVillages: 18,
    totalLivestock: 1845000,
    trend: '+16%',
    riskExplanation: 'Acute cluster of vesicular lesions and fever in crossbred dairy herds along Haveli and Shirur blocks with high peri-urban milk transit.',
    recommendedAction: 'Prioritize field investigation and emergency ring vaccination in 10km radius; deploy mobile containment units.',
    vaccinationGap: 'Critical gap: 23.8% deficit below mandatory threshold (85%)',
    whyAtRisk: [
      'Rapid spread of vesicular lesions across high-density dairy clusters',
      'Vaccination coverage at 61.2% versus 85% required threshold',
      'High livestock mobility across peri-urban milk sheds',
      'Delayed syndromic reporting in 7 peripheral villages'
    ],
    assignedTeams: [
      { id: 'tm-pun-1', leadVet: 'Dr. Deshmukh', mobileUnit: 'Mobile Vet Van 01', contact: '+91 94220 11022', status: 'Field Deployed' },
      { id: 'tm-pun-2', leadVet: 'Dr. Kadam', mobileUnit: 'Mobile Vet Van 03', contact: '+91 98224 88190', status: 'Field Deployed' },
      { id: 'tm-pun-3', leadVet: 'Dr. Ananya Joshi', mobileUnit: 'RRT Pune Core', contact: '+91 98812 34509', status: 'En Route' }
    ],
    recentReports: [
      { date: '2026-09-13', village: 'Uruli Kanchan', syndrome: 'Salivation & Foot Lesions', cattleAffected: 16 },
      { date: '2026-09-12', village: 'Wagholi', syndrome: 'High Fever & Blisters', cattleAffected: 11 },
      { date: '2026-09-10', village: 'Loni Kalbhor', syndrome: 'Sudden Milk Drop & Lameness', cattleAffected: 14 }
    ],
    coordinates: [18.5574, 74.0595]
  },
  {
    id: 'satara',
    districtName: 'Satara',
    marathiName: 'सातारा',
    division: 'Pune',
    riskPercentage: 28,
    riskLevel: 'Low',
    primaryDisease: 'Routine Surveillance',
    activeCases: 11,
    mortalityReports: 0,
    vaccinationCoverage: 88.4,
    affectedVillages: 4,
    totalLivestock: 1320000,
    trend: '-8%',
    riskExplanation: 'Stable syndromic baseline with high vaccination saturation in Krishna valley pastoral zones.',
    recommendedAction: 'Continue scheduled booster programs and maintain border check-post biosecurity.',
    vaccinationGap: 'Above target (+3.4% surplus over state benchmark)',
    whyAtRisk: [
      'High vaccination saturation (88.4%) achieved in Phase 1',
      'Prompt para-vet reporting and quarantine compliance',
      'Active cold-chain logistics in Wai and Karad blocks'
    ],
    assignedTeams: [
      { id: 'tm-sat-1', leadVet: 'Dr. Shinde', mobileUnit: 'Satara MVU-1', contact: '+91 94231 22910', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Shirwal', syndrome: 'Mild Nasal Discharge', cattleAffected: 3 }
    ],
    coordinates: [17.6676, 74.2176]
  },
  {
    id: 'solapur',
    districtName: 'Solapur',
    marathiName: 'सोलापूर',
    division: 'Pune',
    riskPercentage: 72,
    riskLevel: 'High',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 84,
    mortalityReports: 12,
    vaccinationCoverage: 58.1,
    affectedVillages: 14,
    totalLivestock: 1650000,
    trend: '+12%',
    riskExplanation: 'Pre-monsoon stagnation along Bhima river basin triggered respiratory distress and sudden deaths in buffalo herds.',
    recommendedAction: 'Deploy urgent prophylactic antibiotic therapy and accelerated HS-BQ combination drive.',
    vaccinationGap: 'Severe gap: 26.9% deficit below state target',
    whyAtRisk: [
      'Low lying marshy pastoral grounds facilitating bacterial persistence',
      'Suboptimal vaccination coverage before seasonal rains',
      'High inter-state livestock transit along Karnataka border'
    ],
    assignedTeams: [
      { id: 'tm-sol-1', leadVet: 'Dr. Patil', mobileUnit: 'Solapur MVU-02', contact: '+91 98230 45112', status: 'Field Deployed' },
      { id: 'tm-sol-2', leadVet: 'Dr. Gaikwad', mobileUnit: 'Pandharpur RRT', contact: '+91 94225 66710', status: 'En Route' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Mohol', syndrome: 'Submandibular Oedema & Dyspnoea', cattleAffected: 18 }
    ],
    coordinates: [17.7895, 75.3707]
  },
  {
    id: 'sangli',
    districtName: 'Sangli',
    marathiName: 'सांगली',
    division: 'Pune',
    riskPercentage: 42,
    riskLevel: 'Moderate',
    primaryDisease: 'Brucellosis',
    activeCases: 34,
    mortalityReports: 1,
    vaccinationCoverage: 74.5,
    affectedVillages: 8,
    totalLivestock: 1190000,
    trend: '+4%',
    riskExplanation: 'Sporadic late-term abortions detected across progressive dairy farms in Miraj and Walwa blocks.',
    recommendedAction: 'Execute calfhood B. abortus S19 vaccination screening and serological surveillance in milk collection centers.',
    vaccinationGap: 'Moderate gap: 10.5% below target',
    whyAtRisk: [
      'Intensive stall-fed conditions favoring bacterial transmission',
      'Unscreened animal purchases from neighboring cattle fairs'
    ],
    assignedTeams: [
      { id: 'tm-san-1', leadVet: 'Dr. Mane', mobileUnit: 'Miraj Mobile Unit', contact: '+91 97654 32101', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Ashta', syndrome: 'Bovine Third Trimester Abortion', cattleAffected: 4 }
    ],
    coordinates: [17.1466, 74.6981]
  },
  {
    id: 'kolhapur',
    districtName: 'Kolhapur',
    marathiName: 'कोल्हापूर',
    division: 'Pune',
    riskPercentage: 24,
    riskLevel: 'Low',
    primaryDisease: 'Routine Surveillance',
    activeCases: 8,
    mortalityReports: 0,
    vaccinationCoverage: 89.2,
    affectedVillages: 3,
    totalLivestock: 1420000,
    trend: '-5%',
    riskExplanation: 'Strong dairy cooperative network maintains near universal immunisation and robust cold storage adherence.',
    recommendedAction: 'Maintain digital ear-tag tracking and bulk milk testing protocols.',
    vaccinationGap: 'Target achieved (+4.2% surplus)',
    whyAtRisk: [
      'Model veterinary infrastructure through Gokul milk cooperative',
      'High farmer awareness and biosecurity protocols'
    ],
    assignedTeams: [
      { id: 'tm-kol-1', leadVet: 'Dr. Bhosale', mobileUnit: 'Karveer Vet Unit', contact: '+91 98220 99881', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Hupari', syndrome: 'Mild Bloat', cattleAffected: 2 }
    ],
    coordinates: [16.475, 74.1389]
  },

  // ─── NASHIK DIVISION ────────────────────────────────────────
  {
    id: 'nashik',
    districtName: 'Nashik',
    marathiName: 'नाशिक',
    division: 'Nashik',
    riskPercentage: 68,
    riskLevel: 'High',
    primaryDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 96,
    mortalityReports: 5,
    vaccinationCoverage: 68.4,
    affectedVillages: 15,
    totalLivestock: 1720000,
    trend: '+14%',
    riskExplanation: 'Nodular cutaneous eruptions in indigenous cattle clusters across Niphad and Malegaon tehsils following vector surges.',
    recommendedAction: 'Issue advisory on vector control (mosquitoes/ticks) and conduct targeted goat pox booster drives.',
    vaccinationGap: 'High gap: 16.6% below target',
    whyAtRisk: [
      'High fly and tick populations around onion crop farmyards',
      'Dense village livestock congregations during weekly market days'
    ],
    assignedTeams: [
      { id: 'tm-nsk-1', leadVet: 'Dr. Wagh', mobileUnit: 'Nashik RRT-01', contact: '+91 94222 34189', status: 'Field Deployed' },
      { id: 'tm-nsk-2', leadVet: 'Dr. Sonawane', mobileUnit: 'Malegaon Vet Van', contact: '+91 98223 77412', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Lasalgaon', syndrome: 'Cutaneous Nodules & High Pyrexia', cattleAffected: 15 }
    ],
    coordinates: [20.2815, 74.0761]
  },
  {
    id: 'ahmednagar',
    districtName: 'Ahmednagar',
    marathiName: 'अहिल्यानगर',
    division: 'Nashik',
    riskPercentage: 82,
    riskLevel: 'Critical',
    primaryDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 142,
    mortalityReports: 9,
    vaccinationCoverage: 59.5,
    affectedVillages: 21,
    totalLivestock: 2450000,
    trend: '+22%',
    riskExplanation: 'Severe outbreak spread across Rahata, Shrirampur, and Sangamner milk belts with significant dairy yield reduction.',
    recommendedAction: 'Immediate containment cordon; restrict interstate animal transport and initiate ring vaccination campaign.',
    vaccinationGap: 'Critical gap: 25.5% below benchmark',
    whyAtRisk: [
      'Largest bovine population in Maharashtra with intensive crossbreeding',
      'Unvaccinated nomadic pastoral herds traversing sugarcane corridors',
      'High environmental persistence during humid cloudy spells'
    ],
    assignedTeams: [
      { id: 'tm-ahd-1', leadVet: 'Dr. Thorat', mobileUnit: 'Sangamner RRT', contact: '+91 98228 11440', status: 'Field Deployed' },
      { id: 'tm-ahd-2', leadVet: 'Dr. Tambe', mobileUnit: 'Rahata MVU-1', contact: '+91 94220 55190', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-13', village: 'Loni', syndrome: 'Severe Drooling & Interdigital Canker', cattleAffected: 24 }
    ],
    coordinates: [19.1908, 74.7288]
  },
  {
    id: 'jalgaon',
    districtName: 'Jalgaon',
    marathiName: 'जळगाव',
    division: 'Nashik',
    riskPercentage: 54,
    riskLevel: 'Moderate',
    primaryDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 48,
    mortalityReports: 2,
    vaccinationCoverage: 71.0,
    affectedVillages: 10,
    totalLivestock: 1350000,
    trend: '+3%',
    riskExplanation: 'Subacute cutaneous skin lesions reported in Jamner and Raver banana belt cattle herds.',
    recommendedAction: 'Intensify fogging operations in animal sheds and replenish Goat Pox vaccine reserves.',
    vaccinationGap: 'Moderate gap: 14.0% below target',
    whyAtRisk: [
      'High humidity along Tapi river basin fostering arthropod vectors',
      'Border trade flow with Madhya Pradesh'
    ],
    assignedTeams: [
      { id: 'tm-jlg-1', leadVet: 'Dr. Chaudhari', mobileUnit: 'Jalgaon MVU', contact: '+91 94227 88123', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Savda', syndrome: 'Fever & Skin Nodules', cattleAffected: 8 }
    ],
    coordinates: [20.852, 75.4579]
  },
  {
    id: 'dhule',
    districtName: 'Dhule',
    marathiName: 'धुळे',
    division: 'Nashik',
    riskPercentage: 48,
    riskLevel: 'Moderate',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 32,
    mortalityReports: 3,
    vaccinationCoverage: 73.2,
    affectedVillages: 7,
    totalLivestock: 920000,
    trend: '-2%',
    riskExplanation: 'Scattered syndromic alerts in Shirpur and Sindkheda talukas; containment measures holding.',
    recommendedAction: 'Complete booster coverage for draught animals before sowing operations.',
    vaccinationGap: 'Moderate gap: 11.8% below target',
    whyAtRisk: [
      'Intermittent waterlogging in low-lying pastures',
      'Relatively slow remote village reporting in Satpuda foothills'
    ],
    assignedTeams: [
      { id: 'tm-dhl-1', leadVet: 'Dr. Rajput', mobileUnit: 'Dhule MVU', contact: '+91 98231 66524', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Songir', syndrome: 'Fever & Respiratory Rattles', cattleAffected: 5 }
    ],
    coordinates: [21.0654, 74.561]
  },
  {
    id: 'nandurbar',
    districtName: 'Nandurbar',
    marathiName: 'नंदुरबार',
    division: 'Nashik',
    riskPercentage: 62,
    riskLevel: 'High',
    primaryDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 76,
    mortalityReports: 8,
    vaccinationCoverage: 52.8,
    affectedVillages: 16,
    totalLivestock: 840000,
    trend: '+11%',
    riskExplanation: 'PPR outbreak impacting tribal backyard goat rearing communities in Dhadgaon and Akkalkuwa hilly ranges.',
    recommendedAction: 'Deploy mobile veterinary vans equipped with cold storage for mass goat immunisation in tribal hamlets.',
    vaccinationGap: 'Severe gap: 32.2% below target in remote blocks',
    whyAtRisk: [
      'Challenging terrain with scattered tribal hamlets limiting routine clinic access',
      'Extensive grazing in forest reserves without quarantine facilities'
    ],
    assignedTeams: [
      { id: 'tm-ndb-1', leadVet: 'Dr. Padvi', mobileUnit: 'Akkalkuwa Tribal Unit', contact: '+91 94221 44589', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Molgi', syndrome: 'Caprine Stomatitis & Diarrhoea', cattleAffected: 21 }
    ],
    coordinates: [21.462, 74.1244]
  },

  // ─── CHHATRAPATI SAMBHAJINAGAR (AURANGABAD) DIVISION ────────
  {
    id: 'aurangabad',
    districtName: 'Chhatrapati Sambhajinagar',
    marathiName: 'छत्रपती संभाजीनगर',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 74,
    riskLevel: 'High',
    primaryDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 110,
    mortalityReports: 6,
    vaccinationCoverage: 62.4,
    affectedVillages: 17,
    totalLivestock: 1390000,
    trend: '+15%',
    riskExplanation: 'Active viral transmission detected across Paithan and Gangapur tehsils adjacent to livestock gathering venues.',
    recommendedAction: 'Sanitize cattle markets, pause inter-block livestock exhibitions, and mandate ring vaccination.',
    vaccinationGap: 'High gap: 22.6% below target',
    whyAtRisk: [
      'High footfall at regional weekly cattle bazaars',
      'Dense cattle corridor along Godavari backwaters'
    ],
    assignedTeams: [
      { id: 'tm-aur-1', leadVet: 'Dr. Khan', mobileUnit: 'Sambhajinagar RRT', contact: '+91 94220 77312', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Bidkin', syndrome: 'Oral Vesicles & Lameness', cattleAffected: 19 }
    ],
    coordinates: [20.1365, 75.3849]
  },
  {
    id: 'jalna',
    districtName: 'Jalna',
    marathiName: 'जालना',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 58,
    riskLevel: 'High',
    primaryDisease: 'Black Quarter (BQ)',
    activeCases: 42,
    mortalityReports: 4,
    vaccinationCoverage: 66.8,
    affectedVillages: 9,
    totalLivestock: 1040000,
    trend: '+6%',
    riskExplanation: 'Clostridial spore germination in alkaline black soil following dry spell intermittent showers in Ambad tehsil.',
    recommendedAction: 'Immediate subcutaneous BQ vaccination of unimmunised young stock (6 months to 2 years).',
    vaccinationGap: 'Moderate gap: 18.2% below target',
    whyAtRisk: [
      'Endemic soil contamination in historical pastures',
      'Delayed vaccination of adolescent calves'
    ],
    assignedTeams: [
      { id: 'tm-jln-1', leadVet: 'Dr. Kharat', mobileUnit: 'Ambad Vet Van', contact: '+91 98224 55901', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Ranjani', syndrome: 'Crepitant Swelling on Thigh & High Fever', cattleAffected: 7 }
    ],
    coordinates: [19.9232, 76.0157]
  },
  {
    id: 'parbhani',
    districtName: 'Parbhani',
    marathiName: 'परभणी',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 52,
    riskLevel: 'Moderate',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 38,
    mortalityReports: 3,
    vaccinationCoverage: 70.1,
    affectedVillages: 8,
    totalLivestock: 890000,
    trend: '+2%',
    riskExplanation: 'Seasonal respiratory syndromes recorded in water-retentive black cotton soil pockets along Purna river.',
    recommendedAction: 'Coordinate with village gram panchayats to establish prophylactic treatment camps.',
    vaccinationGap: 'Moderate gap: 14.9% below target',
    whyAtRisk: [
      'Humid conditions near river flood plains',
      'Overworked draught bullocks with reduced immunological resilience'
    ],
    assignedTeams: [
      { id: 'tm-pbn-1', leadVet: 'Dr. Jadhav', mobileUnit: 'Parbhani MVU', contact: '+91 94229 33810', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Jintur', syndrome: 'Salivation & Throat Oedema', cattleAffected: 6 }
    ],
    coordinates: [19.3136, 76.6838]
  },
  {
    id: 'hingoli',
    districtName: 'Hingoli',
    marathiName: 'हिंगोली',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 38,
    riskLevel: 'Moderate',
    primaryDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 22,
    mortalityReports: 1,
    vaccinationCoverage: 78.4,
    affectedVillages: 5,
    totalLivestock: 680000,
    trend: '-3%',
    riskExplanation: 'Case counts declining after ring vaccination in Sengaon; surveillance monitoring active.',
    recommendedAction: 'Monitor recovery rates and support livestock owners with antiseptic wound sprays.',
    vaccinationGap: 'Low gap: 6.6% below target',
    whyAtRisk: [
      'Proximity to forested hill tracts with vector reservoir hosts'
    ],
    assignedTeams: [
      { id: 'tm-hng-1', leadVet: 'Dr. Kale', mobileUnit: 'Hingoli MVU', contact: '+91 98226 77123', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Aundha', syndrome: 'Mild Skin Nodules', cattleAffected: 3 }
    ],
    coordinates: [19.6048, 77.0424]
  },
  {
    id: 'nanded',
    districtName: 'Nanded',
    marathiName: 'नांदेड',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 76,
    riskLevel: 'Critical',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 118,
    mortalityReports: 14,
    vaccinationCoverage: 57.3,
    affectedVillages: 19,
    totalLivestock: 1280000,
    trend: '+19%',
    riskExplanation: 'Severe mortality spike along Godavari wetlands and interstate border with Telangana.',
    recommendedAction: 'Declare emergency containment protocol; deploy state veterinary rapid response teams immediately.',
    vaccinationGap: 'Critical gap: 27.7% below state benchmark',
    whyAtRisk: [
      'Heavy cross-border livestock trading at Dharmabad without health certification',
      'Low pre-monsoon vaccination saturation in pastoral riverine villages'
    ],
    assignedTeams: [
      { id: 'tm-ndd-1', leadVet: 'Dr. Rathod', mobileUnit: 'Nanded Core MVU', contact: '+91 94223 99014', status: 'Field Deployed' },
      { id: 'tm-ndd-2', leadVet: 'Dr. Syed', mobileUnit: 'Biloli RRT', contact: '+91 98235 44109', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-13', village: 'Mukhed', syndrome: 'Sudden High Fever & Rapid Death', cattleAffected: 22 }
    ],
    coordinates: [19.1493, 77.6869]
  },
  {
    id: 'beed',
    districtName: 'Beed',
    marathiName: 'बीड',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 66,
    riskLevel: 'High',
    primaryDisease: 'Anthrax (Sporadic)',
    activeCases: 46,
    mortalityReports: 6,
    vaccinationCoverage: 64.1,
    affectedVillages: 11,
    totalLivestock: 1220000,
    trend: '+8%',
    riskExplanation: 'Peracute deaths with incomplete rigor mortis reported in grazing grounds of Ashti tehsil.',
    recommendedAction: 'Enforce carcass deep-burial with quicklime; initiate ring anthrax spore vaccination and ban uninspected meat processing.',
    vaccinationGap: 'High gap: 20.9% below target',
    whyAtRisk: [
      'Soil disruption during excavation uncovering dormant spore beds',
      'High sheep and goat population grazing close to soil surface'
    ],
    assignedTeams: [
      { id: 'tm-bed-1', leadVet: 'Dr. Munde', mobileUnit: 'Beed Special Vet Unit', contact: '+91 94221 88402', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Ashti', syndrome: 'Bloody Natural Orifices Discharge', cattleAffected: 8 }
    ],
    coordinates: [18.9634, 75.7241]
  },
  {
    id: 'latur',
    districtName: 'Latur',
    marathiName: 'लातूर',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 45,
    riskLevel: 'Moderate',
    primaryDisease: 'Brucellosis',
    activeCases: 29,
    mortalityReports: 1,
    vaccinationCoverage: 76.2,
    affectedVillages: 7,
    totalLivestock: 980000,
    trend: '+1%',
    riskExplanation: 'Screening in organized dairy units revealed low level seropositivity in Deoni cattle breeding belts.',
    recommendedAction: 'Implement herd segregation of seropositive cows and pasteurization checks in milk dairies.',
    vaccinationGap: 'Low gap: 8.8% below target',
    whyAtRisk: [
      'Concentrated Deoni breed herds with shared community bulls'
    ],
    assignedTeams: [
      { id: 'tm-ltr-1', leadVet: 'Dr. Patil', mobileUnit: 'Latur Dairy Vet Unit', contact: '+91 98227 11094', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Udgir', syndrome: 'Reproductive Pathology', cattleAffected: 4 }
    ],
    coordinates: [18.3667, 76.7775]
  },
  {
    id: 'dharashiv',
    districtName: 'Dharashiv',
    marathiName: 'धाराशिव',
    division: 'Chhatrapati Sambhajinagar',
    riskPercentage: 50,
    riskLevel: 'Moderate',
    primaryDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 36,
    mortalityReports: 2,
    vaccinationCoverage: 72.8,
    affectedVillages: 8,
    totalLivestock: 870000,
    trend: '+4%',
    riskExplanation: 'Mild vesicular symptoms observed in Tuljapur pilgrim trail cattle stations.',
    recommendedAction: 'Conduct disinfection of cattle resting shelters along pilgrimage highways.',
    vaccinationGap: 'Moderate gap: 12.2% below target',
    whyAtRisk: [
      'Transient transit of bullock carts during festive seasonal migrations'
    ],
    assignedTeams: [
      { id: 'tm-dhr-1', leadVet: 'Dr. Bhosale', mobileUnit: 'Tuljapur Vet Unit', contact: '+91 94228 33201', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Tuljapur', syndrome: 'Salivation & Foot Tenderness', cattleAffected: 7 }
    ],
    coordinates: [18.169, 76.0259]
  },

  // ─── AMRAVATI DIVISION ──────────────────────────────────────
  {
    id: 'amravati',
    districtName: 'Amravati',
    marathiName: 'अमरावती',
    division: 'Amravati',
    riskPercentage: 64,
    riskLevel: 'High',
    primaryDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 78,
    mortalityReports: 4,
    vaccinationCoverage: 67.5,
    affectedVillages: 14,
    totalLivestock: 1150000,
    trend: '+9%',
    riskExplanation: 'Cluster of vector-borne cutaneous lesions expanding in Achalpur and Melghat forest fringe zones.',
    recommendedAction: 'Intensify insecticide dipping and distribute fly-repellent ointments to gaushalas.',
    vaccinationGap: 'High gap: 17.5% below target',
    whyAtRisk: [
      'High vector density near Melghat Tiger Reserve buffer waterbodies',
      'Nomadic pastoralist movements with non-immunized stock'
    ],
    assignedTeams: [
      { id: 'tm-amr-1', leadVet: 'Dr. Gawande', mobileUnit: 'Amravati RRT', contact: '+91 94221 66782', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Achalpur', syndrome: 'Subcutaneous Nodules & Lameness', cattleAffected: 12 }
    ],
    coordinates: [21.167, 77.6691]
  },
  {
    id: 'akola',
    districtName: 'Akola',
    marathiName: 'अकोला',
    division: 'Amravati',
    riskPercentage: 46,
    riskLevel: 'Moderate',
    primaryDisease: 'Black Quarter (BQ)',
    activeCases: 26,
    mortalityReports: 2,
    vaccinationCoverage: 75.9,
    affectedVillages: 6,
    totalLivestock: 680000,
    trend: '+1%',
    riskExplanation: 'Isolated cases in Telhara; livestock vaccination progress remains above regional average.',
    recommendedAction: 'Ensure second booster dose for calves under 1 year.',
    vaccinationGap: 'Low gap: 9.1% below target',
    whyAtRisk: [
      'Sporadic spore concentrations in flood-prone river beds'
    ],
    assignedTeams: [
      { id: 'tm-akl-1', leadVet: 'Dr. Deshmukh', mobileUnit: 'Akola MVU', contact: '+91 98222 55431', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Telhara', syndrome: 'Muscle Crepitus & Fever', cattleAffected: 4 }
    ],
    coordinates: [20.7533, 77.0686]
  },
  {
    id: 'washim',
    districtName: 'Washim',
    marathiName: 'वाशिम',
    division: 'Amravati',
    riskPercentage: 35,
    riskLevel: 'Moderate',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 18,
    mortalityReports: 1,
    vaccinationCoverage: 81.3,
    affectedVillages: 5,
    totalLivestock: 590000,
    trend: '-4%',
    riskExplanation: 'Surveillance indicators stable with timely immunisation of Gaolao breed cattle.',
    recommendedAction: 'Continue syndromic surveillance in Risod cattle market.',
    vaccinationGap: 'Low gap: 3.7% below benchmark',
    whyAtRisk: [
      'Seasonal monsoon water pooling in shallow irrigation ditches'
    ],
    assignedTeams: [
      { id: 'tm-wsh-1', leadVet: 'Dr. Thakare', mobileUnit: 'Washim MVU', contact: '+91 94228 11902', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Risod', syndrome: 'Mild Respiratory Wheezing', cattleAffected: 3 }
    ],
    coordinates: [20.2641, 77.2311]
  },
  {
    id: 'buldhana',
    districtName: 'Buldhana',
    marathiName: 'बुलढाणा',
    division: 'Amravati',
    riskPercentage: 55,
    riskLevel: 'Moderate',
    primaryDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 44,
    mortalityReports: 2,
    vaccinationCoverage: 71.8,
    affectedVillages: 9,
    totalLivestock: 990000,
    trend: '+5%',
    riskExplanation: 'Mild surge in Khamgaon and Shegaon tehsils; vector population active around cotton fields.',
    recommendedAction: 'Organize village bio-security workshops and supply neem-based fly repellents.',
    vaccinationGap: 'Moderate gap: 13.2% below target',
    whyAtRisk: [
      'Substantial cattle movement along pilgrimage circuit and weekly markets'
    ],
    assignedTeams: [
      { id: 'tm-bld-1', leadVet: 'Dr. Sanap', mobileUnit: 'Khamgaon Vet Van', contact: '+91 98224 88319', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Shegaon', syndrome: 'Pyrexia & Nodular Eruptions', cattleAffected: 9 }
    ],
    coordinates: [20.5175, 76.411]
  },
  {
    id: 'yavatmal',
    districtName: 'Yavatmal',
    marathiName: 'यवतमाळ',
    division: 'Amravati',
    riskPercentage: 60,
    riskLevel: 'High',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 68,
    mortalityReports: 5,
    vaccinationCoverage: 65.2,
    affectedVillages: 13,
    totalLivestock: 1310000,
    trend: '+7%',
    riskExplanation: 'High incidence in Penganga river basin affecting working bullocks during intense agricultural work cycle.',
    recommendedAction: 'Conduct mobile veterinary clinics across vulnerable tribal tehsils (Umarkhed, Pusad).',
    vaccinationGap: 'High gap: 19.8% below state target',
    whyAtRisk: [
      'Stress-induced immunosuppression in draught animals',
      'Remoteness of interior tribal habitations'
    ],
    assignedTeams: [
      { id: 'tm-yvt-1', leadVet: 'Dr. Ade', mobileUnit: 'Pusad Mobile Unit', contact: '+91 94220 33490', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Umarkhed', syndrome: 'Rapid Respiratory Distress', cattleAffected: 11 }
    ],
    coordinates: [20.0276, 78.066]
  },

  // ─── NAGPUR DIVISION ────────────────────────────────────────
  {
    id: 'nagpur',
    districtName: 'Nagpur',
    marathiName: 'नागपूर',
    division: 'Nagpur',
    riskPercentage: 40,
    riskLevel: 'Moderate',
    primaryDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 32,
    mortalityReports: 1,
    vaccinationCoverage: 79.2,
    affectedVillages: 6,
    totalLivestock: 1120000,
    trend: '-2%',
    riskExplanation: 'Contained foci in Katol citrus orchards; overall veterinary network responding effectively.',
    recommendedAction: 'Maintain buffer zone vaccination around central livestock markets.',
    vaccinationGap: 'Low gap: 5.8% below target',
    whyAtRisk: [
      'Major freight hub with extensive interstate road transport crossings'
    ],
    assignedTeams: [
      { id: 'tm-ngp-1', leadVet: 'Dr. Meshram', mobileUnit: 'Nagpur RRT', contact: '+91 94221 22890', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Katol', syndrome: 'Mouth Ulcers & Mild Lameness', cattleAffected: 5 }
    ],
    coordinates: [21.1964, 79.0447]
  },
  {
    id: 'wardha',
    districtName: 'Wardha',
    marathiName: 'वर्धा',
    division: 'Nagpur',
    riskPercentage: 26,
    riskLevel: 'Low',
    primaryDisease: 'Routine Surveillance',
    activeCases: 9,
    mortalityReports: 0,
    vaccinationCoverage: 86.8,
    affectedVillages: 3,
    totalLivestock: 610000,
    trend: '-6%',
    riskExplanation: 'Strong baseline immunity in Gaolao indigenous breeding tract with proactive community monitoring.',
    recommendedAction: 'Continue genetic conservation and purebred herd disease screening.',
    vaccinationGap: 'Benchmark met (+1.8% above target)',
    whyAtRisk: [
      'Indigenous breed resilience and active community gaushalas'
    ],
    assignedTeams: [
      { id: 'tm-wrd-1', leadVet: 'Dr. Ghotekar', mobileUnit: 'Wardha MVU', contact: '+91 98223 99120', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Sewagram', syndrome: 'Mild Digestive Disorder', cattleAffected: 2 }
    ],
    coordinates: [20.803, 78.5842]
  },
  {
    id: 'bhandara',
    districtName: 'Bhandara',
    marathiName: 'भंडारा',
    division: 'Nagpur',
    riskPercentage: 70,
    riskLevel: 'High',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 82,
    mortalityReports: 8,
    vaccinationCoverage: 62.1,
    affectedVillages: 14,
    totalLivestock: 640000,
    trend: '+14%',
    riskExplanation: 'Extensive lake and paddy wetlands fostering pasteurella persistence in draught buffaloes.',
    recommendedAction: 'Execute emergency vaccination in waterlogged paddy farming belts.',
    vaccinationGap: 'High gap: 22.9% below target',
    whyAtRisk: [
      'Hundreds of lakes and flooded rice fields ideal for anaerobic bacterial propagation',
      'Water-wallowing buffalo herds frequently exchanging pathogens'
    ],
    assignedTeams: [
      { id: 'tm-bhn-1', leadVet: 'Dr. Bawankule', mobileUnit: 'Bhandara Lake Vet Van', contact: '+91 94228 44512', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Tumsar', syndrome: 'Swollen Throat & Laboured Breathing', cattleAffected: 16 }
    ],
    coordinates: [21.0561, 79.7916]
  },
  {
    id: 'gondia',
    districtName: 'Gondia',
    marathiName: 'गोंदिया',
    division: 'Nagpur',
    riskPercentage: 75,
    riskLevel: 'High',
    primaryDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 89,
    mortalityReports: 10,
    vaccinationCoverage: 58.7,
    affectedVillages: 15,
    totalLivestock: 580000,
    trend: '+16%',
    riskExplanation: 'Paddy wetland exposure compounded by interstate forest border movements from Chhattisgarh.',
    recommendedAction: 'Mobilize boat-accessible mobile vet units to isolated island hamlets and accelerate HS vaccination.',
    vaccinationGap: 'High gap: 26.3% below target',
    whyAtRisk: [
      'Flooded paddy cultivation and heavy rainfall pockets',
      'Cross-border cattle grazing in interstate forest ranges'
    ],
    assignedTeams: [
      { id: 'tm-gnd-1', leadVet: 'Dr. Rahangdale', mobileUnit: 'Gondia Wetland MVU', contact: '+91 98226 11782', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-13', village: 'Tirora', syndrome: 'Severe Submaxillary Oedema', cattleAffected: 17 }
    ],
    coordinates: [21.0885, 80.1574]
  },
  {
    id: 'chandrapur',
    districtName: 'Chandrapur',
    marathiName: 'चंद्रपूर',
    division: 'Nagpur',
    riskPercentage: 56,
    riskLevel: 'High',
    primaryDisease: 'Black Quarter (BQ)',
    activeCases: 40,
    mortalityReports: 3,
    vaccinationCoverage: 69.4,
    affectedVillages: 9,
    totalLivestock: 820000,
    trend: '+5%',
    riskExplanation: 'Pasture contamination around coal mining drainage corridors and forest buffer zones in Bhadravati.',
    recommendedAction: 'Screen pastoral corridors for environmental toxins and complete clostridial immunisation.',
    vaccinationGap: 'Moderate gap: 15.6% below target',
    whyAtRisk: [
      'Pasture encroachment near mining run-offs',
      'Wild ruminant and domestic cattle interface around Tadoba buffer'
    ],
    assignedTeams: [
      { id: 'tm-chd-1', leadVet: 'Dr. Roy', mobileUnit: 'Chandrapur MVU', contact: '+91 94221 77319', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Bhadravati', syndrome: 'Lameness with Subcutaneous Gas', cattleAffected: 6 }
    ],
    coordinates: [20.0962, 79.3113]
  },
  {
    id: 'gadchiroli',
    districtName: 'Gadchiroli',
    marathiName: 'गडचिरोली',
    division: 'Nagpur',
    riskPercentage: 80,
    riskLevel: 'Critical',
    primaryDisease: 'Anthrax & HS Co-infection Risk',
    activeCases: 94,
    mortalityReports: 15,
    vaccinationCoverage: 48.9,
    affectedVillages: 23,
    totalLivestock: 690000,
    trend: '+24%',
    riskExplanation: 'Extensive forest tracts with limited road connectivity resulting in low immunisation coverage and uncontained mortalities.',
    recommendedAction: 'Dispatch air-assisted vaccine cold-chain supplies and activate joint tribal health-veterinary emergency camps.',
    vaccinationGap: 'Critical gap: 36.1% below benchmark',
    whyAtRisk: [
      'Dense forest landscape with inaccessible interior villages during monsoon swells',
      'Co-grazing with wild ungulates without veterinary barriers',
      'Delay in syndromic reporting due to telecommunication deficits'
    ],
    assignedTeams: [
      { id: 'tm-gad-1', leadVet: 'Dr. Madavi', mobileUnit: 'Aheri Tribal MVU', contact: '+91 94220 88910', status: 'Field Deployed' },
      { id: 'tm-gad-2', leadVet: 'Dr. Usendi', mobileUnit: 'Gadchiroli Forest RRT', contact: '+91 98225 11209', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-13', village: 'Aheri', syndrome: 'Rapid Mortality & Blood Oozing', cattleAffected: 19 },
      { date: '2026-09-11', village: 'Etapalli', syndrome: 'Respiratory Choking & High Fever', cattleAffected: 14 }
    ],
    coordinates: [19.8282, 80.3223]
  },

  // ─── KONKAN DIVISION ────────────────────────────────────────
  {
    id: 'thane',
    districtName: 'Thane',
    marathiName: 'ठाणे',
    division: 'Konkan',
    riskPercentage: 36,
    riskLevel: 'Moderate',
    primaryDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 19,
    mortalityReports: 1,
    vaccinationCoverage: 79.4,
    affectedVillages: 5,
    totalLivestock: 450000,
    trend: '-1%',
    riskExplanation: 'Stable situation in peri-urban dairy sheds with good road connectivity and veterinary clinic density.',
    recommendedAction: 'Audit biosecurity in commercial buffalo milk dairies.',
    vaccinationGap: 'Low gap: 5.6% below target',
    whyAtRisk: [
      'High-density commercial dairy sheds with heavy milk van transit'
    ],
    assignedTeams: [
      { id: 'tm-thn-1', leadVet: 'Dr. Sawant', mobileUnit: 'Thane MVU', contact: '+91 98229 33019', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Kalyan Rural', syndrome: 'Mild Skin Wheals', cattleAffected: 4 }
    ],
    coordinates: [19.3761, 73.3389]
  },
  {
    id: 'palghar',
    districtName: 'Palghar',
    marathiName: 'पालघर',
    division: 'Konkan',
    riskPercentage: 59,
    riskLevel: 'High',
    primaryDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 64,
    mortalityReports: 5,
    vaccinationCoverage: 63.5,
    affectedVillages: 12,
    totalLivestock: 510000,
    trend: '+10%',
    riskExplanation: 'Coastal tribal belts in Jawhar and Mokhada facing goat morbidity amid coastal rains.',
    recommendedAction: 'Deploy mobile veterinary vans along ghat roads for accelerated PPR and Enterotoxaemia vaccination.',
    vaccinationGap: 'High gap: 21.5% below target',
    whyAtRisk: [
      'Rainfall-induced stress and high humidity in goat pens',
      'Tribal pastoralists relying on seasonal open forest grazing'
    ],
    assignedTeams: [
      { id: 'tm-plg-1', leadVet: 'Dr. Gavit', mobileUnit: 'Jawhar Tribal MVU', contact: '+91 94223 66014', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Mokhada', syndrome: 'Ocular Discharge & Mouth Erosions in Goats', cattleAffected: 15 }
    ],
    coordinates: [19.8072, 72.9454]
  },
  {
    id: 'raigad',
    districtName: 'Raigad',
    marathiName: 'रायगड',
    division: 'Konkan',
    riskPercentage: 30,
    riskLevel: 'Low',
    primaryDisease: 'Routine Surveillance',
    activeCases: 12,
    mortalityReports: 0,
    vaccinationCoverage: 85.1,
    affectedVillages: 4,
    totalLivestock: 420000,
    trend: '-3%',
    riskExplanation: 'Coastal agricultural plain with low disease incidence and steady coverage progress.',
    recommendedAction: 'Maintain deworming camps for coastal draft buffaloes.',
    vaccinationGap: 'Target met (+0.1% surplus)',
    whyAtRisk: [
      'High coastal salinity and rainfall necessitating regular liver-fluke prophylaxis'
    ],
    assignedTeams: [
      { id: 'tm-rgd-1', leadVet: 'Dr. Patil', mobileUnit: 'Alibag MVU', contact: '+91 98224 11890', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Pen', syndrome: 'Submandibular Bottle Jaw', cattleAffected: 3 }
    ],
    coordinates: [18.437, 73.2764]
  },
  {
    id: 'ratnagiri',
    districtName: 'Ratnagiri',
    marathiName: 'रत्नागिरी',
    division: 'Konkan',
    riskPercentage: 22,
    riskLevel: 'Low',
    primaryDisease: 'Routine Surveillance',
    activeCases: 7,
    mortalityReports: 0,
    vaccinationCoverage: 88.6,
    affectedVillages: 3,
    totalLivestock: 390000,
    trend: '-7%',
    riskExplanation: 'Excellent vaccination coverage and low herd density limit contagious outbreak risks.',
    recommendedAction: 'Sustain coastal animal health surveillance and parasitic control.',
    vaccinationGap: 'Above target (+3.6% surplus)',
    whyAtRisk: [
      'Low bovine density reduces rapid contagious transmission risk'
    ],
    assignedTeams: [
      { id: 'tm-rtn-1', leadVet: 'Dr. Joshi', mobileUnit: 'Ratnagiri MVU', contact: '+91 94227 55902', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Chiplun', syndrome: 'Mild Tick Infestation', cattleAffected: 2 }
    ],
    coordinates: [17.2626, 73.4558]
  },
  {
    id: 'sindhudurg',
    districtName: 'Sindhudurg',
    marathiName: 'सिंधुदुर्ग',
    division: 'Konkan',
    riskPercentage: 18,
    riskLevel: 'Low',
    primaryDisease: 'Routine Surveillance',
    activeCases: 5,
    mortalityReports: 0,
    vaccinationCoverage: 91.2,
    affectedVillages: 2,
    totalLivestock: 310000,
    trend: '-9%',
    riskExplanation: 'Lowest disease vulnerability in Maharashtra due to high immunisation saturation and proactive veterinary extension.',
    recommendedAction: 'Maintain disease-free status through Goa and Karnataka border check-posts.',
    vaccinationGap: 'Benchmark exceeded (+6.2% surplus)',
    whyAtRisk: [
      'Geographically insulated topography with well-managed indigenous Konkan Kapila herds'
    ],
    assignedTeams: [
      { id: 'tm-snd-1', leadVet: 'Dr. Parab', mobileUnit: 'Kudal MVU', contact: '+91 98221 44890', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-07', village: 'Kudal', syndrome: 'Routine Health Check', cattleAffected: 1 }
    ],
    coordinates: [16.1811, 73.7433]
  },
  {
    id: 'mumbai-city',
    districtName: 'Mumbai',
    marathiName: 'मुंबई शहर',
    division: 'Konkan',
    riskPercentage: 20,
    riskLevel: 'Low',
    primaryDisease: 'Urban Stable Surveillance',
    activeCases: 4,
    mortalityReports: 0,
    vaccinationCoverage: 94.0,
    affectedVillages: 1,
    totalLivestock: 28000,
    trend: '0%',
    riskExplanation: 'Urban licensed stables with strict municipal veterinary monitoring and mandatory vaccination.',
    recommendedAction: 'Regular inspection of milk stables and slaughterhouse entry biosecurity.',
    vaccinationGap: 'Target met (+9.0% surplus)',
    whyAtRisk: [
      'Very small domestic livestock footprint strictly monitored by BMC'
    ],
    assignedTeams: [
      { id: 'tm-mum-1', leadVet: 'Dr. Shah', mobileUnit: 'BMC Veterinary Wing', contact: '+91 98200 12345', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Byculla', syndrome: 'Stable Inspection Routine', cattleAffected: 1 }
    ],
    coordinates: [18.9582, 72.8401]
  },
  {
    id: 'mumbai-suburban',
    districtName: 'Mumbai Suburban',
    marathiName: 'मुंबई उपनगर',
    division: 'Konkan',
    riskPercentage: 25,
    riskLevel: 'Low',
    primaryDisease: 'Aarey Dairy Colony Monitoring',
    activeCases: 6,
    mortalityReports: 0,
    vaccinationCoverage: 92.5,
    affectedVillages: 1,
    totalLivestock: 65000,
    trend: '-1%',
    riskExplanation: 'Centrally managed dairy colony with dedicated veterinary staff and controlled entry points.',
    recommendedAction: 'Sustain quarterly screening for Tuberculosis and Brucellosis.',
    vaccinationGap: 'Target met (+7.5% surplus)',
    whyAtRisk: [
      'High cattle concentration in Aarey milk sheds requiring vigilant biosecurity'
    ],
    assignedTeams: [
      { id: 'tm-sub-1', leadVet: 'Dr. Kulkarni', mobileUnit: 'Aarey Vet Hospital', contact: '+91 98201 55678', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Aarey Colony', syndrome: 'Mastitis Check', cattleAffected: 2 }
    ],
    coordinates: [19.1357, 72.8538]
  }
];

// Helper: Normalize district name for resilient matching across spelling variants
export function normalizeDistrictName(name: string): string {
  if (!name) return '';
  const lower = name.toLowerCase().trim();
  
  // Specific alias mappings
  if (lower.includes('ahmednagar') || lower.includes('ahmadnagar') || lower.includes('ahilya')) return 'ahmednagar';
  if (lower.includes('aurangabad') || lower.includes('sambhajinagar') || lower.includes('chhatrapati')) return 'aurangabad';
  if (lower.includes('beed') || lower.includes('bid')) return 'beed';
  if (lower.includes('dharashiv') || lower.includes('osmanabad')) return 'dharashiv';
  if (lower.includes('buldana') || lower.includes('buldhana')) return 'buldhana';
  if (lower.includes('gondia') || lower.includes('gondiya')) return 'gondia';
  if (lower.includes('raigad') || lower.includes('raigarh')) return 'raigad';
  if (lower === 'mumbai' || lower.includes('mumbai city')) return 'mumbai-city';
  if (lower.includes('suburban')) return 'mumbai-suburban';

  return lower.replace(/[^a-z0-9]/g, '');
}

// Find district by name or ID (fuzzy match)
export function getDistrictByName(name: string): DistrictRiskData | undefined {
  if (!name) return undefined;
  const norm = normalizeDistrictName(name);

  return MAHARASHTRA_DISTRICT_RISK_DATA.find((d) => {
    return (
      d.id === norm ||
      normalizeDistrictName(d.districtName) === norm ||
      (d.marathiName && d.marathiName.includes(name))
    );
  });
}

// Risk evaluation helpers
export function getRiskLevelFromScore(score: number): RiskLevel {
  if (score <= 30) return 'Low';
  if (score <= 55) return 'Moderate';
  if (score <= 75) return 'High';
  return 'Critical';
}

/**
 * Color scale matching requirements:
 * Low (0–30%): Emerald green
 * Moderate (31–55%): Amber
 * High (56–75%): Orange
 * Critical (76–100%): Red
 */
export function getRiskColor(riskPercentage: number, opacity: number = 0.75): string {
  if (riskPercentage <= 30) {
    return opacity === 1 ? '#10B981' : `rgba(16, 185, 129, ${opacity})`; // Soft Emerald
  }
  if (riskPercentage <= 55) {
    return opacity === 1 ? '#F59E0B' : `rgba(245, 158, 11, ${opacity})`; // Soft Amber
  }
  if (riskPercentage <= 75) {
    return opacity === 1 ? '#F97316' : `rgba(249, 115, 22, ${opacity})`; // Warm Orange
  }
  return opacity === 1 ? '#EF4444' : `rgba(239, 68, 68, ${opacity})`; // Alert Red
}

export function getVaccinationColor(coverage: number, opacity: number = 0.75): string {
  if (coverage >= 80) {
    return opacity === 1 ? '#10B981' : `rgba(16, 185, 129, ${opacity})`; // Emerald
  }
  if (coverage >= 65) {
    return opacity === 1 ? '#F59E0B' : `rgba(245, 158, 11, ${opacity})`; // Amber
  }
  return opacity === 1 ? '#EF4444' : `rgba(239, 68, 68, ${opacity})`; // Red
}
