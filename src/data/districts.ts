import type { DistrictData } from '../types/government';

export const MAHARASHTRA_DISTRICTS: DistrictData[] = [
  // ─── PUNE DIVISION ────────────────────────────────────────────────────────
  {
    id: 'pune',
    name: 'Pune',
    marathiName: 'पुणे',
    division: 'Pune',
    riskScore: 78,
    riskLevel: 'Critical',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 62,
    mortality: 7,
    vaccinationCoverage: 61.2,
    affectedVillages: 18,
    totalLivestock: 1845000,
    trend: '+16%',
    riskSummary: 'Acute cluster of vesicular lesions and fever in crossbred dairy herds along Haveli and Shirur blocks.',
    whyAtRisk: [
      'Rapid spread of vesicular lesions across dairy clusters',
      'Critical vaccination coverage gap (61.2% vs 85% state mandate)',
      'High livestock mobility across peri-urban milk sheds',
      'Delayed syndromic reporting in 7 peripheral villages'
    ],
    recommendedAction: 'Deploy emergency ring vaccination in 10km radius and activate mobile veterinary containment units.',
    vaccinationGap: 'Critical gap: 23.8% deficit below threshold',
    assignedTeams: [
      { id: 'tm-pun-1', leadVet: 'Dr. Deshmukh', mobileUnit: 'Mobile Vet Van 01', contact: '+91 94220 11022', status: 'Field Deployed' },
      { id: 'tm-pun-2', leadVet: 'Dr. Kadam', mobileUnit: 'Mobile Vet Van 03', contact: '+91 98224 88190', status: 'Field Deployed' },
      { id: 'tm-pun-3', leadVet: 'Dr. Ananya Joshi', mobileUnit: 'RRT Pune Core', contact: '+91 98812 34509', status: 'En Route' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Uruli Kanchan', syndrome: 'Salivation & Foot Lesions', cattleAffected: 14 },
      { date: '2026-09-11', village: 'Wagholi', syndrome: 'High Fever & Blisters', cattleAffected: 9 },
      { date: '2026-09-10', village: 'Loni Kalbhor', syndrome: 'Sudden Milk Drop & Lameness', cattleAffected: 12 },
      { date: '2026-09-08', village: 'Saswad', syndrome: 'Vesicular Eruptions', cattleAffected: 8 }
    ],
    cx: 245,
    cy: 355,
    svgPath: 'M 210,320 L 265,305 L 295,335 L 285,395 L 235,410 L 195,370 Z'
  },
  {
    id: 'satara',
    name: 'Satara',
    marathiName: 'सातारा',
    division: 'Pune',
    riskScore: 28,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 11,
    mortality: 0,
    vaccinationCoverage: 88.4,
    affectedVillages: 4,
    totalLivestock: 1320000,
    trend: '-8%',
    riskSummary: 'Stable syndromic baseline with high vaccination saturation in Krishna valley pastoral zones.',
    whyAtRisk: [
      'High vaccination saturation (88.4%) achieved in Phase 1',
      'Prompt para-vet reporting and quarantine compliance',
      'Zero reported mortality in last 60 days'
    ],
    recommendedAction: 'Maintain baseline syndromic monitoring and sentinel milk testing.',
    vaccinationGap: 'Satisfactory coverage: 3.4% above target',
    assignedTeams: [
      { id: 'tm-sat-1', leadVet: 'Dr. S. Mane', mobileUnit: 'Satara MVU-02', contact: '+91 94231 44520', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Karad Rural', syndrome: 'Mild Respiratory Wheeze', cattleAffected: 3 },
      { date: '2026-09-05', village: 'Wai Khurd', syndrome: 'Transient Inappetence', cattleAffected: 2 }
    ],
    cx: 235,
    cy: 435,
    svgPath: 'M 195,370 L 235,410 L 255,470 L 205,485 L 185,420 Z'
  },
  {
    id: 'solapur',
    name: 'Solapur',
    marathiName: 'सोलापूर',
    division: 'Pune',
    riskScore: 52,
    riskLevel: 'Moderate',
    suspectedDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 29,
    mortality: 2,
    vaccinationCoverage: 73.8,
    affectedVillages: 9,
    totalLivestock: 1780000,
    trend: '+3%',
    riskSummary: 'Moderate PPR respiratory symptoms recorded in migratory small ruminant flocks across Pandharpur belt.',
    whyAtRisk: [
      'Migratory sheep & goat flocks moving through semi-arid corridors',
      'Communal water source congregation during dry spells',
      'Delayed small ruminant booster coverage in remote hamlets'
    ],
    recommendedAction: 'Initiate targeted PPR goat vaccination in migratory clusters and set up checkposts.',
    vaccinationGap: 'Moderate gap: 11.2% deficit for small ruminants',
    assignedTeams: [
      { id: 'tm-sol-1', leadVet: 'Dr. V. Jagtap', mobileUnit: 'Solapur MVU-01', contact: '+91 98221 66734', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Pandharpur South', syndrome: 'Nasal Discharge & Oral Lesions', cattleAffected: 11 },
      { date: '2026-09-08', village: 'Sangola', syndrome: 'Diarrhea & High Fever (Goats)', cattleAffected: 7 }
    ],
    cx: 370,
    cy: 450,
    svgPath: 'M 285,395 L 350,375 L 430,425 L 380,505 L 305,480 L 255,470 Z'
  },
  {
    id: 'kolhapur',
    name: 'Kolhapur',
    marathiName: 'कोल्हापूर',
    division: 'Pune',
    riskScore: 34,
    riskLevel: 'Moderate',
    suspectedDisease: 'Black Quarter (BQ)',
    activeCases: 16,
    mortality: 1,
    vaccinationCoverage: 82.5,
    affectedVillages: 5,
    totalLivestock: 1150000,
    trend: '-6%',
    riskSummary: 'Isolated Black Quarter detections controlled by dairy cooperative veterinary staff.',
    whyAtRisk: [
      'Sporadic seasonal clostridial spores following riverine soil tilling',
      'Prompt antibiotic response initiated by Gokul cooperative vets',
      'Coverage remains strong at 82.5%'
    ],
    recommendedAction: 'Continue weekly cooperative milk route screening and boost unimmunized young calves.',
    vaccinationGap: 'Good coverage: 2.5% below target',
    assignedTeams: [
      { id: 'tm-kol-1', leadVet: 'Dr. P. Patil', mobileUnit: 'Gokul Vet Squad', contact: '+91 94222 55901', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Shirol', syndrome: 'Crepitant Swelling & Limping', cattleAffected: 3 },
      { date: '2026-09-06', village: 'Hatkanangle', syndrome: 'Fever & Muscle Stiffening', cattleAffected: 2 }
    ],
    cx: 215,
    cy: 535,
    svgPath: 'M 180,480 L 225,480 L 250,560 L 195,585 L 165,525 Z'
  },
  {
    id: 'sangli',
    name: 'Sangli',
    marathiName: 'सांगली',
    division: 'Pune',
    riskScore: 39,
    riskLevel: 'Moderate',
    suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 18,
    mortality: 1,
    vaccinationCoverage: 80.1,
    affectedVillages: 6,
    totalLivestock: 1040000,
    trend: '+1%',
    riskSummary: 'Localized low-level syndromic alerts in Krishna floodplain sugarcane fields.',
    whyAtRisk: [
      'High soil humidity along river basin grazing grounds',
      'Inter-district animal transport from Karnataka border'
    ],
    recommendedAction: 'Enforce border checkpost certification and pre-monsoon boosters.',
    vaccinationGap: 'Near target: 4.9% deficit',
    assignedTeams: [
      { id: 'tm-sng-1', leadVet: 'Dr. R. Thorat', mobileUnit: 'Sangli MVU-04', contact: '+91 94233 11200', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Miraj Rural', syndrome: 'Throat Swelling & Dyspnea', cattleAffected: 4 }
    ],
    cx: 275,
    cy: 515,
    svgPath: 'M 235,470 L 305,480 L 295,550 L 230,555 L 225,480 Z'
  },

  // ─── NASHIK DIVISION ──────────────────────────────────────────────────────
  {
    id: 'nashik',
    name: 'Nashik',
    marathiName: 'नाशिक',
    division: 'Nashik',
    riskScore: 68,
    riskLevel: 'High',
    suspectedDisease: 'Brucellosis',
    activeCases: 48,
    mortality: 4,
    vaccinationCoverage: 54.5,
    affectedVillages: 14,
    totalLivestock: 1920000,
    trend: '+12%',
    riskSummary: 'Persistent serological positivity for Brucella abortus in intensive dairy clusters in Niphad and Sinnar.',
    whyAtRisk: [
      'Reproductive disorders and late-term abortions in commercial dairy',
      'Vaccination coverage deficit of 30.5% below required herd threshold',
      'High rate of cattle leasing and unquarantined breeding bull sharing',
      'Bulk milk tank serology showing elevation across 4 chilling centers'
    ],
    recommendedAction: 'Institute mandatory calf-hood S19 vaccination drive and screen breeding bulls.',
    vaccinationGap: 'High gap: 30.5% deficit',
    assignedTeams: [
      { id: 'tm-nsk-1', leadVet: 'Dr. Sonawane', mobileUnit: 'Nashik RRT 01', contact: '+91 94227 33410', status: 'Field Deployed' },
      { id: 'tm-nsk-2', leadVet: 'Dr. Shinde', mobileUnit: 'Nashik MVU-02', contact: '+91 98226 77123', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Niphad Mandi', syndrome: 'Abortion & Retained Placenta', cattleAffected: 8 },
      { date: '2026-09-10', village: 'Sinnar Industrial Zone', syndrome: 'Hygroma & Orchitis', cattleAffected: 6 }
    ],
    cx: 200,
    cy: 220,
    svgPath: 'M 160,180 L 235,170 L 260,240 L 215,280 L 150,245 Z'
  },
  {
    id: 'jalgaon',
    name: 'Jalgaon',
    marathiName: 'जळगाव',
    division: 'Nashik',
    riskScore: 62,
    riskLevel: 'High',
    suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 39,
    mortality: 3,
    vaccinationCoverage: 67.0,
    affectedVillages: 11,
    totalLivestock: 1610000,
    trend: '+8%',
    riskSummary: 'High syndromic alerts of acute respiratory distress in Tapi river valley draft bullocks.',
    whyAtRisk: [
      'Draft bullock exposure in waterlogged alluvial farmlands',
      'Historical vulnerability in Tapi basin with sudden temperature drops',
      'Delayed booster administration in 5 eastern talukas'
    ],
    recommendedAction: 'Pre-position emergency antibiotics and dispatch mobile vet vaccination teams.',
    vaccinationGap: 'High gap: 18.0% deficit',
    assignedTeams: [
      { id: 'tm-jlg-1', leadVet: 'Dr. A. Chaudhari', mobileUnit: 'Tapi Basin MVU', contact: '+91 94225 99011', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Bhusawal North', syndrome: 'Acute Dyspnea & Submandibular Edema', cattleAffected: 7 },
      { date: '2026-09-09', village: 'Raver Orchards', syndrome: 'High Fever & Heavy Salivation', cattleAffected: 5 }
    ],
    cx: 340,
    cy: 145,
    svgPath: 'M 285,115 L 390,110 L 415,175 L 320,195 L 265,165 Z'
  },
  {
    id: 'dhule',
    name: 'Dhule',
    marathiName: 'धुळे',
    division: 'Nashik',
    riskScore: 45,
    riskLevel: 'Moderate',
    suspectedDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 21,
    mortality: 1,
    vaccinationCoverage: 76.2,
    affectedVillages: 7,
    totalLivestock: 890000,
    trend: '+2%',
    riskSummary: 'Scattered nodular cutaneous eruptions in indigenous cattle herds.',
    whyAtRisk: [
      'Vector insect surge along interstate highway buffer zone',
      'Moderate vaccination coverage in pastoral tribal hamlets'
    ],
    recommendedAction: 'Vector fogging in cattle sheds and goat pox booster administration.',
    vaccinationGap: 'Moderate gap: 8.8% deficit',
    assignedTeams: [
      { id: 'tm-dhl-1', leadVet: 'Dr. M. Deore', mobileUnit: 'Dhule MVU-01', contact: '+91 94221 22899', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Shindkheda', syndrome: 'Skin Nodules & Swollen Lymph Nodes', cattleAffected: 6 }
    ],
    cx: 235,
    cy: 130,
    svgPath: 'M 195,100 L 285,115 L 265,165 L 185,160 Z'
  },
  {
    id: 'nandurbar',
    name: 'Nandurbar',
    marathiName: 'नंदुरबार',
    division: 'Nashik',
    riskScore: 41,
    riskLevel: 'Moderate',
    suspectedDisease: 'Anthrax',
    activeCases: 14,
    mortality: 2,
    vaccinationCoverage: 71.0,
    affectedVillages: 5,
    totalLivestock: 680000,
    trend: '0%',
    riskSummary: 'Isolated soil-borne spore exposure reported in hilly tribal forest fringes.',
    whyAtRisk: [
      'Dense forest pasture grazing with historical anthrax focus zones',
      'Difficult remote access for motorized veterinary vans'
    ],
    recommendedAction: 'Enforce ring vaccination in forest fringe villages and carcass disposal SOPs.',
    vaccinationGap: 'Moderate gap: 14.0% deficit',
    assignedTeams: [
      { id: 'tm-ndb-1', leadVet: 'Dr. K. Valvi', mobileUnit: 'Satpura 4x4 Mobile Unit', contact: '+91 94230 44102', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Dhadgaon Forest Area', syndrome: 'Sudden Death & Non-clotting Blood', cattleAffected: 3 }
    ],
    cx: 170,
    cy: 80,
    svgPath: 'M 140,55 L 220,70 L 195,120 L 130,110 Z'
  },
  {
    id: 'ahmednagar',
    name: 'Ahmednagar',
    marathiName: 'अहिल्यानगर',
    division: 'Nashik',
    riskScore: 56,
    riskLevel: 'High',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 37,
    mortality: 3,
    vaccinationCoverage: 69.5,
    affectedVillages: 12,
    totalLivestock: 2350000,
    trend: '+9%',
    riskSummary: 'Spillover risk from Pune border with early vesicular lesions reported in Rahuri and Sangamner.',
    whyAtRisk: [
      'Highest total cattle population in Maharashtra',
      'Intensive daily milk tanker transit to Mumbai and Pune',
      'Calf immunity gap observed in newly calved herds'
    ],
    recommendedAction: 'Accelerate FMD booster camps and establish milk transit sanitization points.',
    vaccinationGap: 'High gap: 15.5% deficit',
    assignedTeams: [
      { id: 'tm-ah-1', leadVet: 'Dr. G. Vikhe', mobileUnit: 'Rahuri Regional Unit', contact: '+91 98223 99801', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Sangamner West', syndrome: 'Vesicles on Tongue & Teats', cattleAffected: 9 },
      { date: '2026-09-10', village: 'Rahuri Farm Border', syndrome: 'High Fever & Inappetence', cattleAffected: 6 }
    ],
    cx: 275,
    cy: 285,
    svgPath: 'M 235,170 L 320,195 L 340,290 L 265,305 L 215,280 Z'
  },

  // ─── CHHATRAPATI SAMBHAJINAGAR (AURANGABAD) DIVISION ──────────────────────
  {
    id: 'chhatrapati-sambhajinagar',
    name: 'Chhatrapati Sambhajinagar',
    marathiName: 'छत्रपती संभाजीनगर',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 57,
    riskLevel: 'High',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 38,
    mortality: 3,
    vaccinationCoverage: 68.4,
    affectedVillages: 11,
    totalLivestock: 1450000,
    trend: '+9%',
    riskSummary: 'Vesicular lesion reports emerging from weekly livestock markets in Paithan and Gangapur.',
    whyAtRisk: [
      'Major regional livestock trading hub at weekly cattle markets',
      'Immunity dip in young stock between 6 to 12 months',
      'Interstate truck transit convergence'
    ],
    recommendedAction: 'Institute mandatory market health checks and deploy mobile ring vaccination.',
    vaccinationGap: 'High gap: 16.6% deficit',
    assignedTeams: [
      { id: 'tm-cs-1', leadVet: 'Dr. B. Kale', mobileUnit: 'Sambhajinagar RRT', contact: '+91 94223 11988', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Gangapur Mandi', syndrome: 'Foot Lesions & Drooling', cattleAffected: 8 },
      { date: '2026-09-08', village: 'Paithan Rural', syndrome: 'Oral Ulcers & Lameness', cattleAffected: 5 }
    ],
    cx: 355,
    cy: 250,
    svgPath: 'M 320,195 L 400,210 L 415,285 L 340,290 Z'
  },
  {
    id: 'jalna',
    name: 'Jalna',
    marathiName: 'जालना',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 48,
    riskLevel: 'Moderate',
    suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 23,
    mortality: 2,
    vaccinationCoverage: 74.0,
    affectedVillages: 7,
    totalLivestock: 980000,
    trend: '+4%',
    riskSummary: 'Scattered acute fever cases in draft animals along Kundalika river basin.',
    whyAtRisk: [
      'Seasonal grazing shifts post harvest',
      'Moderate vaccination coverage in rainfed villages'
    ],
    recommendedAction: 'Deploy prophylactic antibiotic reserves and inspect village cattle water tanks.',
    vaccinationGap: 'Moderate gap: 11.0% deficit',
    assignedTeams: [
      { id: 'tm-jln-1', leadVet: 'Dr. S. Rathod', mobileUnit: 'Jalna Vet Van 02', contact: '+91 94228 77610', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Ambad Khurd', syndrome: 'Rapid Respiration & Fever', cattleAffected: 5 }
    ],
    cx: 430,
    cy: 260,
    svgPath: 'M 400,210 L 475,225 L 475,295 L 415,285 Z'
  },
  {
    id: 'parbhani',
    name: 'Parbhani',
    marathiName: 'परभणी',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 50,
    riskLevel: 'Moderate',
    suspectedDisease: 'Black Quarter (BQ)',
    activeCases: 25,
    mortality: 2,
    vaccinationCoverage: 72.8,
    affectedVillages: 8,
    totalLivestock: 1020000,
    trend: '+3%',
    riskSummary: 'Localized clostridial swelling reports following unseasonal rain showers.',
    whyAtRisk: [
      'Godavari river bank silt pastures prone to clostridial spore exposure',
      'Gaps in booster coverage in nomadic shepherd groups'
    ],
    recommendedAction: 'Organize village-level BQ booster camps and public awareness announcements.',
    vaccinationGap: 'Moderate gap: 12.2% deficit',
    assignedTeams: [
      { id: 'tm-pbn-1', leadVet: 'Dr. N. Kulkarni', mobileUnit: 'Parbhani MVU-01', contact: '+91 98229 00412', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Jintur Road', syndrome: 'Subcutaneous Emphysema & Lameness', cattleAffected: 4 }
    ],
    cx: 500,
    cy: 295,
    svgPath: 'M 475,225 L 545,245 L 535,325 L 475,295 Z'
  },
  {
    id: 'hingoli',
    name: 'Hingoli',
    marathiName: 'हिंगोली',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 42,
    riskLevel: 'Moderate',
    suspectedDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 17,
    mortality: 1,
    vaccinationCoverage: 75.5,
    affectedVillages: 5,
    totalLivestock: 610000,
    trend: '-1%',
    riskSummary: 'Mild syndromic reports in sheep and goat flocks near Vidarbha boundary.',
    whyAtRisk: [
      'Inter-district pastoral movement between Marathwada and Vidarbha'
    ],
    recommendedAction: 'Continue weekly sentinel herd surveillance.',
    vaccinationGap: 'Moderate gap: 9.5% deficit',
    assignedTeams: [
      { id: 'tm-hng-1', leadVet: 'Dr. D. Jadhav', mobileUnit: 'Hingoli Vet Squad', contact: '+91 94220 33811', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-07', village: 'Basmath Rural', syndrome: 'Ocular Discharge in Sheep', cattleAffected: 5 }
    ],
    cx: 535,
    cy: 235,
    svgPath: 'M 515,190 L 575,205 L 555,265 L 505,245 Z'
  },
  {
    id: 'nanded',
    name: 'Nanded',
    marathiName: 'नांदेड',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 53,
    riskLevel: 'Moderate',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 31,
    mortality: 2,
    vaccinationCoverage: 71.8,
    affectedVillages: 10,
    totalLivestock: 1390000,
    trend: '+5%',
    riskSummary: 'Elevated border risk from northern Telangana livestock transit corridors.',
    whyAtRisk: [
      'Border transit points from northern Telangana without quarantine stalls',
      'Isolated fever spikes in peripheral gaushalas',
      'Pasture water pooling along Godavari river banks'
    ],
    recommendedAction: 'Strengthen border veterinary checkposts and conduct ring vaccination.',
    vaccinationGap: 'Moderate gap: 13.2% deficit',
    assignedTeams: [
      { id: 'tm-nd-1', leadVet: 'Dr. M. Syed', mobileUnit: 'Nanded Border MVU', contact: '+91 98224 55109', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Degloor Border', syndrome: 'Oral Blisters & Excessive Drooling', cattleAffected: 7 },
      { date: '2026-09-08', village: 'Mukhed', syndrome: 'Lameness in Draft Buffaloes', cattleAffected: 4 }
    ],
    cx: 580,
    cy: 335,
    svgPath: 'M 545,245 L 635,275 L 625,385 L 535,355 L 535,325 Z'
  },
  {
    id: 'beed',
    name: 'Beed',
    marathiName: 'बीड',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 47,
    riskLevel: 'Moderate',
    suspectedDisease: 'Brucellosis',
    activeCases: 22,
    mortality: 1,
    vaccinationCoverage: 74.5,
    affectedVillages: 8,
    totalLivestock: 1530000,
    trend: '+2%',
    riskSummary: 'Sporadic reproductive disorder flags in drought-prone dairy holdings.',
    whyAtRisk: [
      'Seasonal fodder scarcity causing herd aggregation at central relief camps',
      'Under-reporting of bovine abortions in private smallholder pens'
    ],
    recommendedAction: 'Distribute milk ring test kits to veterinary dispensaries.',
    vaccinationGap: 'Moderate gap: 10.5% deficit',
    assignedTeams: [
      { id: 'tm-bd-1', leadVet: 'Dr. S. Pandhare', mobileUnit: 'Beed MVU-03', contact: '+91 94227 11440', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Georai', syndrome: 'Late-term Abortion in Buffalo', cattleAffected: 3 }
    ],
    cx: 395,
    cy: 345,
    svgPath: 'M 350,290 L 440,295 L 460,380 L 365,375 Z'
  },
  {
    id: 'latur',
    name: 'Latur',
    marathiName: 'लातूर',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 38,
    riskLevel: 'Moderate',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 20,
    mortality: 1,
    vaccinationCoverage: 79.2,
    affectedVillages: 6,
    totalLivestock: 1120000,
    trend: '-2%',
    riskSummary: 'Contained cluster with rapid recovery following cooperative ring vaccination.',
    whyAtRisk: [
      'Active containment in place across Udgir and Ausa blocks',
      'Vaccination coverage robust at 79.2%',
      'Active sarpanch health vigilance network'
    ],
    recommendedAction: 'Maintain syndromic surveillance until 14-day zero-case window achieved.',
    vaccinationGap: 'Satisfactory coverage: 5.8% deficit',
    assignedTeams: [
      { id: 'tm-ltr-1', leadVet: 'Dr. P. Birajdar', mobileUnit: 'Latur Veterinary Unit', contact: '+91 94233 44001', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Udgir Mandi Outskirts', syndrome: 'Healing Mouth Lesions', cattleAffected: 4 }
    ],
    cx: 485,
    cy: 405,
    svgPath: 'M 440,335 L 535,355 L 515,445 L 445,435 Z'
  },
  {
    id: 'dharashiv',
    name: 'Dharashiv',
    marathiName: 'धाराशिव',
    division: 'Chhatrapati Sambhajinagar',
    riskScore: 35,
    riskLevel: 'Moderate',
    suspectedDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 15,
    mortality: 1,
    vaccinationCoverage: 81.0,
    affectedVillages: 5,
    totalLivestock: 870000,
    trend: '-4%',
    riskSummary: 'Stable disease parameters with ongoing sheep immunisation campaign.',
    whyAtRisk: [
      'Seasonal dryland grazing transit from Karnataka border'
    ],
    recommendedAction: 'Continue targeted village flock audits.',
    vaccinationGap: 'Good coverage: 4.0% deficit',
    assignedTeams: [
      { id: 'tm-dhr-1', leadVet: 'Dr. A. Gaikwad', mobileUnit: 'Dharashiv MVU', contact: '+91 98220 88991', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-07', village: 'Tuljapur Rural', syndrome: 'Mild Coughing in Sheep', cattleAffected: 3 }
    ],
    cx: 420,
    cy: 425,
    svgPath: 'M 365,375 L 445,385 L 445,465 L 380,470 Z'
  },

  // ─── AMRAVATI DIVISION ────────────────────────────────────────────────────
  {
    id: 'amravati',
    name: 'Amravati',
    marathiName: 'अमरावती',
    division: 'Amravati',
    riskScore: 72,
    riskLevel: 'High',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 52,
    mortality: 5,
    vaccinationCoverage: 64.1,
    affectedVillages: 15,
    totalLivestock: 1380000,
    trend: '+14%',
    riskSummary: 'Accelerating vesicular disease alerts in Melghat foothills and Chandur Railway cattle holdings.',
    whyAtRisk: [
      'Cross-district animal movement from Madhya Pradesh and Vidarbha borders',
      'Cluster symptom surge in 3 rural talukas within 7 days',
      'Vaccination backlog in smallholder and tribal dairy farms',
      'Pasture water stagnation following heavy rainfall'
    ],
    recommendedAction: 'Deploy 5km radius ring vaccination and enforce checkpost disinfectant dips.',
    vaccinationGap: 'High gap: 20.9% deficit',
    assignedTeams: [
      { id: 'tm-amr-1', leadVet: 'Dr. R. Wankhade', mobileUnit: 'Amravati RRT 02', contact: '+91 94228 11920', status: 'Field Deployed' },
      { id: 'tm-amr-2', leadVet: 'Dr. S. Tayade', mobileUnit: 'Melghat 4x4 Van', contact: '+91 98225 33019', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Chandur Railway', syndrome: 'Blisters on Tongue & Coronary Band', cattleAffected: 11 },
      { date: '2026-09-10', village: 'Achalpur Foothills', syndrome: 'High Fever, Milk Drop & Drooling', cattleAffected: 8 },
      { date: '2026-09-08', village: 'Daryapur', syndrome: 'Severe Lameness in Working Bullocks', cattleAffected: 6 }
    ],
    cx: 565,
    cy: 140,
    svgPath: 'M 490,75 L 610,85 L 620,165 L 530,175 L 485,140 Z'
  },
  {
    id: 'akola',
    name: 'Akola',
    marathiName: 'अकोला',
    division: 'Amravati',
    riskScore: 54,
    riskLevel: 'Moderate',
    suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 28,
    mortality: 2,
    vaccinationCoverage: 70.5,
    affectedVillages: 9,
    totalLivestock: 760000,
    trend: '+6%',
    riskSummary: 'Submandibular edema and fever cases flagged in Purna valley buffaloes.',
    whyAtRisk: [
      'Riverine floodplain grazing along Purna river',
      'Gaps in pre-monsoon vaccination in remote farm clusters'
    ],
    recommendedAction: 'Administer prophylactic alum precipitated HS vaccines in vulnerable riverine blocks.',
    vaccinationGap: 'Moderate gap: 14.5% deficit',
    assignedTeams: [
      { id: 'tm-akl-1', leadVet: 'Dr. H. Agrawal', mobileUnit: 'Akola MVU-01', contact: '+91 94221 88402', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Murtizapur', syndrome: 'Throat Swelling & Labored Breathing', cattleAffected: 6 }
    ],
    cx: 475,
    cy: 165,
    svgPath: 'M 435,125 L 490,135 L 515,200 L 445,190 Z'
  },
  {
    id: 'buldhana',
    name: 'Buldhana',
    marathiName: 'बुलढाणा',
    division: 'Amravati',
    riskScore: 49,
    riskLevel: 'Moderate',
    suspectedDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 26,
    mortality: 1,
    vaccinationCoverage: 73.0,
    affectedVillages: 8,
    totalLivestock: 1140000,
    trend: '+3%',
    riskSummary: 'Mild vector-borne nodular skin cases observed in Shegaon and Khamgaon blocks.',
    whyAtRisk: [
      'Elevated vector mosquito and biting fly population after showers',
      'Border trade transit with Jalgaon and Madhya Pradesh'
    ],
    recommendedAction: 'Organize vector control fogging and provide supportive treatment kits.',
    vaccinationGap: 'Moderate gap: 12.0% deficit',
    assignedTeams: [
      { id: 'tm-bld-1', leadVet: 'Dr. V. Kharat', mobileUnit: 'Buldhana MVU-02', contact: '+91 98226 11099', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Khamgaon Outskirts', syndrome: 'Cutaneous Nodules & Edema', cattleAffected: 7 }
    ],
    cx: 405,
    cy: 165,
    svgPath: 'M 365,120 L 435,125 L 445,210 L 375,190 Z'
  },
  {
    id: 'yavatmal',
    name: 'Yavatmal',
    marathiName: 'यवतमाळ',
    division: 'Amravati',
    riskScore: 55,
    riskLevel: 'Moderate',
    suspectedDisease: 'Anthrax',
    activeCases: 32,
    mortality: 3,
    vaccinationCoverage: 69.0,
    affectedVillages: 10,
    totalLivestock: 1280000,
    trend: '+7%',
    riskSummary: 'Soil spore activation warning in historically endemic forest fringes.',
    whyAtRisk: [
      'Unseasonal rain exposing deep soil spore reservoirs',
      'Extensive communal scrubland grazing with unimmunized indigenous cattle'
    ],
    recommendedAction: 'Execute compulsory anthrax spore vaccination within 10km of reported focus points.',
    vaccinationGap: 'Moderate gap: 16.0% deficit',
    assignedTeams: [
      { id: 'tm-yvt-1', leadVet: 'Dr. C. Meshram', mobileUnit: 'Yavatmal Rapid Response Unit', contact: '+91 94229 66012', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Wani Rural', syndrome: 'Peracute Death & Bloody Discharge', cattleAffected: 4 },
      { date: '2026-09-08', village: 'Pusad Forest Fringe', syndrome: 'Severe Colic & High Fever', cattleAffected: 5 }
    ],
    cx: 585,
    cy: 235,
    svgPath: 'M 530,175 L 625,185 L 655,275 L 555,265 Z'
  },
  {
    id: 'washim',
    name: 'Washim',
    marathiName: 'वाशीम',
    division: 'Amravati',
    riskScore: 37,
    riskLevel: 'Moderate',
    suspectedDisease: 'Peste des Petits Ruminants (PPR)',
    activeCases: 16,
    mortality: 1,
    vaccinationCoverage: 78.5,
    affectedVillages: 5,
    totalLivestock: 620000,
    trend: '-1%',
    riskSummary: 'Stable health profile with ongoing small ruminant immunization.',
    whyAtRisk: [
      'Regular migratory sheep flock entry from Hingoli border'
    ],
    recommendedAction: 'Continue routine syndromic surveillance and vaccination audits.',
    vaccinationGap: 'Satisfactory coverage: 6.5% deficit',
    assignedTeams: [
      { id: 'tm-wsh-1', leadVet: 'Dr. T. Raut', mobileUnit: 'Washim MVU-01', contact: '+91 94224 88301', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-06', village: 'Risod Outskirts', syndrome: 'Mild Coughing in Goats', cattleAffected: 4 }
    ],
    cx: 495,
    cy: 215,
    svgPath: 'M 465,185 L 530,195 L 525,255 L 465,240 Z'
  },

  // ─── NAGPUR DIVISION ──────────────────────────────────────────────────────
  {
    id: 'nagpur',
    name: 'Nagpur',
    marathiName: 'नागपूर',
    division: 'Nagpur',
    riskScore: 81,
    riskLevel: 'Critical',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 64,
    mortality: 8,
    vaccinationCoverage: 60.8,
    affectedVillages: 19,
    totalLivestock: 1180000,
    trend: '+18%',
    riskSummary: 'Severe multi-taluka outbreak of acute vesicular stomatitis and milk drop across peri-urban and rural dairy belt.',
    whyAtRisk: [
      'Rapid cluster transmission in dense dairy co-operatives',
      'Critical vaccination coverage deficit (60.8% vs 85% mandate)',
      'Rising young stock mortality in unimmunized crossbred cattle',
      'Major regional transport intersection bringing unquarantined livestock'
    ],
    recommendedAction: 'Declare containment buffer zone, freeze livestock markets for 14 days, and launch emergency ring vaccination.',
    vaccinationGap: 'Critical gap: 24.2% deficit below threshold',
    assignedTeams: [
      { id: 'tm-nag-1', leadVet: 'Dr. Anil Gajbhiye', mobileUnit: 'Nagpur Rapid Response 01', contact: '+91 94221 77209', status: 'Field Deployed' },
      { id: 'tm-nag-2', leadVet: 'Dr. Sunita Pendam', mobileUnit: 'Nagpur Mobile Unit 03', contact: '+91 98223 44109', status: 'Field Deployed' },
      { id: 'tm-nag-3', leadVet: 'Dr. Rajesh Kohale', mobileUnit: 'Vidarbha Veterinary Taskforce', contact: '+91 94235 99201', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-12', village: 'Kamptee Dairy Belt', syndrome: 'Ruptured Vesicles & Profuse Salivation', cattleAffected: 16 },
      { date: '2026-09-11', village: 'Hingna Rural', syndrome: 'Severe Lameness & Teat Lesions', cattleAffected: 12 },
      { date: '2026-09-10', village: 'Umred Cattle Market', syndrome: 'High Fever & Mouth Erosion', cattleAffected: 14 },
      { date: '2026-09-09', village: 'Katol Citrus Belt', syndrome: 'Acute Inappetence in Calves', cattleAffected: 9 }
    ],
    cx: 675,
    cy: 135,
    svgPath: 'M 620,85 L 720,95 L 735,185 L 645,175 Z'
  },
  {
    id: 'wardha',
    name: 'Wardha',
    marathiName: 'वर्धा',
    division: 'Nagpur',
    riskScore: 58,
    riskLevel: 'High',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 34,
    mortality: 2,
    vaccinationCoverage: 69.2,
    affectedVillages: 10,
    totalLivestock: 690000,
    trend: '+10%',
    riskSummary: 'Secondary spread from adjacent Nagpur outbreak detected in Arvi and Seloo dairy farms.',
    whyAtRisk: [
      'Direct highway corridor connection to Nagpur outbreak epicentre',
      'Daily milk vehicle movement between Wardha collection centers and Nagpur',
      'Immunity gap in smallholder dairy buffaloes'
    ],
    recommendedAction: 'Establish border disinfection barricades and execute ring vaccination in northern blocks.',
    vaccinationGap: 'High gap: 15.8% deficit',
    assignedTeams: [
      { id: 'tm-wrd-1', leadVet: 'Dr. B. Dhage', mobileUnit: 'Wardha RRT 01', contact: '+91 94228 33501', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Arvi Dairy Route', syndrome: 'Tongue Vesicles & Drooling', cattleAffected: 8 },
      { date: '2026-09-09', village: 'Seloo', syndrome: 'Fever & Lameness in Buffaloes', cattleAffected: 6 }
    ],
    cx: 635,
    cy: 200,
    svgPath: 'M 610,165 L 665,175 L 655,250 L 595,240 Z'
  },
  {
    id: 'bhandara',
    name: 'Bhandara',
    marathiName: 'भंडारा',
    division: 'Nagpur',
    riskScore: 51,
    riskLevel: 'Moderate',
    suspectedDisease: 'Haemorrhagic Septicaemia (HS)',
    activeCases: 24,
    mortality: 2,
    vaccinationCoverage: 72.0,
    affectedVillages: 7,
    totalLivestock: 640000,
    trend: '+4%',
    riskSummary: 'Respiratory distress alerts in Wainganga river basin rice paddy draft animals.',
    whyAtRisk: [
      'Extensive paddy field waterlogging where working bullocks graze',
      'Moisture induced bacterial survival in community ponds'
    ],
    recommendedAction: 'Pre-position emergency antibiotics and vaccinate draft animals.',
    vaccinationGap: 'Moderate gap: 13.0% deficit',
    assignedTeams: [
      { id: 'tm-bhn-1', leadVet: 'Dr. S. Bawankar', mobileUnit: 'Wainganga Basin Unit', contact: '+91 94220 99812', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-10', village: 'Tumsar Paddy Belt', syndrome: 'Swollen Neck & Labored Breathing', cattleAffected: 5 }
    ],
    cx: 755,
    cy: 145,
    svgPath: 'M 720,95 L 785,105 L 775,185 L 725,175 Z'
  },
  {
    id: 'gondia',
    name: 'Gondia',
    marathiName: 'गोंदिया',
    division: 'Nagpur',
    riskScore: 46,
    riskLevel: 'Moderate',
    suspectedDisease: 'Anthrax',
    activeCases: 19,
    mortality: 2,
    vaccinationCoverage: 73.5,
    affectedVillages: 6,
    totalLivestock: 710000,
    trend: '+1%',
    riskSummary: 'Isolated sudden death alarms in remote forested border hamlets adjoining Chhattisgarh.',
    whyAtRisk: [
      'Dense interstate forest buffer with unscreened wildlife and livestock interaction',
      'Hard to reach forest villages requiring mobile backpack vaccination teams'
    ],
    recommendedAction: 'Maintain forest fringe checkposts and deploy mobile para-vet backpack units.',
    vaccinationGap: 'Moderate gap: 11.5% deficit',
    assignedTeams: [
      { id: 'tm-gnd-1', leadVet: 'Dr. P. Uikey', mobileUnit: 'Gondia Tribal Forest Unit', contact: '+91 94234 55102', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Deori Forest Edge', syndrome: 'Sudden Incollapse & Pyrexia', cattleAffected: 4 }
    ],
    cx: 820,
    cy: 155,
    svgPath: 'M 785,105 L 865,115 L 845,215 L 775,185 Z'
  },
  {
    id: 'chandrapur',
    name: 'Chandrapur',
    marathiName: 'चंद्रपूर',
    division: 'Nagpur',
    riskScore: 61,
    riskLevel: 'High',
    suspectedDisease: 'Foot-and-Mouth Disease (FMD)',
    activeCases: 39,
    mortality: 4,
    vaccinationCoverage: 65.8,
    affectedVillages: 12,
    totalLivestock: 1050000,
    trend: '+8%',
    riskSummary: 'Vesicular lesions detected in cattle herds along Wardha river industrial corridor.',
    whyAtRisk: [
      'High density cattle movements across Telangana and Andhra borders',
      'Industrial peri-urban dairy herds with low vaccination compliance',
      'Recent inter-village bullock cart racing events'
    ],
    recommendedAction: 'Cancel cattle congregations and initiate mass ring vaccination in southern blocks.',
    vaccinationGap: 'High gap: 19.2% deficit',
    assignedTeams: [
      { id: 'tm-chd-1', leadVet: 'Dr. K. Naitam', mobileUnit: 'Chandrapur RRT 01', contact: '+91 98222 00192', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-11', village: 'Ballarpur Industrial', syndrome: 'Erosive Stomatitis & Fever', cattleAffected: 8 },
      { date: '2026-09-09', village: 'Rajura South', syndrome: 'Severe Hoof Lesions', cattleAffected: 6 }
    ],
    cx: 710,
    cy: 285,
    svgPath: 'M 655,225 L 755,215 L 755,360 L 665,345 Z'
  },
  {
    id: 'gadchiroli',
    name: 'Gadchiroli',
    marathiName: 'गडचिरोली',
    division: 'Nagpur',
    riskScore: 44,
    riskLevel: 'Moderate',
    suspectedDisease: 'Anthrax',
    activeCases: 17,
    mortality: 2,
    vaccinationCoverage: 68.5,
    affectedVillages: 7,
    totalLivestock: 620000,
    trend: '0%',
    riskSummary: 'Endemic forest soil focus points closely tracked with village tribal networks.',
    whyAtRisk: [
      'Vast forest expanse with remote tribal cattle rearers',
      'Monsoon access limitations in remote naxal-affected blocks'
    ],
    recommendedAction: 'Utilize specialized tribal health workers for syndromic alerting and vaccine distribution.',
    vaccinationGap: 'Moderate gap: 16.5% deficit',
    assignedTeams: [
      { id: 'tm-gdc-1', leadVet: 'Dr. V. Madavi', mobileUnit: 'Gadchiroli Mobile Dispensary', contact: '+91 94223 77011', status: 'Field Deployed' }
    ],
    recentReports: [
      { date: '2026-09-07', village: 'Aheri Forest Range', syndrome: 'Sudden Pyrexia & Death in Bull', cattleAffected: 3 }
    ],
    cx: 810,
    cy: 330,
    svgPath: 'M 755,215 L 860,225 L 880,450 L 765,420 L 755,360 Z'
  },

  // ─── KONKAN DIVISION ──────────────────────────────────────────────────────
  {
    id: 'mumbai-city',
    name: 'Mumbai City',
    marathiName: 'मुंबई शहर',
    division: 'Konkan',
    riskScore: 18,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 4,
    mortality: 0,
    vaccinationCoverage: 94.0,
    affectedVillages: 1,
    totalLivestock: 45000,
    trend: '-12%',
    riskSummary: 'Urban stables under continuous municipal sanitary supervision.',
    whyAtRisk: [
      'Very small urban dairy stable population',
      'Strict municipal corporation animal entry screening'
    ],
    recommendedAction: 'Maintain urban dairy health certification audits.',
    vaccinationGap: 'Target exceeded: 9.0% surplus',
    assignedTeams: [
      { id: 'tm-mum-1', leadVet: 'Dr. S. Kazi', mobileUnit: 'BMC Vet Inspection Unit', contact: '+91 98200 11223', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-05', village: 'Dharavi Stables', syndrome: 'Mild Respiratory Cough', cattleAffected: 2 }
    ],
    cx: 95,
    cy: 330,
    svgPath: 'M 85,315 L 105,315 L 105,345 L 85,345 Z'
  },
  {
    id: 'mumbai-suburban',
    name: 'Mumbai Suburban',
    marathiName: 'मुंबई उपनगर',
    division: 'Konkan',
    riskScore: 22,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 6,
    mortality: 0,
    vaccinationCoverage: 92.5,
    affectedVillages: 2,
    totalLivestock: 95000,
    trend: '-10%',
    riskSummary: 'Aarey Milk Colony herds exhibiting stable baseline immunity.',
    whyAtRisk: [
      'Organized dairy units with captive veterinary officers in Aarey Colony'
    ],
    recommendedAction: 'Continue weekly bulk milk sample diagnostic screening.',
    vaccinationGap: 'Target exceeded: 7.5% surplus',
    assignedTeams: [
      { id: 'tm-mumb-2', leadVet: 'Dr. M. Sawant', mobileUnit: 'Aarey Dairy Health Unit', contact: '+91 98201 44556', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Aarey Unit 12', syndrome: 'Minor Indigestion', cattleAffected: 3 }
    ],
    cx: 105,
    cy: 310,
    svgPath: 'M 90,295 L 120,295 L 115,325 L 88,320 Z'
  },
  {
    id: 'thane',
    name: 'Thane',
    marathiName: 'ठाणे',
    division: 'Konkan',
    riskScore: 25,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 9,
    mortality: 0,
    vaccinationCoverage: 91.0,
    affectedVillages: 3,
    totalLivestock: 380000,
    trend: '-11%',
    riskSummary: 'High vaccination coverage across peri-urban and rural dairy farms.',
    whyAtRisk: [
      'Vaccination coverage exceeds state target at 91.0%',
      'Low density peri-urban dairy holdings',
      'Rapid diagnostic access to veterinary college labs'
    ],
    recommendedAction: 'Maintain baseline syndromic tracking and highway livestock checkpoint logs.',
    vaccinationGap: 'Target exceeded: 6.0% surplus',
    assignedTeams: [
      { id: 'tm-thn-1', leadVet: 'Dr. S. Bhoir', mobileUnit: 'Thane Regional MVU', contact: '+91 94220 55110', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-09', village: 'Bhiwandi Rural', syndrome: 'Mild Skin Scratches', cattleAffected: 2 }
    ],
    cx: 125,
    cy: 285,
    svgPath: 'M 105,260 L 160,265 L 155,315 L 105,310 Z'
  },
  {
    id: 'palghar',
    name: 'Palghar',
    marathiName: 'पालघर',
    division: 'Konkan',
    riskScore: 32,
    riskLevel: 'Moderate',
    suspectedDisease: 'Lumpy Skin Disease (LSD)',
    activeCases: 15,
    mortality: 0,
    vaccinationCoverage: 83.5,
    affectedVillages: 5,
    totalLivestock: 510000,
    trend: '-3%',
    riskSummary: 'Scattered nodular skin lesions in coastal tribal cattle holdings.',
    whyAtRisk: [
      'Coastal humid breeze supporting mosquito vectors',
      'Gujarat border transit along NH48'
    ],
    recommendedAction: 'Administer goat pox vaccine boosters to young stock.',
    vaccinationGap: 'Good coverage: 1.5% deficit',
    assignedTeams: [
      { id: 'tm-pal-1', leadVet: 'Dr. D. Patil', mobileUnit: 'Palghar Coastal MVU', contact: '+91 94226 77801', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-08', village: 'Dahanu Coastal Hamlet', syndrome: 'Mild Skin Nodules', cattleAffected: 4 }
    ],
    cx: 110,
    cy: 215,
    svgPath: 'M 85,150 L 150,165 L 160,260 L 95,255 Z'
  },
  {
    id: 'raigad',
    name: 'Raigad',
    marathiName: 'रायगड',
    division: 'Konkan',
    riskScore: 29,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 12,
    mortality: 0,
    vaccinationCoverage: 87.0,
    affectedVillages: 4,
    totalLivestock: 620000,
    trend: '-7%',
    riskSummary: 'Clean syndromic record with satisfactory vaccination penetration.',
    whyAtRisk: [
      'Stable coastal microclimate',
      'Good field veterinary coverage across talukas'
    ],
    recommendedAction: 'Continue routine syndromic surveillance.',
    vaccinationGap: 'Satisfactory coverage: 2.0% above target',
    assignedTeams: [
      { id: 'tm-rgd-1', leadVet: 'Dr. M. Sawant', mobileUnit: 'Raigad MVU-01', contact: '+91 94223 88129', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-07', village: 'Alibag Outskirts', syndrome: 'Minor Hoof Abrasion', cattleAffected: 3 }
    ],
    cx: 145,
    cy: 375,
    svgPath: 'M 105,335 L 180,345 L 175,425 L 115,415 Z'
  },
  {
    id: 'ratnagiri',
    name: 'Ratnagiri',
    marathiName: 'रत्नागिरी',
    division: 'Konkan',
    riskScore: 24,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 8,
    mortality: 0,
    vaccinationCoverage: 89.5,
    affectedVillages: 3,
    totalLivestock: 580000,
    trend: '-9%',
    riskSummary: 'High vaccination saturation with no acute outbreak signals.',
    whyAtRisk: [
      'Geographical insulation by western ghats ridge',
      'Effective village dairy society vaccination compliance'
    ],
    recommendedAction: 'Maintain periodic milk testing and farm surveillance.',
    vaccinationGap: 'Target exceeded: 4.5% surplus',
    assignedTeams: [
      { id: 'tm-rtn-1', leadVet: 'Dr. V. Joshi', mobileUnit: 'Ratnagiri Coast Unit', contact: '+91 94221 44090', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-06', village: 'Chiplun Valley', syndrome: 'Transient Digestive Spasm', cattleAffected: 2 }
    ],
    cx: 140,
    cy: 480,
    svgPath: 'M 115,415 L 185,425 L 175,535 L 125,525 Z'
  },
  {
    id: 'sindhudurg',
    name: 'Sindhudurg',
    marathiName: 'सिंधुदुर्ग',
    division: 'Konkan',
    riskScore: 21,
    riskLevel: 'Low',
    suspectedDisease: 'Routine Surveillance',
    activeCases: 6,
    mortality: 0,
    vaccinationCoverage: 91.5,
    affectedVillages: 2,
    totalLivestock: 420000,
    trend: '-10%',
    riskSummary: 'Low epidemiological risk with excellent baseline herd immunity.',
    whyAtRisk: [
      'Comprehensive coverage across coastal and hilly holdings',
      'Goa border livestock checkpost operating 24/7'
    ],
    recommendedAction: 'Maintain baseline surveillance and border checkpost logs.',
    vaccinationGap: 'Target exceeded: 6.5% surplus',
    assignedTeams: [
      { id: 'tm-snd-1', leadVet: 'Dr. R. Rane', mobileUnit: 'Sindhudurg Mobile Unit', contact: '+91 94229 11099', status: 'On Standby' }
    ],
    recentReports: [
      { date: '2026-09-05', village: 'Sawantwadi Rural', syndrome: 'Mild Digestive Sluggishness', cattleAffected: 2 }
    ],
    cx: 155,
    cy: 575,
    svgPath: 'M 125,525 L 185,535 L 175,615 L 135,605 Z'
  }
];

export function getDistrictById(id: string): DistrictData | undefined {
  return MAHARASHTRA_DISTRICTS.find((d) => d.id === id || d.name.toLowerCase() === id.toLowerCase());
}

export function getDistrictsByRisk(risk: string): DistrictData[] {
  if (risk === 'All') return MAHARASHTRA_DISTRICTS;
  return MAHARASHTRA_DISTRICTS.filter((d) => d.riskLevel.toLowerCase() === risk.toLowerCase());
}

export function getDistrictsByDivision(division: string): DistrictData[] {
  if (division === 'All') return MAHARASHTRA_DISTRICTS;
  return MAHARASHTRA_DISTRICTS.filter((d) => d.division === division);
}
