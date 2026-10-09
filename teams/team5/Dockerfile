FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# The app is the package `teams.team5` (see apps.py and the core's router
# convention), so it must live at /app/teams/team5 with /app on PYTHONPATH.
ENV PYTHONPATH=/app
RUN mkdir -p /app/teams/team5 && touch /app/teams/__init__.py
WORKDIR /app/teams/team5

RUN apt-get update && \
	apt-get install -y gcc libpq-dev && \
	rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

EXPOSE 8000

ENTRYPOINT ["sh", "-c", "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn config.wsgi:application -b 0.0.0.0:8000"]
