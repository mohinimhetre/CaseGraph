// CaseGraph - Seed v2: Kalyani Nagar Murder
// Graph: station:shivajinagar_ps
// Changes from v1:
//   - caseId: 'case_001' added to every node except Organization and Investigator
//   - uid field added to all Person nodes (government/system unique identifier)
//   - Updated verify queries with direction-aware path query
// All queries single-line. Run each line separately in FalkorDB Browser.

// STEP 0: Clear (run alone first)
MATCH (n) DETACH DELETE n

// STEP 1: Organization (no caseId - org exists independently of any case)
CREATE (:Organization {id: 'org_001', name: 'Shivajinagar Police Station', type: 'police_station', district: 'Pune'})

// STEP 2: Investigator (no caseId - investigator exists independently)
CREATE (:Investigator {id: 'inv_001', name: 'SI Priya Sharma', rank: 'Sub Inspector', badgeNumber: 'MH-PN-SI-4421'})
MATCH (i:Investigator {id: 'inv_001'}), (o:Organization {id: 'org_001'}) CREATE (i)-[:MEMBER_OF]->(o)

// STEP 3: Case
CREATE (:Case {id: 'case_001', name: 'Kalyani Nagar Murder', type: 'homicide', status: 'open', dateOpened: '2026-10-10', fir: 'FIR-2026-SHV-0401', jurisdiction: 'Shivajinagar', summary: 'Amit Shah found dead in his flat. Cause of death poisoning. Co-manager Shalini Mane who also fired the suspect is now missing.'})
MATCH (i:Investigator {id: 'inv_001'}), (c:Case {id: 'case_001'}) CREATE (i)-[:ASSIGNED_TO {role: 'lead_investigator', since: '2026-10-10'}]->(c)
MATCH (o:Organization {id: 'org_001'}), (c:Case {id: 'case_001'}) CREATE (o)-[:HANDLES]->(c)

// STEP 4: Persons (uid = government/Aadhaar style unique identifier, caseId scopes to this case)
CREATE (:Person {id: 'per_001', uid: 'UID-MH-2001-0041', caseId: 'case_001', name: 'Amit Shah', dob: '1986-04-10', gender: 'male', address: 'Flat 6C, Kalyani Nagar, Pune', occupation: 'Software Manager', role: 'victim', phones: ['+91-9810-111-222']})
CREATE (:Person {id: 'per_002', uid: 'UID-MH-2002-0088', caseId: 'case_001', name: 'Shalini Mane', dob: '1988-08-25', gender: 'female', address: 'Viman Nagar, Pune', occupation: 'Software Manager', role: 'missing', phones: ['+91-9822-333-444'], notes: 'Co-manager with Amit. Jointly fired Raj. Left for Mahabaleshwar two days before murder. Unreachable. Listed missing.'})
CREATE (:Person {id: 'per_003', uid: 'UID-MH-2003-0112', caseId: 'case_001', name: 'Raj Kumar', dob: '1990-12-03', gender: 'male', address: 'Hadapsar, Pune', occupation: 'Unemployed, formerly Software Developer', role: 'suspect', phones: ['+91-9833-555-666'], notes: 'Fired jointly by Amit and Shalini. Publicly threatened both on LinkedIn after termination.'})
CREATE (:Person {id: 'per_004', uid: 'UID-MH-2004-0067', caseId: 'case_001', name: 'Riya Desai', dob: '1992-06-17', gender: 'female', address: 'Koregaon Park, Pune', occupation: 'Software Developer', role: 'witness', phones: ['+91-9844-777-888']})
CREATE (:Person {id: 'per_005', uid: 'UID-MH-2005-0033', caseId: 'case_001', name: 'Mohan Shinde', dob: '1970-02-28', gender: 'male', address: 'Wadgaon Sheri, Pune', occupation: 'Security Guard', role: 'witness', phones: ['+91-9855-999-000']})

// Link persons to case
MATCH (p:Person {id: 'per_001'}), (c:Case {id: 'case_001'}) CREATE (p)-[:VICTIM_IN]->(c)
MATCH (p:Person {id: 'per_002'}), (c:Case {id: 'case_001'}) CREATE (p)-[:MISSING_IN]->(c)
MATCH (p:Person {id: 'per_003'}), (c:Case {id: 'case_001'}) CREATE (p)-[:SUSPECT_IN]->(c)
MATCH (p:Person {id: 'per_004'}), (c:Case {id: 'case_001'}) CREATE (p)-[:WITNESS_IN]->(c)
MATCH (p:Person {id: 'per_005'}), (c:Case {id: 'case_001'}) CREATE (p)-[:WITNESS_IN]->(c)

