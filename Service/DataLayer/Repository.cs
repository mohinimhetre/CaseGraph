using NFalkorDB;
using System.Text;
using System.Text.Json;

namespace DataLayer
{
    public class Repository
    {
        public string GetRelationships(string tenant, string source, string target, string? caseId = null)
        {
            var client = new FalkorDB("localhost:6379");
            var graph = client.SelectGraph(tenant);
            // Query the graph for relationships between source and target
            var results = graph.ReadOnlyQuery("MATCH (r:Person), (a:Person) WHERE toLower(r.name) CONTAINS '"+ source.ToLower() +"'   AND toLower(a.name) CONTAINS '"+ target.ToLower() +"' MATCH path = (r)-[*1..3]-(a) WITH path ORDER BY length(path) ASC LIMIT 3 WITH path, range(0, length(path)-1) AS indices UNWIND indices AS i WITH path, relationships(path)[i] AS rel RETURN  length(path) AS depth, [n IN nodes(path) | coalesce(n.name, n.id)] AS hops, coalesce(startNode(rel).name, startNode(rel).id) AS from,  type(rel) AS relationship,   coalesce(endNode(rel).name, endNode(rel).id) AS to");

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

        public string CaseTimeline(string tenant, string caseId)
        {
            var client = new FalkorDB("localhost:6379");
            var graph = client.SelectGraph(tenant);
            // Query the graph for relationships between source and target
            var results = graph.ReadOnlyQuery("MATCH (e:Event)-[:PART_OF]->(c:Case {id: '" + caseId + "'}) RETURN e.name AS event, e.timestamp AS time, e.description AS what ORDER BY e.timestamp ASC");
            var response = new StringBuilder();
            foreach (var row in results)
            {
                var eventNode = row.GetValue<string>("event");
                var timeNode = row.GetValue<string>("time");
                var whatNode = row.GetValue<string>("what");
                response.AppendLine($"at {timeNode} {eventNode}, {whatNode}");
            }
            return response.ToString();
        }
    }
}
