using BusinessLayer;
using Graph_service.Hubs;

var builder = WebApplication.CreateBuilder(args);

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
