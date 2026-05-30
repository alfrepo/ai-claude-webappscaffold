// WHY THIS FILE EXISTS: Root application routes.
// All feature routes are lazy-loaded here for performance.
// To add a feature route: add a loadChildren() entry pointing to the feature's routes file.
// Route guards go here — apply AuthGuard to all authenticated routes.

import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    // Redirect to a home page — replace 'home' with your first feature route
    redirectTo: 'home',
  },
  {
    path: 'home',
    // Placeholder: replace with lazy-loaded feature module/component
    loadComponent: () =>
      import('./features/home/home.component').then((m) => m.HomeComponent),
  },
  {
    path: '**',
    // 404 — replace with a proper NotFoundComponent
    redirectTo: 'home',
  },
];
