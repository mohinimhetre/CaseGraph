import { Component, ElementRef, Input, ViewChild, inject, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService } from '../services/chat.service'; // Adjust path as needed

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chat.component.html',
  styleUrls: ['./chat.component.css']
})
export class ChatComponent {
  private chatService = inject(ChatService);
  @Input() tenant = '';

  // Expose the messages signal from your service to the template
  public messages = this.chatService.messages;
  public userMessage = signal<string>('');

  @ViewChild('scrollContainer') private scrollContainer!: ElementRef;

  constructor() {
    // Automatically scroll to the bottom whenever a new message arrives
    effect(() => {
      if (this.messages().length) {
        setTimeout(() => this.scrollToBottom(), 50);
      }
    });
  }

  public sendMessage() {
    const text = this.userMessage().trim();
    if (!text) return;

    // Optional: Immediately show user's message locally before SignalR confirmation
    this.chatService.sendMessage(text, this.tenant);
    this.userMessage.set(''); // Clear input
  }

  private scrollToBottom() {
    try {
      this.scrollContainer.nativeElement.scrollTop =
        this.scrollContainer.nativeElement.scrollHeight;
    } catch (err) {}
  }
}
