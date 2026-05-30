// WHY THIS FILE EXISTS: Angular application bootstrap entry point.
// Uses the standalone bootstrapApplication API (Angular 17+).
// Application config (providers, routing) is defined in app.config.ts.
// Do not add business logic here.

import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent, appConfig).catch((err: unknown) => console.error(err));
