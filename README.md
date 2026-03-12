# Kanban Board

A production-grade, full-stack project management platform inspired by Trello — built from scratch with a microservices architecture, asynchronous task processing, and containerized infrastructure.

**Live demo:** [fake-trello-phi.vercel.app](https://fake-trello-phi.vercel.app) 

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                        Traefik                          │
│              (Reverse Proxy / Load Balancer)            │
└──────────┬─────────────────────────┬────────────────────┘
           │                         │
    ┌──────▼──────┐           ┌──────▼──────┐
    │   FastAPI   │           │   React.js  │
    │  (Backend)  │           │  (Frontend) │
    └──────┬──────┘           └─────────────┘
           │
    ┌──────▼──────┐     ┌─────────────┐
    │  PostgreSQL │     │    Redis     │
    │  (Database) │     │ (Broker/Cache)│
    └─────────────┘     └──────┬──────┘
                               │
                        ┌──────▼──────┐
                        │   Celery    │
                        │  (Workers)  │
                        └─────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | FastAPI, SQLAlchemy, Pydantic |
| Frontend | React.js, TypeScript |
| Mobile | Flutter (Dart) |
| Task Queue | Celery + Redis |
| Reverse Proxy | Traefik |
| Database | PostgreSQL |
| Containerization | Docker, Docker Compose |
| Testing | Pytest, Locust |

---

## Key Features

- **Board & Card Management** — Create boards, lists, and cards with drag-and-drop support
- **Real-time Updates** — Asynchronous background task processing via Celery workers
- **Microservices Architecture** — Services communicate through Traefik reverse proxy with automatic service discovery
- **Load Balancing** — Traefik handles SSL termination and distributes traffic across services
- **Performance Tested** — API endpoints validated under concurrent load using Locust
- **Cross-platform** — Web app (React) + Mobile app (Flutter)

---

## What I Built & Why

This project started as a way to understand how production-grade platforms like Trello actually work under the hood — not just the UI, but the infrastructure that makes them reliable at scale.

**Interesting engineering decisions:**

- **Celery + Redis for async tasks:** Instead of blocking API responses on long-running operations (email notifications, heavy DB writes), these are offloaded to Celery workers. Redis acts as the message broker.
- **Traefik over Nginx:** Traefik's dynamic configuration and Docker-native service discovery made it the right choice for a containerized microservices setup.
- **Locust load testing:** Identified and resolved a bottleneck in the card ordering endpoint that degraded under concurrent writes.

---

## Getting Started

### Prerequisites

- Docker & Docker Compose
- Node.js (for frontend development)
- Python 3.11+

### Run with Docker Compose

```bash
git clone https://github.com/EyupKeremBas7/kanban-board.git
cd kanban-board

# Start all services
docker compose up -d

# Backend API: http://localhost:8000
# Frontend:    http://localhost:5173
# Traefik Dashboard: http://localhost:8080
```

### Run Tests

```bash
# Unit & integration tests
cd backend
pytest

# Load testing
locust -f tests/locustfile.py --host=http://localhost:8000
```

---

## Project Structure

```
kanban-board/
├── backend/          # FastAPI application
│   ├── app/
│   │   ├── api/      # Route handlers
│   │   ├── models/   # SQLAlchemy models
│   │   ├── schemas/  # Pydantic schemas
│   │   └── tasks/    # Celery tasks
│   └── tests/
├── frontend/         # React.js application
├── mobile/           # Flutter mobile app
├── docker-compose.yml
└── docker-compose.traefik.yml
```

---

## Author

**Eyüp Kerem Baş** — [GitHub](https://github.com/EyupKeremBas7) · [LinkedIn](https://www.linkedin.com/in/eyup-kerem-bas-a83976295/)
