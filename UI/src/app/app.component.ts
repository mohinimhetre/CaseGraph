import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ChatComponent } from './chat/chat.component';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, ChatComponent, FormsModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  readonly tenants = ['shivajinagar_ps', 'kharadi_ps'];
  selectedTenant = '';
  investigationStarted = false;

  startInvestigation(): void {
    if (!this.selectedTenant) {
      return;
    }

    this.investigationStarted = true;
  }
}
