// CaseGraph - Seed: Case 002, Shalini Mane Suspicious Death
// Target: dedicated Kharadi police-station database/graph (station:kharadi_ps)
// This is a SEPARATE database from station:shivajinagar_ps and police_department_hierarchy.
// Every node required by this case is created locally in this database.
// The Person UID matches Shalini's UID in the Kalyani Nagar database; nodes are not physically shared.
// Run each non-commented line separately in FalkorDB Browser, as with the Kalyani seed.

// STEP 0: Clear (run alone first ONLY if this dedicated Kharadi case database may be reset)
MATCH (n) DETACH DELETE n

// STEP 1: Station-local organization (same label/properties convention as Kalyani seed)
CREATE (:Organization {id: 'org_002', name: 'Kharadi Police Station', type: 'police_station', district: 'Pune'})

// STEP 2: Station-local investigator
CREATE (:Investigator {id: 'inv_002', name: 'SI Madhav', rank: 'Sub Inspector'})
MATCH (i:Investigator {id: 'inv_002'}), (o:Organization {id: 'org_002'}) CREATE (i)-[:MEMBER_OF]->(o)

// STEP 3: Case
CREATE (:Case {id: 'case_002', name: 'Shalini Mane Suspicious Death', type: 'suspicious_death', status: 'open', dateOpened: '2026-10-15', fir: 'FIR-2026-KHD-0012', jurisdiction: 'Kharadi', summary: 'Shalini Mane found dead on a service road near Kharadi Bypass. SI Madhav is investigating; the cause and circumstances of death remain under investigation.'})
MATCH (i:Investigator {id: 'inv_002'}), (c:Case {id: 'case_002'}) CREATE (i)-[:ASSIGNED_TO {role: 'lead_investigator', since: '2026-10-15'}]->(c)
MATCH (o:Organization {id: 'org_002'}), (c:Case {id: 'case_002'}) CREATE (o)-[:HANDLES]->(c)

// STEP 4: Shalini person record (same UID as her record in the separate Kalyani Nagar database)
CREATE (:Person {id: 'per_002', uid: 'UID-MH-2002-0088', caseId: 'case_002', name: 'Shalini Mane', dob: '1988-08-25', gender: 'female', address: 'Viman Nagar, Pune', occupation: 'Software Manager', role: 'deceased', notes: 'Left for a solo trip to Mahabaleshwar on 2026-10-08, was reported missing.'})
MATCH (p:Person {id: 'per_002'}), (c:Case {id: 'case_002'}) CREATE (p)-[:VICTIM_IN]->(c)

// STEP 5: Verify case and investigator (run separately)
// MATCH (o:Organization {id: 'org_002'})-[:HANDLES]->(c:Case {id: 'case_002'}) OPTIONAL MATCH (i:Investigator)-[:ASSIGNED_TO]->(c) OPTIONAL MATCH (p:Person {uid: 'UID-MH-2002-0088'})-[:VICTIM_IN]->(c) RETURN o.name AS station, i.name AS investigator, c.name AS case, c.location AS location, p.name AS deceased, p.uid AS personUID, c.status AS status
