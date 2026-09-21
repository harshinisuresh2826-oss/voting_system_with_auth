# 🗳️ VotePulse - Full-Stack Online Voting System

VotePulse is a complete, modern Full-Stack Online Voting System featuring a **Node.js + Express REST API Backend** with persistent storage, and an interactive **Single Page Application (SPA) Frontend** designed with glassmorphism UI, real-time analytics, and tamper-proof voting logic.

---

## 📁 Project Structure

```
voting-system/
├── backend/
│   ├── server.js          # Express REST API server (Auth, Candidates, Voting, Admin APIs)
│   ├── database.json      # Persistent file-backed DB store (Users, Candidates, Votes)
│   └── package.json       # Backend dependencies (express, cors, body-parser, bcryptjs, jsonwebtoken)
├── frontend/
│   ├── index.html         # HTML5 layout containing 6 modular SPA screens
│   ├── style.css          # Glassmorphism design system, dark mode CSS, animations
│   ├── app.js             # SPA client router, API service, state management & DOM renderer
│   └── assets/            # High-aesthetic candidate avatars and hero ballot graphics
└── README.md              # Setup & Execution Guide
```

---

## ⚡ Quick Start & Setup Guide

### 1. Start the Express Backend Server

Open your terminal in VS Code:

```bash
cd backend
npm install
npm start
```

The Express API server will start on **`http://localhost:5000`**.

### 2. Launch the Frontend Application

You can launch the frontend application in any of the following ways:
- **Directly**: Open [`frontend/index.html`](file:///c:/online%20voting/frontend/index.html) in your browser.
- **VS Code Live Server**: Right-click `frontend/index.html` and click **"Open with Live Server"**.

---

## 🔑 Demo Account Credentials

| Account Role | Username | Password | Access Rights |
| :--- | :--- | :--- | :--- |
| **System Admin** | `admin` | `admin123` | Full Admin Dashboard, Live Results, Vote Reset |
| **Demo Voter** | `demovoter1` | `voter123` | Cast vote on official ballot, view vote receipt |
| **New User** | *Any registered user* | *Created password* | Registered voter account |

---

## 🖥️ UI Screens Included

1. **Home Screen (`#home`)**: Hero title, voting features, ballot graphic, quick navigation.
2. **Register Screen (`#register`)**: Form with password validation and account creation.
3. **Login Screen (`#login`)**: Authentication with quick demo fill shortcuts.
4. **Choose Candidate Screen (`#vote`)**: Protected voter interface, candidate cards, platform manifestos, radio card checkmark selection.
5. **Vote Success Screen (`#success`)**: Green checkmark confirmation, cryptographic vote receipt hash, and timestamp.
6. **Admin Dashboard (`#admin`)**: Dark blue sidebar, live KPIs (Total Voters, Total Votes, Winner), candidate tally progress bars, and recent audit logs table.

---

## 🌐 REST API Endpoints

- `POST /api/register` — Register a new voter account
- `POST /api/login` — Authenticate user or admin & receive session token
- `GET /api/candidates` — Fetch active candidates list and metadata
- `POST /api/vote` — Submit vote for candidate ID (validates token & duplicate prevention)
- `GET /api/user/status` — Returns current user's voting status
- `GET /api/admin/dashboard` — Fetch live admin statistics & election tallies
- `POST /api/admin/reset` — Reset election data for re-testing

---

## 🛡️ Security & Integrity Features

- **Duplicate Vote Prevention**: Permanently locks voting once a user submits a vote.
- **Password Hashing**: Passwords stored securely using `bcryptjs`.
- **JWT Authorization**: Bearer token authentication for protected vote & admin routes.
