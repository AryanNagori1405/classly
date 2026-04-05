# Classly – Classroom Lecture Sharing Platform

Full-stack application (Node.js backend + Flutter frontend) for sharing classroom lectures with advanced collaboration features.

---

## Features

| Feature | Description |
|---------|-------------|
| 🔐 UID / RegId Auth | Login with University ID or Registration Number + OTP (no email/password) |
| 🎥 Video Lectures | Teachers upload lectures; auto-deleted after 7 days |
| ⏱️ Timestamp Doubts | Students ask questions at specific video timestamps |
| 📝 Anonymous Feedback | Students send anonymous suggestions to teachers; admin can see real sender |
| 👥 Communities | Students create/join discussion communities |
| 📥 Downloads | Videos are downloadable for offline viewing |
| 🔖 Bookmarks | Save lectures for quick access |
| 📋 Notes/Docs | Teachers attach PDF/DOCX documents to lectures |
| 👨‍💼 Admin Panel | Admin sees all feedback with sender info, manages users |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Node.js + Express |
| Database | PostgreSQL |
| Auth | JWT + OTP |
| Frontend | Flutter (Dart) |
| Storage | File URLs (cloud-agnostic) |
| Scheduler | node-schedule (7-day cleanup) |

---

## Quick Start

### 1. Database setup

```bash
psql -U postgres -c "CREATE DATABASE classly_db;"
psql -U postgres -d classly_db -f backend/database-setup.sql
```

### 2. Backend

```bash
cd backend
cp .env.example .env        # fill in DB credentials and JWT_SECRET
npm install
npm start                   # runs on http://localhost:5000
```

### 3. Flutter frontend

```bash
cd frontend
cp .env.example .env        # optional – set API_URL
flutter pub get
flutter run
```

### 4. Docker (all-in-one)

```bash
cp backend/.env.example backend/.env   # fill in at least JWT_SECRET
docker compose up --build
```

The API is available at `http://localhost:5000` and PostgreSQL at port `5432`.

---

## API Overview

### Authentication (no email/password)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/verify-uid` | POST | Send UID or reg_id → receive OTP |
| `/api/auth/verify-otp` | POST | Submit OTP → receive JWT |
| `/api/auth/refresh-token` | POST | Refresh JWT |
| `/api/auth/logout` | POST | Logout |
| `/api/auth/register` | POST | Pre-register user (admin) |

### Lectures / Videos

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/videos` | GET | List videos (with search/filter) |
| `/api/videos` | POST | Upload lecture (teacher) |
| `/api/videos/:id` | GET | Video detail |
| `/api/videos/:id` | PATCH | Update lecture |
| `/api/videos/:id/download` | POST | Record download |
| `/api/videos/:id/upvote` | POST | Upvote/recommend |

### Timestamp Doubts

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/timestamps/video/:id/timestamps` | GET | List doubts for video |
| `/api/timestamps/video/:id/timestamps` | POST | Add doubt at timestamp |
| `/api/timestamps/:id/resolve` | PATCH | Teacher marks resolved |
| `/api/timestamps/:id/comments` | POST | Reply to doubt |
| `/api/timestamps/video/:id/faq` | GET | Auto-compiled FAQ |

### Communities

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/communities` | GET | Browse communities |
| `/api/communities` | POST | Create community |
| `/api/communities/:id/join` | POST | Join |
| `/api/communities/:id/leave` | POST | Leave |
| `/api/communities/:id/posts` | GET/POST | Posts |
| `/api/communities/:id/posts/:postId/like` | POST | Like post |

### Anonymous Feedback

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/feedback` | POST | Send anonymous feedback |
| `/api/feedback/received` | GET | Teacher views feedback (no sender) |
| `/api/feedback/all` | GET | Admin views all feedback WITH senders |
| `/api/feedback/:id/response` | PUT | Teacher responds |
| `/api/feedback/analytics` | GET | Teacher analytics |

### Bookmarks

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/bookmarks` | GET | User's bookmarks |
| `/api/bookmarks/:videoId` | POST | Bookmark a video |
| `/api/bookmarks/:videoId` | DELETE | Remove bookmark |

---

## Environment Variables

See `backend/.env.example` for all required variables.

```
DB_USER, DB_HOST, DB_NAME, DB_PASSWORD, DB_PORT
JWT_SECRET, JWT_EXPIRES_IN
PORT, NODE_ENV
ALLOWED_ORIGINS           # CORS – leave empty to allow all
SMTP_*                    # optional for email OTP delivery
```

---

## Project Structure

```
classly/
├── backend/
│   ├── src/
│   │   ├── index.js          # Express app entry point
│   │   ├── config/           # DB connection
│   │   ├── middleware/        # JWT auth middleware
│   │   ├── routes/           # All API routes
│   │   └── jobs/             # 7-day video cleanup job
│   ├── database-setup.sql    # Full PostgreSQL schema
│   ├── .env.example
│   └── Dockerfile
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/           # User, Video, Course models
│   │   ├── providers/        # AuthProvider (UID+OTP flow)
│   │   ├── services/         # ApiService, StorageService
│   │   └── screens/
│   │       ├── auth/         # UIDLoginScreen, OTPVerificationScreen
│   │       ├── home/         # StudentHome, TeacherHome
│   │       ├── video/        # VideoList, VideoDetail (with doubts)
│   │       ├── community/    # CommunityList, CommunityDetail
│   │       ├── feedback/     # FeedbackScreen (anonymous)
│   │       ├── bookmarks/    # BookmarksScreen
│   │       └── admin/        # AdminDashboard
│   └── pubspec.yaml
└── docker-compose.yml
```
