using DataLayer;
using ModelContextProtocol.Server;
using System.ComponentModel;

namespace GraphMcpServer.Tools;

[McpServerToolType]
public sealed class CaseGraphTools
{
    private readonly Repository _repository;

    public CaseGraphTools(Repository repository)
    {
        _repository = repository;
    }

    [McpServerTool, Description("Finds the relationship between source and destination.")]
    public string FindRelationship(string tenant, string source, string destination, string caseId)
    {
        return _repository.GetRelationships(tenant, source, destination);
    }

    [McpServerTool, Description("Gets the timeline of events for the specified case.")]
    public string CaseTimeline(string tenant, string caseId)
    {
        return _repository.CaseTimeline(tenant, caseId);
    }
}
