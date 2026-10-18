// STEP 1: Organization not needed if Kalyani Nagar case is already seed
// CREATE (:Organization {id: 'org_001', name: 'Shivajinagar Police Station', type: 'police_station', district: 'Pune'})

// STEP 2: Investigator not needed if Kalyani Nagar case is already seed
// CREATE (:Investigator {id: 'inv_001', name: 'SI Priya Sharma', rank: 'Sub Inspector', badgeNumber: 'MH-PN-SI-4421'})
// MATCH (i:Investigator {id: 'inv_001'}), (o:Organization {id: 'org_001'}) CREATE (i)-[:MEMBER_OF]->(o)

// STEP 3: Case
CREATE (:Case {id: 'case_003', name: 'Koregaon Park Art Heist', type: 'grand_larceny', status: 'open', dateOpened: '2026-10-11', fir: 'FIR-2026-SHV-0499', jurisdiction: 'Shivajinagar', summary: 'Priceless 19th-century painting The Monsoon Horizon stolen from Koregaon Park Art Gallery. Fired technician Kabir Rao suspected due to threat messages and a night sighting.'})
MATCH (i:Investigator {id: 'inv_001'}), (c:Case {id: 'case_003'}) CREATE (i)-[:ASSIGNED_TO {role: 'lead_investigator', since: '2026-10-11'}]->(c)

// STEP 4: Persons
CREATE (:Person {id: 'per_301', uid: 'UID-MH-2009-0881', caseId: 'case_003', name: 'Vikram Joshi', dob: '1978-11-12', gender: 'male', address: 'Kalyani Nagar, Pune', occupation: 'Gallery Curator', role: 'complainant', phones: ['+91-9877-111-000'], notes: 'Discovered the painting missing during morning inspection.'})
CREATE (:Person {id: 'per_302', uid: 'UID-MH-2011-0342', caseId: 'case_003', name: 'Kabir Rao', dob: '1995-03-22', gender: 'male', address: 'Kothrud, Pune', occupation: 'Unemployed, formerly Art Technician', role: 'suspect', phones: ['+91-9877-222-111'], notes: 'Fired by Vikram Joshi for negligence. Sent aggressive WhatsApp messages demanding immediate backpay.'})
CREATE (:Person {id: 'per_303', uid: 'UID-MH-1989-0994', caseId: 'case_003', name: 'Karan Thapa', dob: '1984-07-05', gender: 'male', address: 'Yerwada, Pune', occupation: 'Security Guard', role: 'witness', phones: ['+91-9877-333-222'], notes: 'Manning the back entrance on the night of the theft.'})

// Link persons to case
MATCH (p:Person {id: 'per_301'}), (c:Case {id: 'case_003'}) CREATE (p)-[:WITNESS_IN]->(c)
MATCH (p:Person {id: 'per_302'}), (c:Case {id: 'case_003'}) CREATE (p)-[:SUSPECT_IN]->(c)
MATCH (p:Person {id: 'per_303'}), (c:Case {id: 'case_003'}) CREATE (p)-[:WITNESS_IN]->(c)

// Person to person relationships
MATCH (v:Person {id: 'per_301'}), (k:Person {id: 'per_302'}) CREATE (v)-[:FIRED {at: '2026-10-01', notes: 'Fired Kabir Rao for chronic negligence and mishandling art pieces.'}]->(k)
MATCH (k:Person {id: 'per_302'}), (v:Person {id: 'per_301'}) CREATE (k)-[:THREATENED {at: '2026-10-02', medium: 'WhatsApp', notes: 'Sent aggressive text demands warning that the gallery would pay dearly if dues were delayed.'}]->(v)

// STEP 5: Locations
CREATE (:Location {id: 'loc_301', caseId: 'case_003', name: 'Koregaon Park Art Gallery', type: 'crime_scene', address: 'Lane 5, Koregaon Park, Pune 411001'})
CREATE (:Location {id: 'loc_302', caseId: 'case_003', name: 'Cafe Goodluck', type: 'claimed_alibi_location', address: 'Deccan Gymkhana, Pune 411004', notes: 'Kabir claims he was dining here during the hour of the heist.'})

MATCH (l:Location {id: 'loc_301'}), (c:Case {id: 'case_003'}) CREATE (l)-[:SCENE_OF]->(c)
MATCH (p:Person {id: 'per_302'}), (l:Location {id: 'loc_301'}) CREATE (p)-[:SEEN_AT {at: '2026-10-10T23:15:00', source: 'Guard Karan Thapa', status: 'disputed'}]->(l)

