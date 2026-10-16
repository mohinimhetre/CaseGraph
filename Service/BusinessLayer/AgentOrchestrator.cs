using Microsoft.Agents.AI;
using Microsoft.Extensions.AI;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BusinessLayer
{
    public class AgentOrchestrator
    {
        public async Task<string> RunAgent(string message)
        {
            // 1. Point to your local Ollama instance and specify the model
            var chatClient = new OllamaChatClient(
                new Uri("http://localhost:11434"),
                modelId: "llama3.2"
            );

            // 2. Initialize the agent using the local Chat Client
            AIAgent agent = chatClient.AsAIAgent(
                instructions: "You are a agent responsible to get data from Graph DB."
            );

            // 3. Execute the agent locally
            var response = await agent.RunAsync(message);
            Console.WriteLine(response);

            return response.Text;
        }
    }
}
