import { TestBed } from '@angular/core/testing';
import { AppComponent } from './app.component';
import { ChatService } from './services/chat.service';
import { signal } from '@angular/core';

describe('AppComponent', () => {
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AppComponent],
      providers: [{
        provide: ChatService,
        useValue: { messages: signal([]), sendMessage: jasmine.createSpy('sendMessage') }
      }]
    }).compileComponents();
  });

  it('should create the app', () => {
    const fixture = TestBed.createComponent(AppComponent);
    const app = fixture.componentInstance;
    expect(app).toBeTruthy();
  });

  it('should show the tenant selector and app banner on startup', () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.detectChanges();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('.app-banner h1')?.textContent).toContain('Case graph');
    expect(compiled.querySelector('label')?.textContent).toBe('Tenant');
    expect(compiled.querySelectorAll('select option').length).toBe(3);
    expect(compiled.querySelector('button')?.textContent).toContain('Lets investigate');
  });

  it('should start chat with the selected tenant', () => {
    const fixture = TestBed.createComponent(AppComponent);
    fixture.componentInstance.selectedTenant = 'kharadi_ps';
    fixture.componentInstance.startInvestigation();
    fixture.detectChanges();

    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('.tenant-name')?.textContent).toContain('kharadi_ps');
  });
});
