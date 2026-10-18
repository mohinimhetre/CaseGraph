using DataLayer;
using Microsoft.AspNetCore.Identity;
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
    public async Task<string> FindRelationship(string tenant, string source, string destination, string caseId)
    {
        return await _repository.GetRelationships(tenant, source, destination, caseId);
    }

    [McpServerTool, Description("Gets the timeline of events for the specified case.")]
    public async Task<string> CaseTimeline(string tenant, string caseId)
    {
        return await _repository.CaseTimeline(tenant, caseId);
    }

    [McpServerTool, Description("Finds entities by name or the details of the entity or person within a specific case.")]
    public async Task<string> FindByName(string tenant, string caseId, string name)
    {
        return await _repository.FindByName(tenant, caseId, name);
    }

    [McpServerTool, Description("Creates a new evidence record when the user reports, discovers, finds, collects, recovers, or submits new evidence related to the case.")]
    public async Task<string> CreateEvidence(string tenant, string caseId, string evidence, string description, string status, string type)
    {
        return await _repository.CreateEvidence(tenant, caseId, evidence, description, status, type);
    }

    [McpServerTool, Description("Finds missing links by correlating given case in other cases in the department.")]
    public async Task<string> GetCasePattern(string tenant, string caseId)
    {
        return await _repository.ScanCases(tenant, caseId);
    }
}
