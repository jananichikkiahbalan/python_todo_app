# Todo App

A simple full-stack Todo application.
**Stack:** Vanilla JS frontend · Python (Flask) backend · MySQL database

---

## Project Structure

```
todo-app/
├── backend/
│   ├── app.py            # Flask API server
│   ├── requirements.txt  # Python dependencies
│   └── schema.sql        # Database setup
└── frontend/
    └── index.html        # Single-file frontend
```

---

## Setup

### 1. Database

```bash
mysql -u root -p < backend/schema.sql
```

This creates the `todo_db` database and the `todos` table.

### 2. Backend

```bash
cd backend
pip install -r requirements.txt
python app.py
```

The API will run on **http://localhost:5000**.

**Environment variables (optional overrides):**

| Variable      | Default     |
|---------------|-------------|
| `DB_HOST`     | `localhost` |
| `DB_USER`     | `root`      |
| `DB_PASSWORD` | *(empty)*   |
| `DB_NAME`     | `todo_db`   |

Set them before running:
```bash
DB_USER=myuser DB_PASSWORD=secret python app.py
```

### 3. Frontend

Just open `frontend/index.html` in a browser — no build step needed.

> If you see CORS errors, make sure the Flask server is running and you're opening the file directly (not from a different server port). Flask-CORS is already enabled for all origins.

---

## API Reference

| Method | Endpoint          | Body                          | Description       |
|--------|-------------------|-------------------------------|-------------------|
| GET    | `/todos`          | —                             | List all todos    |
| POST   | `/todos`          | `{ "title": "..." }`          | Create a todo     |
| PUT    | `/todos/<id>`     | `{ "title"?, "completed"? }`  | Update a todo     |
| DELETE | `/todos/<id>`     | —                             | Delete a todo     |
