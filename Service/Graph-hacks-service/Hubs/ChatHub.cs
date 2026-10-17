using BusinessLayer;
using Microsoft.AspNetCore.SignalR;

namespace Graph_service.Hubs
{
    public class ChatHub(AgentOrchestrator aIAgent) : Hub
    {
        private readonly AgentOrchestrator _agent = aIAgent;

        // This method can be invoked by the Angular frontend via .invoke('SendMessage', ...)
        public async Task SendMessage(string user, string message, string tenant, string caseId)
        {
            await Clients.All.SendAsync("ReceiveMessage", user, message);

            string agentResponse = await _agent.RunInvestigatorAgent(message, tenant, caseId);
            await Clients.All.SendAsync("ReceiveMessage", "Agent", agentResponse);
        }
    }
}