// STEP 6: Events
CREATE (:Event {id: 'evt_301', caseId: 'case_003', name: 'Kabir Rao Fired', timestamp: '2026-10-01T14:00:00', description: 'Curator Vikram Joshi terminates Kabir Raos employment contract.'})
CREATE (:Event {id: 'evt_302', caseId: 'case_003', name: 'WhatsApp Threats', timestamp: '2026-10-02T09:30:00', description: 'Kabir sends multiple aggressive messages to Vikrams personal number.'})
CREATE (:Event {id: 'evt_303', caseId: 'case_003', name: 'Unresolved Guard Sighting', timestamp: '2026-10-10T23:15:00', description: 'Karan Thapa spots a man matching Kabirs height and build entering the storage corridor.'})
CREATE (:Event {id: 'evt_304', caseId: 'case_003', name: 'Painting Stolen', timestamp: '2026-10-10T23:30:00', description: 'Estimated execution window of the theft. Alarm systems were temporarily bypassed.'})
CREATE (:Event {id: 'evt_305', caseId: 'case_003', name: 'Theft Discovered', timestamp: '2026-10-11T09:00:00', description: 'Curator notices the empty frame in Exhibition Hall B during morning initialization.'})
CREATE (:Event {id: 'evt_gap3', caseId: 'case_003', name: 'UNACCOUNTED SECURITY DOWNTIME', timestamp: '2026-10-10T23:00:00', description: 'GAP: Security logs show an unexplained 30-minute system loop override between 23:00 and 23:30.'})

// Link events to case
MATCH (e:Event {id: 'evt_301'}), (c:Case {id: 'case_003'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_302'}), (c:Case {id: 'case_003'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_303'}), (c:Case {id: 'case_003'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_304'}), (c:Case {id: 'case_003'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_305'}), (c:Case {id: 'case_003'}) CREATE (e)-[:PART_OF]->(c)
MATCH (e:Event {id: 'evt_gap3'}), (c:Case {id: 'case_003'}) CREATE (e)-[:PART_OF]->(c)

// Link events to entities
MATCH (e:Event {id: 'evt_301'}), (p:Person {id: 'per_302'}) CREATE (e)-[:INVOLVES {role: 'terminated'}]->(p)
MATCH (e:Event {id: 'evt_301'}), (p:Person {id: 'per_301'}) CREATE (e)-[:INVOLVES {role: 'terminator'}]->(p)
MATCH (e:Event {id: 'evt_302'}), (p:Person {id: 'per_302'}) CREATE (e)-[:INVOLVES {role: 'sender'}]->(p)
MATCH (e:Event {id: 'evt_303'}), (p:Person {id: 'per_302'}) CREATE (e)-[:INVOLVES {role: 'identified_subject'}]->(p)
MATCH (e:Event {id: 'evt_303'}), (p:Person {id: 'per_303'}) CREATE (e)-[:WITNESSED_BY]->(p)
MATCH (e:Event {id: 'evt_304'}), (l:Location {id: 'loc_301'}) CREATE (e)-[:OCCURRED_AT]->(l)
MATCH (e:Event {id: 'evt_gap3'}), (l:Location {id: 'loc_301'}) CREATE (e)-[:REFERS_TO]->(l)

// STEP 7: Statements
CREATE (:Statement {id: 'stm_301', caseId: 'case_003', name: 'Curator Discovery Record', text: 'I arrived at 9 AM and saw the frame of The Monsoon Horizon empty on the floor. Kabir knew the mechanical lock overrides for that gallery hall perfectly.'})
CREATE (:Statement {id: 'stm_302', caseId: 'case_003', name: 'Kabir Rao Alibi Claim', text: 'I was sitting at Cafe Goodluck in Deccan from 10 PM until midnight having dinner. I have not stepped foot near Koregaon Park since I was unfairly fired.'})
CREATE (:Statement {id: 'stm_303', caseId: 'case_003', name: 'Karan Thapa Patrol Log', text: 'A man looking exactly like Kabir bypassed the back lane security gate at 11:15 PM. He was carrying a long, cylindrical drafting tube.'})

MATCH (s:Statement {id: 'stm_301'}), (p:Person {id: 'per_301'}) CREATE (p)-[:GAVE]->(s)
MATCH (s:Statement {id: 'stm_302'}), (p:Person {id: 'per_302'}) CREATE (p)-[:GAVE]->(s)
MATCH (s:Statement {id: 'stm_303'}), (p:Person {id: 'per_303'}) CREATE (p)-[:GAVE]->(s)
MATCH (s:Statement {id: 'stm_301'}), (c:Case {id: 'case_003'}) CREATE (s)-[:RECORDED_IN]->(c)
MATCH (s:Statement {id: 'stm_302'}), (c:Case {id: 'case_003'}) CREATE (s)-[:RECORDED_IN]->(c)
MATCH (s:Statement {id: 'stm_303'}), (c:Case {id: 'case_003'}) CREATE (s)-[:RECORDED_IN]->(c)
MATCH (s1:Statement {id: 'stm_302'}), (s2:Statement {id: 'stm_303'}) CREATE (s1)-[:CONTRADICTS {reason: 'Kabir claims he was in Deccan Gymkhana, but guard Thapa explicitly identifies him at the gallery gate'}]->(s2)

