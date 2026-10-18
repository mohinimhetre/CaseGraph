using NFalkorDB;
using System.Text;

namespace DataLayer
{
    public class Repository
    {
        private readonly FalkorDB _falkorDb;

        public Repository(FalkorDB falkorDb)
        {
            _falkorDb = falkorDb;
        }

        public async Task<string> GetRelationships(string tenant, string source, string target, string caseId)
        {
            var graph = _falkorDb.SelectGraph(tenant);

            var validationResultSource = IfEntityExists(tenant, caseId, source);
            var validationResultTarget = IfEntityExists(tenant, caseId, target);
            if (validationResultSource && !validationResultTarget)
            {
                return await FindByName(tenant, caseId, source);
            }
            else if (validationResultTarget && !validationResultSource)
            {
                return await FindByName(tenant, caseId, target);
            }

            // Query the graph for relationships between source and target
            var results = await graph.ReadOnlyQueryAsync("MATCH (r:Person), (a:Person) WHERE toLower(r.name) CONTAINS '" + source.ToLower() + "'  AND toLower(a.name) CONTAINS '" + target.ToLower() + 
                                            "' MATCH path = (r)-[*1..3]-(a)  WITH path ORDER BY length(path) ASC LIMIT 3  WITH path, range(0, length(path)-1) AS indices  " +
                                            "UNWIND indices AS i  WITH path, relationships(path)[i] AS rel  " +
                                            "RETURN   length(path) AS depth,  " +
                                            "        [n IN nodes(path) | coalesce(n.name, n.id)] AS hops, " +
                                            "        coalesce(startNode(rel).name, startNode(rel).id) AS from, " +
                                            "        type(rel) AS relationship, " +
                                            "        coalesce(endNode(rel).name, endNode(rel).id) AS to, " +
                                            "        coalesce(rel.notes, \"\") AS note");

            var response = new StringBuilder();
            response.AppendLine("Tell the link and also print the table of overview of hop and depth");
            foreach (var row in results)
            {
                var from = row.GetValue<string>("from");
                var to = row.GetValue<string>("to");
                var edge = row.GetValue<string>("relationship");
                var depth = row.GetValue<long>("depth");
                var hop = row.GetValue<object[]>("hops");

                response.AppendLine($"{from} {edge} {to} depth is {depth} hop is {string.Join('-', hop)}");
            }
            return response.ToString();
        }

        public async Task<string> CaseTimeline(string tenant, string caseId)
        {
            var graph = _falkorDb.SelectGraph(tenant);
            // Query the graph for relationships between source and target
            var results = await graph.ReadOnlyQueryAsync("MATCH (e:Event)-[:PART_OF]->(c:Case {id: '" + caseId + "'}) " +
                "                               RETURN e.name AS event, e.timestamp AS time, e.description AS what ORDER BY e.timestamp ASC");

            if(results.Count == 0)
            {
                return "No record found for this in the tenant";
            }

            var response = new StringBuilder();
            foreach (var row in results)
            {
                var eventNode = row.GetValue<string>("event");
                var timeNode = row.GetValue<string>("time");
                var whatNode = row.GetValue<string>("what");
                response.AppendLine($"at {timeNode} {eventNode}, {whatNode}");
            }

            response.AppendLine("Tell this in a story");

            return response.ToString();
        }

        public async Task<string> FindByName(string tenant, string caseId, string name)
        {
            var graph = _falkorDb.SelectGraph(tenant);

            var detailsQuery = $"MATCH (n {{caseId: '{caseId}'}}) WHERE toLower(n.name) CONTAINS '{name.ToLower()}' OR any(label IN labels(n) WHERE toLower(label) CONTAINS '{name.ToLower()}') RETURN properties(n) AS entityDetails, labels(n) AS entityType";

            var connectionsQuery = $"MATCH (n {{caseId: '{caseId}'}})-[r]-(connected) WHERE toLower(n.name) CONTAINS '{name.ToLower()}' RETURN n.name AS entity, type(r) AS relationship, CASE WHEN startNode(r).name = n.name THEN 'outgoing' ELSE 'incoming' END AS direction, connected.name AS connectedTo, labels(connected) AS connectedType, properties(r) AS relationshipDetails";

            var details = await graph.QueryAsync(detailsQuery);
            var connections = await graph.QueryAsync(connectionsQuery);

            if(details.Count ==0 && connections.Count == 0)
            {
                return $"No evidence found related to {name}, create new";
            }
            var response = new StringBuilder();
            foreach (var row in details)
            {
                var entityDetails = row.GetValue<Dictionary<string, object>>("entityDetails");
                var entityType = row.GetValue<object[]>("entityType");

                response.AppendLine(
                    $"Entity details: {string.Join(", ", entityDetails.Select(kv => $"{kv.Key}={kv.Value}"))}; " +
                    $"type: {string.Join(", ", entityType)}");
            }
            return response.ToString();
        }