// Person to person relationships
MATCH (a:Person {id: 'per_001'}), (s:Person {id: 'per_002'}) CREATE (a)-[:WORKS_WITH {role: 'co_manager', notes: 'Both were managers in the same software team'}]->(s)
MATCH (a:Person {id: 'per_001'}), (r:Person {id: 'per_003'}) CREATE (a)-[:FIRED {at: '2026-09-20', notes: 'Jointly fired Raj Kumar along with Shalini Mane for poor performance'}]->(r)
MATCH (s:Person {id: 'per_002'}), (r:Person {id: 'per_003'}) CREATE (s)-[:FIRED {at: '2026-09-20', notes: 'Jointly fired Raj Kumar along with Amit Shah for poor performance'}]->(r)
MATCH (r:Person {id: 'per_003'}), (a:Person {id: 'per_001'}) CREATE (r)-[:THREATENED {at: '2026-09-21', medium: 'LinkedIn', notes: 'Raj posted public threat on LinkedIn saying both managers would regret this decision'}]->(a)
MATCH (r:Person {id: 'per_003'}), (s:Person {id: 'per_002'}) CREATE (r)-[:THREATENED {at: '2026-09-21', medium: 'LinkedIn', notes: 'Same LinkedIn post threatened both Amit and Shalini'}]->(s)
MATCH (r:Person {id: 'per_003'}), (a:Person {id: 'per_001'}) CREATE (r)-[:CONFRONTED {at: '2026-10-03T18:30:00', location: 'Office car park', notes: 'Raj confronted Amit aggressively in the office car park. Witnessed by Riya Desai.'}]->(a)

// STEP 5: Locations
CREATE (:Location {id: 'loc_001', caseId: 'case_001', name: 'Amit Shah Flat Kalyani Nagar', type: 'crime_scene', address: 'Flat 6C, Kalyani Nagar, Pune 411006'})
CREATE (:Location {id: 'loc_002', caseId: 'case_001', name: 'Mahabaleshwar', type: 'last_known_location', address: 'Mahabaleshwar, Satara District, Maharashtra', notes: 'Shalini told her husband she was going here for a solo trip. Has not been reachable since.'})

MATCH (l:Location {id: 'loc_001'}), (c:Case {id: 'case_001'}) CREATE (l)-[:SCENE_OF]->(c)
MATCH (p:Person {id: 'per_001'}), (l:Location {id: 'loc_001'}) CREATE (p)-[:RESIDES_AT]->(l)
MATCH (p:Person {id: 'per_002'}), (l:Location {id: 'loc_002'}) CREATE (p)-[:LAST_SEEN_AT {at: '2026-10-08', notes: 'Left for solo trip. Husband dropped her at Pune station.'}]->(l)
MATCH (p:Person {id: 'per_003'}), (l:Location {id: 'loc_001'}) CREATE (p)-[:SEEN_AT {at: '2026-10-10T19:00:00', source: 'Security guard Mohan Shinde', status: 'confirmed'}]->(l)

// STEP 6: Events
CREATE (:Event {id: 'evt_001', caseId: 'case_001', name: 'Raj Kumar Fired', timestamp: '2026-09-20T11:00:00', description: 'Raj Kumar fired jointly by Amit Shah and Shalini Mane for poor performance.'})
CREATE (:Event {id: 'evt_002', caseId: 'case_001', name: 'LinkedIn Threat by Raj', timestamp: '2026-09-21T09:00:00', description: 'Raj Kumar posted public LinkedIn threat saying both Amit and Shalini would regret their decision.'})
CREATE (:Event {id: 'evt_003', caseId: 'case_001', name: 'Car Park Confrontation', timestamp: '2026-10-03T18:30:00', description: 'Raj confronted Amit aggressively in office car park. Riya Desai witnessed the incident.'})
CREATE (:Event {id: 'evt_004', caseId: 'case_001', name: 'Shalini Leaves for Mahabaleshwar', timestamp: '2026-10-08T08:00:00', description: 'Shalini Mane left for a solo trip to Mahabaleshwar. Husband dropped her at Pune station. Last known contact.'})
CREATE (:Event {id: 'evt_005', caseId: 'case_001', name: 'Raj Seen Entering Building', timestamp: '2026-10-10T19:00:00', description: 'Security guard Mohan Shinde saw Raj Kumar entering Amits building at 7 PM. Raj denies this.'})
CREATE (:Event {id: 'evt_006', caseId: 'case_001', name: 'Murder of Amit Shah', timestamp: '2026-10-10T20:00:00', description: 'Estimated time of death. Amit Shah poisoned. Poisoned coffee cup found on his desk.'})
CREATE (:Event {id: 'evt_007', caseId: 'case_001', name: 'Body Discovered', timestamp: '2026-10-11T08:00:00', description: 'Amits body discovered by building housekeeping staff during morning rounds.'})
CREATE (:Event {id: 'evt_gap', caseId: 'case_001', name: 'UNACCOUNTED WINDOW 19:00-20:00', timestamp: '2026-10-10T19:00:00', description: 'GAP: Raj seen entering building at 7 PM. Death at 8 PM. No account of what happened in this one hour window inside the flat.'})

