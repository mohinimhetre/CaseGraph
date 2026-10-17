import { ComponentFixture, TestBed } from '@angular/core/testing';
import { signal } from '@angular/core';

import { ChatComponent } from './chat.component';
import { ChatService } from '../services/chat.service';

describe('ChatComponent', () => {
  let component: ChatComponent;
  let fixture: ComponentFixture<ChatComponent>;
  let sendMessage: jasmine.Spy;

  beforeEach(async () => {
    sendMessage = jasmine.createSpy('sendMessage');
    await TestBed.configureTestingModule({
      imports: [ChatComponent],
      providers: [{
        provide: ChatService,
        useValue: { messages: signal([]), sendMessage }
      }]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ChatComponent);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('tenant', 'shivajinagar_ps');
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should send the selected tenant with the chat message', () => {
    component.userMessage.set('Find related cases');
    component.sendMessage();

    expect(sendMessage).toHaveBeenCalledWith('Find related cases', 'shivajinagar_ps');
  });
});
