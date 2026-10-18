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
                instructions: @$"Use the available tools to answer questions about the graph data. You are responsible for
                                choosing tool and extracting entities from the user query and pass it as an argument to the tool. Do this for tenant {tenant} and only for caseId {caseId}. 
                                Always pass this exact caseId to case-specific tools. Wherever you have date-time, include time part as well. You should show graph hop, depth and links if available
                                When user ask to find missing link or pattern or something to search in department or correlate this case with other cases in the department then choose department tenant
                                Tool selection rules:
                                    1. If the investigator is ASKING a question about existing 
                                       information → use Get/Find tools
                                    2. If the investigator is REPORTING new information, a new 
                                       finding, or a new observation → use Create/Update tools 
                                       directly. Do not call Find tools first.
                                    3. If the investigator confirms a proposed fact → call 
                                       the appropriate Create tool to write it to the graph.

                                    Keywords that signal a write action:
                                    - ""we found"", ""I found"", ""discovered"", ""collected""
                                    - ""turns out"", ""new development"", ""update""
                                    - ""the witness said"", ""lab confirmed""
                                    - ""add this"", ""record this"", ""note that""",
                tools: tools);

            var response = await agent.RunAsync(message);

            return response.Text;
        }

        public async Task<string> RunMissingLinkAgent(string message, string caseId)
        {
            var mcpTools = await _mcpClient.ListToolsAsync();

            // Convert IList<McpClientTool> to IList<AITool>
            var tools = mcpTools.Cast<AITool>().ToList();
            AIAgent agent = _llmClient.AsAIAgent(
                instructions: @$"Use the available tools to answer questions about the graph data. You are responsible for
                                choosing tool and extracting entities from the user query and pass it as an argument to the tool. Do this for tenant department and only for caseId {caseId}. 
                                Always pass this exact caseId to case-specific tools. Wherever you have date-time, include time part as well. You should show graph hop, depth and links if available.
                                When user ask to find missing link or pattern or something to search in department or correlate this case with other cases in the department",
                tools: tools);
            var response = await agent.RunAsync(message);
            return response.Text;
        }
    }
}
