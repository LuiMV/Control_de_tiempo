# Backend - Django REST skeleton

This is a minimal skeleton for the backend API.

Run locally (development):
1. python -m venv venv
2. source venv/bin/activate
3. pip install -r requirements.txt
4. python manage.py migrate
5. python manage.py createsuperuser
6. python manage.py runserver

Or use docker-compose (requires docker):
    docker-compose up --build

Note: settings.py uses sqlite3 for quick start.
