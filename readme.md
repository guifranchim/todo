# 📝 Todo List - Fullstack App (Frontend + Backend)

A fullstack task management app, built with a React frontend and a Go backend, with automated deployment to Google Kubernetes Engine (GKE).

---

## 🚀 Running Locally

### 🔧 Prerequisites
- Docker
- Node.js (v18+)
- Kubernetes (for local testing — optional: minikube/kind)

---

### 📦 Backend

```bash
cd backend
cp .env.example .env     # Set your local environment variables
docker compose up --build
