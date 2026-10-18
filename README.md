# CaseGraph

CaseGraph is a graph-powered investigative assistant that helps users explore case relationships, timeline events, related entities, and department-wide patterns using a conversational AI interface.

The project combines:
- An Angular frontend for tenant selection and chat-driven investigation
- An ASP.NET Core SignalR backend that orchestrates AI investigation requests
- A graph data layer built on FalkorDB
- An MCP server exposing case graph tools to the AI agent
- An Ollama-based LLM for natural-language reasoning

## Features

- Tenant-based investigation flows
- Natural-language case questions through a chat interface
- Relationship tracing between people/entities
- Case timeline reconstruction
- Pattern and correlation analysis across department cases
- Evidence creation and graph-based case enrichment

## Architecture

- Frontend: `UI/`
- Backend service: `Service/Graph-hacks-service/`
- MCP graph tool server: `Service/GraphMcpServer/`
- Data access: `Service/DataLayer/`
- Business logic: `Service/BusinessLayer/`

## Tech Stack

- Angular 19
- ASP.NET Core 9
- SignalR
- FalkorDB
- Model Context Protocol (MCP)
- Ollama + Llama 3.1

## Prerequisites

Before running the app, make sure you have:

- Node.js 18+ and npm
- .NET 9 SDK
- Docker (recommended for FalkorDB)
- Ollama installed and running locally

## Quick Start

### 1) Start FalkorDB

If you do not already have a FalkorDB instance, start one with Docker:

```bash
docker run -d --name casegraph-falkordb -p 6379:6379 falkordb/falkordb
```

The application expects FalkorDB to be available at `localhost:6379`.

### 2) Start Ollama and load the model

Make sure Ollama is running locally, then pull the model used by the backend:

```bash
ollama pull llama3.1
```

If needed, start the Ollama daemon:

```bash
ollama serve
```

### 3) Start the MCP graph server

```bash
cd Service/GraphMcpServer
dotnet run
```

This project exposes graph tools on:
- `https://localhost:52716`

### 4) Start the backend service

```bash
cd Service/Graph-hacks-service
dotnet run
```

This service listens on:
- `https://localhost:7295`
- `http://localhost:5008`

The app is configured to connect to the frontend over CORS and the SignalR hub at `/chatHub`.

### 5) Install and run the Angular UI

```bash
cd UI
npm install
npm start
```

Then open:

```text
http://localhost:4200
```

## Usage

1. Open the app in the browser.
2. Select a tenant from the available list such as `shivajinagar_ps`, `kharadi_ps`, or `Test`.
3. Start the investigation session.
4. Ask questions in the chat such as:
   - "Find the relationship between X and Y"
   - "Show the timeline for case 123"
   - "Correlate this case with other related cases"
   - "Create evidence for this lead"

The agent will route requests through the configured graph tools and the local LLM to derive relationships and explain findings.

## Project Structure

```text
CaseGraph/
├── Service/
│   ├── BusinessLayer/
│   ├── DataLayer/
│   ├── Graph-hacks-service/
│   └── GraphMcpServer/
├── UI/
│   ├── src/
│   ├── package.json
│   └── README.md
└── Service.sln
```

## Notes

- The SignalR frontend connection is configured for `https://localhost:7295/chatHub`.
- The MCP server endpoint is expected to remain at `https://localhost:52716` unless you change the URL in `Service/Graph-hacks-service/Program.cs`.
- The local Ollama model name is configured as `llama3.1` in the backend.

## Troubleshooting

### Backend cannot connect to MCP server

Ensure the `GraphMcpServer` project is running before starting the API service, and confirm the URL matches the configured endpoint.

### SignalR connection issues

Check that the backend is running and that the frontend is accessing the correct hub URL from the browser.

### GPT/LLM not responding

Verify Ollama is running locally and that the `llama3.1` model has been pulled successfully.

### Graph data not found

Confirm the FalkorDB container is up and listening on port `6379`.

## License

This project is currently maintained as an internal graph-driven investigation tool. Add your preferred license here before public distribution.
