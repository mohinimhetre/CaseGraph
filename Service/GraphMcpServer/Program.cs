using DataLayer;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly();

var falkorDb = new NFalkorDB.FalkorDB("localhost:6379");

builder.Services.AddTransient(_ => falkorDb);

builder.Services.AddTransient<Repository>();

var app = builder.Build();

app.MapMcp();

app.Run();