// STEP 8: Evidence
CREATE (:Evidence {id: 'evi_301', caseId: 'case_003', name: 'Bypassed Frame and Screws', type: 'physical', description: 'The outer protective glass and frame left behind. Collected partial toolkit scratches being analyzed for dynamic profile matches.', status: 'at_lab', labRefNo: 'FSL-ART-2026-88'})
CREATE (:Evidence {id: 'evi_302', caseId: 'case_003', name: 'WhatsApp Chat Export', type: 'digital', description: 'Full export logs of threat messages sent from Kabirs phone number to the curator.', status: 'collected'})
CREATE (:Evidence {id: 'evi_303', caseId: 'case_003', name: 'Tampered CCTV Control Log', type: 'digital', description: 'Internal automated network log showing local admin bypass keys were typed into the server room console at 23:02.', status: 'collected'})

MATCH (e:Evidence {id: 'evi_301'}), (c:Case {id: 'case_003'}) CREATE (e)-[:COLLECTED_IN]->(c)
MATCH (e:Evidence {id: 'evi_302'}), (c:Case {id: 'case_003'}) CREATE (e)-[:COLLECTED_IN]->(c)
MATCH (e:Evidence {id: 'evi_303'}), (c:Case {id: 'case_003'}) CREATE (e)-[:COLLECTED_IN]->(c)
MATCH (e:Evidence {id: 'evi_301'}), (l:Location {id: 'loc_301'}) CREATE (e)-[:FOUND_AT]->(l)

// STEP 9: Leads
CREATE (:Lead {id: 'led_301', caseId: 'case_003', name: 'Verify Cafe Goodluck Alibi', description: 'Subpoena CCTV footage from Cafe Goodluck for the night of Oct 10 to confirm or refute Kabirs presence.', priority: 'high', status: 'open'})
CREATE (:Lead {id: 'led_302', caseId: 'case_003', name: 'Trace Stolen Canvas', description: 'Alert regional borders, transit hubs, and private art dealers across Maharashtra regarding the stolen painting.', priority: 'high', status: 'open'})
CREATE (:Lead {id: 'led_303', caseId: 'case_003', name: 'Examine Server Access Keys', description: 'Analyze which specific employee backup profile was cloned or used to override the server console logs during the heist.', priority: 'medium', status: 'open'})

MATCH (l:Lead {id: 'led_301'}), (c:Case {id: 'case_003'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_302'}), (c:Case {id: 'case_003'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_303'}), (c:Case {id: 'case_003'}) CREATE (l)-[:PART_OF]->(c)
MATCH (l:Lead {id: 'led_301'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)
MATCH (l:Lead {id: 'led_302'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)
MATCH (l:Lead {id: 'led_303'}), (o:Organization {id: 'org_001'}) CREATE (l)-[:ASSIGNED_TO]->(o)

// STEP 10: Hypothesis
CREATE (:Hypothesis {id: 'hyp_301', caseId: 'case_003', name: 'Inside Job Disgruntled Employee', text: 'Kabir Rao utilized his technical knowledge of the gallery security system and layout to execute a targeted theft under the cover of a manual server override, seeking alternative compensation.', confidence: 0.75, createdAt: '2026-10-11T16:00:00', status: 'active'})
MATCH (h:Hypothesis {id: 'hyp_301'}), (c:Case {id: 'case_003'}) CREATE (h)-[:ABOUT]->(c)
MATCH (h:Hypothesis {id: 'hyp_301'}), (e:Evidence {id: 'evi_302'}) CREATE (h)-[:SUPPORTED_BY {note: 'WhatsApp records prove economic dispute and hostile intent'}]->(e)
MATCH (h:Hypothesis {id: 'hyp_301'}), (e:Evidence {id: 'evi_303'}) CREATE (h)-[:SUPPORTED_BY {note: 'Bypass parameters required specific technical expertise Kabir possesses'}]->(e)
MATCH (h:Hypothesis {id: 'hyp_301'}), (s:Statement {id: 'stm_302'}) CREATE (h)-[:CONTRADICTED_BY {note: 'Kabir claims he was geographically isolated from the scene'}]->(s)

// STEP 11: Traits
CREATE (:Trait {id: 'trt_301', caseId: 'case_003', name: 'Target: High-Value Fine Art', category: 'stolen_property', value: 'fine_art'})
CREATE (:Trait {id: 'trt_302', caseId: 'case_003', name: 'Motive: Disgruntled Subordinate', category: 'motive_type', value: 'workplace_revenge'})
CREATE (:Trait {id: 'trt_303', caseId: 'case_003', name: 'Method: Cyber-Physical Bypass', category: 'modus_operandi', value: 'security_tampering'})
CREATE (:Trait {id: 'trt_304', caseId: 'case_003', name: 'Location: Commercial Gallery', category: 'location_type', value: 'museum_gallery'})
MATCH (c:Case {id: 'case_003'}), (t:Trait {id: 'trt_301'}) CREATE (c)-[:HAS_TRAIT]->(t)
MATCH (c:Case {id: 'case_003'}), (t:Trait {id: 'trt_302'}) CREATE (c)-[:HAS_TRAIT]->(t)
MATCH (c:Case {id: 'case_003'}), (t:Trait {id: 'trt_303'}) CREATE (c)-[:HAS_TRAIT]->(t)
MATCH (c:Case {id: 'case_003'}), (t:Trait {id: 'trt_304'}) CREATE (c)-[:HAS_TRAIT]->(t)