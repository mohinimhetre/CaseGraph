using BusinessLayer;
using Graph_service.Hubs;
using Microsoft.Extensions.AI;
using ModelContextProtocol.Client;

var builder = WebApplication.CreateBuilder(args);

// 1. MCP Configure the transport channel to talk to your MCP project
// Using StdioClientTransport tells .NET to launch your MCP project as a background process
//var mcpTransport = new StdioClientTransport(new StdioClientTransportOptions
//{
//    Command = "dotnet",
//    Arguments = new[] { "run", "--project", "../GraphMcpCmd" }
//});
var mcpTransport = new HttpClientTransport(
                new HttpClientTransportOptions
                {
                    Endpoint = new Uri("https://localhost:52716")
                });

// 2. MCP Initialize the MCP Client connection
var mcpClient = await McpClient.CreateAsync(mcpTransport);

// 3. MCP Register the discovered database tools into the DI container
builder.Services.AddSingleton(mcpClient);

// 1. Ollama Configure the transport channel to talk to your Ollama project
var chatClient = new OllamaChatClient(
                new Uri("http://localhost:11434"),
                modelId: "llama3.2");

// 2. Ollama Register the chat client into the DI container
builder.Services.AddSingleton(chatClient);

// Add services to the container.
// 1. Add SignalR services
builder.Services.AddSignalR();

// 2. SignalR Configure CORS for Angular (Crucial: Must use AllowCredentials for WebSockets)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AngularClient", policy =>
    {
        policy.WithOrigins("http://localhost:4200") // Angular default URL
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials(); // SignalR requires this
    });
});

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.Services.AddSingleton<AgentOrchestrator>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

// 3. SignalR Use CORS policy
app.UseCors("AngularClient");

// 4. SignalR Map the Hub URL path
app.MapHub<ChatHub>("/chatHub");

app.UseAuthorization();

app.MapControllers();

app.Run();
