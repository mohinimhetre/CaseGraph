import { Injectable, signal } from '@angular/core';
import * as signalR from '@microsoft/signalr';

@Injectable({ providedIn: 'root' })
export class ChatService {
  private hubConnection!: signalR.HubConnection;
  // Use Angular Signals for fast UI updates
  public messages = signal<{sender: string, text: string}[]>([]);

  constructor() {
    this.hubConnection = new signalR.HubConnectionBuilder()
      .withUrl('https://localhost:7295/chatHub') // Your .NET API Hub URL
      .withAutomaticReconnect()
      .build();

    this.hubConnection.start().catch(err => console.error(err));

    // Listen for messages pushed from .NET backend
    this.hubConnection.on('ReceiveMessage', (sender: string, text: string) => {
      this.messages.update(prev => [...prev, { sender, text }]);
    });
  }

  public sendMessage(message: string, tenant: string, caseId: string) {
    this.hubConnection.invoke('SendMessage', 'User', message, tenant, caseId);
  }
}
