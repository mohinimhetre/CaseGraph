using DataLayer;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddMcpServer()
    .WithHttpTransport()
    .WithToolsFromAssembly();

builder.Services.AddTransient<Repository>();

var app = builder.Build();

app.MapMcp();

app.Run();