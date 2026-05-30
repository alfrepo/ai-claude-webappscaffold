// WHY THIS FILE EXISTS: HTTP interceptor that prepends the API base URL
// and adds the Authorization header to all API requests.
// The base URL comes from window.__env.API_BASE_URL (runtime injection).
// To add new headers (e.g., X-Correlation-ID): add them in the clone() call.
// To add auth token handling: inject AuthService and get the token here.

import { Injectable } from '@angular/core';
import {
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest,
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

/**
 * Intercepts all HTTP requests to prepend the API base URL.
 * Only intercepts requests that start with '/api' to avoid intercepting
 * i18n translation file requests or other asset loads.
 */
@Injectable()
export class ApiInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    // Only intercept API calls — leave translation file requests, etc. alone
    if (!req.url.startsWith('/api')) {
      return next.handle(req);
    }

    const apiReq = req.clone({
      url: `${environment.API_BASE_URL}${req.url}`,
      // Authorization header will be set here when auth is implemented:
      // setHeaders: { Authorization: `Bearer ${this.authService.getToken()}` }
    });

    return next.handle(apiReq);
  }
}
