using Microsoft.Agents.AI;
using Microsoft.Extensions.AI;
using ModelContextProtocol.Client;

namespace BusinessLayer
{
    public class AgentOrchestrator
    {
        private readonly McpClient _mcpClient;
        private readonly OllamaChatClient _llmClient;

        public AgentOrchestrator(McpClient mcpClient, OllamaChatClient llmClient)
        {
            _mcpClient = mcpClient;
            _llmClient = llmClient;
        }

        public async Task<string> RunInvestigatorAgent(string message, string tenant, string caseId)
        {
            var mcpTools = await _mcpClient.ListToolsAsync();

            // Convert IList<McpClientTool> to IList<AITool>
            var tools = mcpTools.Cast<AITool>().ToList();

            AIAgent agent = _llmClient.AsAIAgent(
                instructions: "Use the available tools to answer questions about the graph data. You are responsible for " +
                                $"choosing tool and extracting entities from the user query and pass it as an argument to the tool. Do this for tenant {tenant} and only for caseId {caseId}. Always pass this exact caseId to case-specific tools.",
                tools: tools);

            var response = await agent.RunAsync(message);

            var toolResponse = response.Messages.Where(x => x.Role.Value == "tool").FirstOrDefault();

            if (toolResponse != null)
            {
                var content = toolResponse.Contents[0] as FunctionResultContent;

                var agent1 = _llmClient.AsAIAgent(
                instructions: "You are responsible for correlate things.");
                var response1 = await agent1.RunAsync(content?.Result.ToString());

                return response1.Text;
            }

            return response.Text;
        }
    }
}
