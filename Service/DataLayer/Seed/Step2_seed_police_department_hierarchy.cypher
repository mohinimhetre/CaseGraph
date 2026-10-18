// CaseGraph - Seed: Pune City Police Department Hierarchy
// Target: dedicated police_department_hierarchy database/graph
// This is a SEPARATE database from station:shivajinagar_ps and station:kharadi_ps.
// This file creates every node needed for the department hierarchy in this database.
// Run each non-commented line separately in FalkorDB Browser, as with the Kalyani seed.

// STEP 0: Clear (run alone first ONLY if this dedicated hierarchy database may be reset)
MATCH (n) DETACH DELETE n

// STEP 1: Parent police department
CREATE (:PoliceDepartment {id: 'dept_001', name: 'Pune City Police', type: 'police_department', district: 'Pune', city: 'Pune'})

// STEP 2: Police stations (Organization matches the Kalyani Nagar seed convention)
CREATE (:Organization {id: 'org_001', name: 'Shivajinagar Police Station', type: 'police_station', district: 'Pune', graphName: 'station:shivajinagar_ps'})
CREATE (:Organization {id: 'org_002', name: 'Kharadi Police Station', type: 'police_station', district: 'Pune', graphName: 'station:kharadi_ps'})

// STEP 3: Investigators (Investigator matches the Kalyani Nagar seed convention)
CREATE (:Investigator {id: 'inv_001', name: 'SI Priya Sharma', rank: 'Sub Inspector', badgeNumber: 'MH-PN-SI-4421'})
CREATE (:Investigator {id: 'inv_002', name: 'SI Madhav', rank: 'Sub Inspector'})

// STEP 4: Department -> police stations
MATCH (d:PoliceDepartment {id: 'dept_001'}), (s:Organization {id: 'org_001'}) CREATE (d)-[:HAS_STATION]->(s)
MATCH (d:PoliceDepartment {id: 'dept_001'}), (s:Organization {id: 'org_002'}) CREATE (d)-[:HAS_STATION]->(s)

// STEP 5: Investigators belong to their respective stations (same convention as Kalyani seed)
MATCH (i:Investigator {id: 'inv_001'}), (s:Organization {id: 'org_001'}) CREATE (i)-[:MEMBER_OF]->(s)
MATCH (i:Investigator {id: 'inv_002'}), (s:Organization {id: 'org_002'}) CREATE (i)-[:MEMBER_OF]->(s)

// STEP 6: Create cases and create link Investigator -> Case
CREATE (:Case {id: 'case_001', name: 'Kalyani Nagar Murder', type: 'homicide', status: 'open', summary: 'Amit Shah found dead in his flat. Cause of death poisoning. Co-manager Shalini Mane who also fired the suspect is now missing.'})
CREATE (:Case {id: 'case_002', name: 'Shalini Mane Suspicious Death', type: 'suspicious_death', status: 'open', summary: 'Shalini Mane found dead on a service road near Kharadi Bypass. SI Madhav is investigating; the cause and circumstances of death remain under investigation.'})

MATCH (i:Investigator {id: 'inv_001'}), (c:Case {id: 'case_001'}) CREATE (i)-[:INVESTIGATES {role: 'lead_investigator', since: '2026-10-10'}]->(c)
MATCH (i:Investigator {id: 'inv_002'}), (c:Case {id: 'case_002'}) CREATE (i)-[:INVESTIGATES {role: 'lead_investigator', since: '2026-10-15'}]->(c)

//create people involved in case 1
CREATE (:Person {id: 'GUID1', uid: 'UID-MH-2001-0041', caseId: 'case_001', name: 'Amit Shah', dob: '1986-04-10', gender: 'male', address: 'Flat 6C, Kalyani Nagar, Pune', occupation: 'Software Manager', role: 'victim', phones: ['+91-9810-111-222']})
CREATE (:Person {id: 'GUID2', uid: 'UID-MH-2002-0088', caseId: 'case_001', name: 'Shalini Mane', dob: '1988-08-25', gender: 'female', address: 'Viman Nagar, Pune', occupation: 'Software Manager', role: 'missing', phones: ['+91-9822-333-444'], notes: 'Co-manager with Amit. Jointly fired Raj. Left for Mahabaleshwar two days before murder. Unreachable. Listed missing.'})
CREATE (:Person {id: 'GUID3', uid: 'UID-MH-2003-0112', caseId: 'case_001', name: 'Raj Kumar', dob: '1990-12-03', gender: 'male', address: 'Hadapsar, Pune', occupation: 'Unemployed, formerly Software Developer', role: 'suspect', phones: ['+91-9833-555-666'], notes: 'Fired jointly by Amit and Shalini. Publicly threatened both on LinkedIn after termination.'})
CREATE (:Person {id: 'GUID4', uid: 'UID-MH-2004-0067', caseId: 'case_001', name: 'Riya Desai', dob: '1992-06-17', gender: 'female', address: 'Koregaon Park, Pune', occupation: 'Software Developer', role: 'witness', phones: ['+91-9844-777-888']})
CREATE (:Person {id: 'GUID5', uid: 'UID-MH-2005-0033', caseId: 'case_001', name: 'Mohan Shinde', dob: '1970-02-28', gender: 'male', address: 'Wadgaon Sheri, Pune', occupation: 'Security Guard', role: 'witness', phones: ['+91-9855-999-000']})

// Link people from case 1 in case 
MATCH (p:Person {id: 'GUID1'}), (c:Case {id: 'case_001'}) CREATE (p)-[:VICTIM_IN]->(c)
MATCH (p:Person {id: 'GUID2'}), (c:Case {id: 'case_001'}) CREATE (p)-[:MISSING_IN]->(c)
MATCH (p:Person {id: 'GUID3'}), (c:Case {id: 'case_001'}) CREATE (p)-[:SUSPECT_IN]->(c)
MATCH (p:Person {id: 'GUID4'}), (c:Case {id: 'case_001'}) CREATE (p)-[:WITNESS_IN]->(c)
MATCH (p:Person {id: 'GUID5'}), (c:Case {id: 'case_001'}) CREATE (p)-[:WITNESS_IN]->(c)

// Link people from case 2 in case 
MATCH (p:Person {id: 'GUID2'}), (c:Case {id: 'case_002'}) CREATE (p)-[:VICTIM_IN]->(c)

// STEP 7: Verify hierarchy (run separately)
// MATCH (d:PoliceDepartment)-[:HAS_STATION]->(s:Organization) OPTIONAL MATCH (i:Investigator)-[:MEMBER_OF]->(s) RETURN d.name AS department, s.name AS station, s.graphName AS stationGraph, i.name AS investigator ORDER BY station