        public async Task<string> CreateEvidence(string tenant, string caseId, string evidence, string description, string status, string type)
        {
            var graph = _falkorDb.SelectGraph(tenant);

            if(IfEntityExists(tenant, caseId, evidence))
            {
                return await FindByName(tenant, caseId, evidence);
            }

            var evidenceId = Guid.NewGuid().ToString();
            var createEvidenceQuery = "CREATE (e:Evidence {id: '" + evidenceId + "', caseId: '" + caseId + "', name: '" + evidence + "', description: '" + description + "', status: '" + status + "', type: '" + type + "'}) RETURN properties(e) AS evidenceDetails";
            var result = await graph.QueryAsync(createEvidenceQuery);
            if(result.Count > 0)
            {
                // Optionally, you can also create a relationship between the evidence and the case node
                var createRelationshipQuery = "MATCH (e:Evidence {id: '" + evidenceId + "'}), (c:Case {id: '" + caseId + "'}) CREATE (e)-[:COLLECTED_IN]->(c)";
                await graph.QueryAsync(createRelationshipQuery);
            }

            return result.Count > 0 ? $"Evidence created: {string.Join(", ", result.First().GetValue<Dictionary<string, object>>("evidenceDetails").Select(kv => $"{kv.Key}={kv.Value}"))}" : "Failed to create evidence.";
        }

        public async Task<string> ScanCases(string tenant, string caseId)
        {
            var graph = _falkorDb.SelectGraph("department");

            var resultsDetails = await graph.ReadOnlyQueryAsync(@$"MATCH path = (c1:Case {{id: '{caseId}'}})-[r1]-(p:Person)-[r2]-(c2:Case)-[r3]-(i:Investigator)-[r4]-(s:Organization) WHERE c1.id <> c2.id RETURN p.name AS sharedPerson, c2.name AS correlatedCaseName, i.name + ' (' + coalesce(i.rank, 'N/A') + ')' AS correlatedCaseInvestigatorDetails, s.name AS investigatorStation, length(path) AS totalHops, [rel in relationships(path) | type(rel)] AS relationshipDepthDetails");

            var response = new StringBuilder();
            foreach(var row in resultsDetails)
            {
                var sharedPerson = row.GetValue<string>("sharedPerson");
                var correlatedCaseName = row.GetValue<string>("correlatedCaseName");
                var correlatedCaseInvestigatorDetails = row.GetValue<string>("correlatedCaseInvestigatorDetails");
                var investigatorStation = row.GetValue<string>("investigatorStation");
                var totalHops = row.GetValue<long>("totalHops");
                var relationshipDepthDetails = row.GetValue<object[]>("relationshipDepthDetails");
                response.AppendLine($"Shared Person: {sharedPerson}, Correlated Case: {correlatedCaseName}, Investigator Details: {correlatedCaseInvestigatorDetails}, Station: {investigatorStation}, Total Hops: {totalHops}, Relationship Depth Details: {string.Join(", ", relationshipDepthDetails)}");
            }

            return response.ToString();
        }

        private bool IfEntityExists(string tenant, string caseId, string input)
        {
            // validate is the given input is a node or edge in the graph for the given caseId, each node will have caseId property so consider only those nodes and edges if they belongs to node that have given caseId
            var graph = _falkorDb.SelectGraph(tenant);

            var nodeResult = graph.ReadOnlyQuery(@"MATCH (n {caseId: '"+caseId+"'}) WHERE toLower(n.name) CONTAINS '"+input.ToLower()+"' OR any(label IN labels(n) WHERE toLower(label) CONTAINS toLower('"+input.ToLower()+"')) RETURN n");
            
            if (nodeResult == null || nodeResult.Count == 0)
            {
                return false;
            }

            return true;
        }
    }
}
