# Control de Uso del Móvil - Starter Project

Estructura:
- backend/ : Django REST skeleton (sqlite ready for dev).
- mobile/  : Flutter starter app (login + dashboard + API client).

Instrucciones rápidas:
- Backend (dev): cd backend && python -m venv venv && source venv/bin/activate && pip install -r requirements.txt && python manage.py migrate && python manage.py createsuperuser && python manage.py runserver
- Mobile: cd mobile && flutter pub get && flutter run

Este paquete es un punto de partida. Funcionalidades nativas (UsageStats, AccessibilityService) requieren implementación en Android nativo.