// Link events to case
MATCH (e:Event {id: 'evt_001'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_002'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_003'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_004'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_005'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_006'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_007'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_gap'}), (c:Case {id: 'case_001'}) CREATE (e)-[:PART_OF]->(c)

// Link events to persons
MATCH (e:Event {id: 'evt_001'}), (p:Person {id: 'per_003'}) CREATE (e)-[:INVOLVES {role: 'fired'}]->(p)
MATCH (e:Event {id: 'evt_001'}), (p:Person {id: 'per_001'}) CREATE (e)-[:INVOLVES {role: 'fired_by'}]->(p)
MATCH (e:Event {id: 'evt_001'}), (p:Person {id: 'per_002'}) CREATE (e)-[:INVOLVES {role: 'fired_by'}]->(p)
MATCH (e:Event {id: 'evt_002'}), (p:Person {id: 'per_003'}) CREATE (e)-[:INVOLVES {role: 'posted_threat'}]->(p)
MATCH (e:Event {id: 'evt_003'}), (p:Person {id: 'per_003'}) CREATE (e)-[:INVOLVES {role: 'aggressor'}]->(p)
MATCH (e:Event {id: 'evt_003'}), (p:Person {id: 'per_001'}) CREATE (e)-[:INVOLVES {role: 'confronted'}]->(p)
MATCH (e:Event {id: 'evt_003'}), (p:Person {id: 'per_004'}) CREATE (e)-[:WITNESSED_BY]->(p)
MATCH (e:Event {id: 'evt_004'}), (p:Person {id: 'per_002'}) CREATE (e)-[:INVOLVES {role: 'departed'}]->(p)
MATCH (e:Event {id: 'evt_005'}), (p:Person {id: 'per_003'}) CREATE (e)-[:INVOLVES {role: 'seen_entering'}]->(p)
MATCH (e:Event {id: 'evt_005'}), (p:Person {id: 'per_005'}) CREATE (e)-[:WITNESSED_BY]->(p)
MATCH (e:Event {id: 'evt_006'}), (p:Person {id: 'per_001'}) CREATE (e)-[:VICTIM_OF]->(p)
MATCH (e:Event {id: 'evt_006'}), (l:Location {id: 'loc_001'}) CREATE (e)-[:OCCURRED_AT]->(l)
MATCH (e:Event {id: 'evt_005'}), (l:Location {id: 'loc_001'}) CREATE (e)-[:OCCURRED_AT]->(l)
MATCH (e:Event {id: 'evt_gap'}), (l:Location {id: 'loc_001'}) CREATE (e)-[:REFERS_TO]->(l)

// STEP 7: Statements
CREATE (:Statement {id: 'stm_001', caseId: 'case_001', name: 'Riya Desai Statement', text: 'Raj Kumar had become very aggressive after being fired. He confronted Amit in the car park on 3rd October and was shouting. Amit looked shaken. Raj said they would both pay for what they did to him meaning Amit and Shalini.'})
CREATE (:Statement {id: 'stm_002', caseId: 'case_001', name: 'Raj Kumar Denial', text: 'I was never at Amits building on 10th October. The guard is lying or confused. I was at home alone that evening. I had no reason to go there.'})
CREATE (:Statement {id: 'stm_003', caseId: 'case_001', name: 'Mohan Shinde Sighting', text: 'I clearly saw Raj Kumar entering the building at 7 PM on 10th October. I know his face because he had visited Amit sir before when he was still working at the company. He did not sign the visitor register and walked in quickly.'})

MATCH (s:Statement {id: 'stm_001'}), (p:Person {id: 'per_004'}) CREATE (p)-[:GAVE]->(s)
MATCH (s:Statement {id: 'stm_002'}), (p:Person {id: 'per_003'}) CREATE (p)-[:GAVE]->(s)
MATCH (s:Statement {id: 'stm_003'}), (p:Person {id: 'per_005'}) CREATE (p)-[:GAVE]->(s)
MATCH (s:Statement {id: 'stm_001'}), (c:Case {id: 'case_001'}) CREATE (s)-[:RECORDED_IN]->(c)
MATCH (s:Statement {id: 'stm_002'}), (c:Case {id: 'case_001'}) CREATE (s)-[:RECORDED_IN]->(c)
MATCH (s:Statement {id: 'stm_003'}), (c:Case {id: 'case_001'}) CREATE (s)-[:RECORDED_IN]->(c)
MATCH (s1:Statement {id: 'stm_002'}), (s2:Statement {id: 'stm_003'}) CREATE (s1)-[:CONTRADICTS {reason: 'Raj denies being at the building but Mohan clearly identifies him entering at 7 PM'}]->(s2)

// STEP 8: Evidence
CREATE (:Evidence {id: 'evi_001', caseId: 'case_001', name: 'Poisoned Coffee Cup', type: 'physical', description: 'Coffee cup found on Amits desk. Lab confirmed traces of potassium cyanide. Cup has partial fingerprints being analyzed.', status: 'at_lab', labRefNo: 'PFSL-2026-2201'})
CREATE (:Evidence {id: 'evi_002', caseId: 'case_001', name: 'LinkedIn Threat Screenshot', type: 'digital', description: 'Screenshot of Raj Kumars LinkedIn post dated 21st September threatening both Amit Shah and Shalini Mane.', status: 'collected'})
CREATE (:Evidence {id: 'evi_003', caseId: 'case_001', name: 'Building Visitor Log', type: 'documentary', description: 'Visitor log for Amits building on 10th October. Raj Kumar did not sign in but guard confirms he entered without registering.', status: 'collected'})

MATCH (e:Evidence {id: 'evi_001'}), (c:Case {id: 'case_001'}) CREATE (e)-[:COLLECTED_IN]->(c)
MATCH (e:Evidence {id: 'evi_002'}), (c:Case {id: 'case_001'}) CREATE (e)-[:COLLECTED_IN]->(c)
MATCH (e:Evidence {id: 'evi_003'}), (c:Case {id: 'case_001'}) CREATE (e)-[:COLLECTED_IN]->(c)
MATCH (e:Evidence {id: 'evi_001'}), (l:Location {id: 'loc_001'}) CREATE (e)-[:FOUND_AT]->(l)

// STEP 9: Leads
CREATE (:Lead {id: 'led_001', caseId: 'case_001', name: 'Locate Shalini Mane', description: 'Shalini Mane is missing since 8th October. Contact Mahabaleshwar hotels and local police. Check if she boarded the train. Husband to provide more details.', priority: 'high', status: 'open'})
CREATE (:Lead {id: 'led_002', caseId: 'case_001', name: 'Fingerprint Analysis Coffee Cup', description: 'Get fingerprint analysis results from PFSL for coffee cup evi_001. Match against Raj Kumars prints.', priority: 'high', status: 'open'})
CREATE (:Lead {id: 'led_003', caseId: 'case_001', name: 'Trace Poison Source', description: 'Identify source of potassium cyanide. Check if Raj Kumar has access to chemicals through any prior work or contacts.', priority: 'high', status: 'open'})
CREATE (:Lead {id: 'led_004', caseId: 'case_001', name: 'Verify Raj Alibi', description: 'Raj claims he was home alone on evening of 10th October. Check CCTV near his Hadapsar address. Check phone location data.', priority: 'medium', status: 'open'})

MATCH (l:Lead {id: 'led_001'}), (c:Case {id: 'case_001'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_002'}), (c:Case {id: 'case_001'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_003'}), (c:Case {id: 'case_001'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_004'}), (c:Case {id: 'case_001'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_001'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)
MATCH (l:Lead {id: 'led_002'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)
MATCH (l:Lead {id: 'led_003'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)
MATCH (l:Lead {id: 'led_004'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)

// STEP 10: Hypothesis
CREATE (:Hypothesis {id: 'hyp_001', caseId: 'case_001', name: 'Raj Kumar Revenge Theory', text: 'Raj Kumar entered Amits flat on the evening of 10th October, poisoned his coffee in revenge for being fired, and left before the poison took effect. Shalini Mane may be his next target.', confidence: 0.70, createdAt: '2026-10-11T10:00:00', status: 'active'})
MATCH (h:Hypothesis {id: 'hyp_001'}), (c:Case {id: 'case_001'}) CREATE (h)-[:ABOUT]->(c)
MATCH (h:Hypothesis {id: 'hyp_001'}), (e:Evidence {id: 'evi_002'}) CREATE (h)-[:SUPPORTED_BY {note: 'LinkedIn threat names both Amit and Shalini as targets'}]->(e)
MATCH (h:Hypothesis {id: 'hyp_001'}), (e:Evidence {id: 'evi_003'}) CREATE (h)-[:SUPPORTED_BY {note: 'Raj entered building without signing visitor log'}]->(e)
MATCH (h:Hypothesis {id: 'hyp_001'}), (s:Statement {id: 'stm_002'}) CREATE (h)-[:CONTRADICTED_BY {note: 'Raj denies being at the building'}]->(s)

// STEP 11: Traits
CREATE (:Trait {id: 'trt_001', caseId: 'case_001', name: 'Weapon: Poison', category: 'weapon', value: 'poison'})
CREATE (:Trait {id: 'trt_002', caseId: 'case_001', name: 'Victim: Male Professional', category: 'victim_profile', value: 'male_professional'})
CREATE (:Trait {id: 'trt_003', caseId: 'case_001', name: 'Motive: Workplace Revenge', category: 'motive_type', value: 'workplace_revenge'})
CREATE (:Trait {id: 'trt_004', caseId: 'case_001', name: 'Location: Residential', category: 'location_type', value: 'residential'})

MATCH (c:Case {id: 'case_001'}), (t:Trait {id: 'trt_001'}) CREATE (c)-[:HAS_TRAIT]->(t)
MATCH (c:Case {id: 'case_001'}), (t:Trait {id: 'trt_002'}) CREATE (c)-[:HAS_TRAIT]->(t)
MATCH (c:Case {id: 'case_001'}), (t:Trait {id: 'trt_003'}) CREATE (c)-[:HAS_TRAIT]->(t)
MATCH (c:Case {id: 'case_001'}), (t:Trait {id: 'trt_004'}) CREATE (c)-[:HAS_TRAIT]->(t)

// STEP 12: Verify queries (uncomment and run one at a time)
// Count all nodes
// MATCH (n) RETURN labels(n) AS type, count(n) AS total ORDER BY total DESC
// Full graph
// MATCH (n) RETURN n
// Timeline
// MATCH (e:Event {caseId: 'case_001'})-[:PART_OF]->(c:Case {id: 'case_001'}) RETURN e.name AS event, e.timestamp AS time, e.description AS what ORDER BY e.timestamp ASC
// How is Raj linked to Amit (with direction and details)
// MATCH path = (r:Person {name: 'Raj Kumar'})-[*1..3]-(a:Person {name: 'Amit Shah'}) WITH path, relationships(path) AS rels, nodes(path) AS nds UNWIND range(0, length(path)-1) AS i RETURN coalesce(nds[i].name, nds[i].id) AS from, type(rels[i]) AS relationship, coalesce(nds[i+1].name, nds[i+1].id) AS to, properties(rels[i]) AS details ORDER BY length(path) ASC LIMIT 10
// Why is Shalini at risk (with direction and details)
// MATCH path = (r:Person {name: 'Raj Kumar'})-[*1..3]-(s:Person {name: 'Shalini Mane'}) WITH path, relationships(path) AS rels, nodes(path) AS nds UNWIND range(0, length(path)-1) AS i RETURN coalesce(nds[i].name, nds[i].id) AS from, type(rels[i]) AS relationship, coalesce(nds[i+1].name, nds[i+1].id) AS to, properties(rels[i]) AS details ORDER BY length(path) ASC LIMIT 10
// Statement contradiction
// MATCH (s1:Statement {caseId: 'case_001'})-[r:CONTRADICTS]->(s2:Statement) RETURN s1.name AS statement, s2.name AS contradicts, r.reason AS reason
// Gap
// MATCH (e:Event {caseId: 'case_001'}) WHERE e.name STARTS WITH 'UNACCOUNTED' RETURN e.name AS gap, e.description AS detail
// GetCaseContext (load all persons and roles)
// MATCH (p:Person {caseId: 'case_001'}) RETURN p.name, p.role, p.uid
