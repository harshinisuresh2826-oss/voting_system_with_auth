const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 5000;
const SECRET_KEY = 'online_voting_system_super_secret_key_2026';
const DB_PATH = path.join(__dirname, 'database.json');

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Serve static frontend files directly at root URL
app.use(express.static(path.join(__dirname, '../frontend')));

// Helper functions for file-backed JSON database
function readDB() {
  try {
    if (!fs.existsSync(DB_PATH)) {
      return { candidates: [], users: [], votes: [] };
    }
    const data = fs.readFileSync(DB_PATH, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error('Error reading database:', err);
    return { candidates: [], users: [], votes: [] };
  }
}

function writeDB(data) {
  try {
    fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    console.error('Error writing database:', err);
    return false;
  }
}

// Authentication middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required. Please log in.' });
  }

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Invalid or expired session. Please log in again.' });
    }
    req.user = user;
    next();
  });
}

// Initialize seed data if database is fresh
function initDatabase() {
  const db = readDB();
  let updated = false;

  const adminExists = db.users && db.users.some(u => u.username.toLowerCase() === 'admin');
  if (!adminExists) {
    const salt = bcrypt.genSaltSync(10);
    const hash = bcrypt.hashSync('admin123', salt);
    db.users.push({
      id: 'usr-admin',
      username: 'admin',
      passwordHash: hash,
      role: 'admin',
      hasVoted: false,
      votedCandidateId: null,
      createdAt: new Date().toISOString()
    });
    updated = true;
  }

  if (!db.candidates || db.candidates.length === 0) {
    db.candidates = [
      {
        id: 'cand-1',
        name: 'Sarah Jenkins',
        party: 'Tech & Innovation Party',
        role: 'Chief Tech Officer & Digital Reformer',
        manifesto: 'Empowering youth through AI education, open governance, and tech infrastructure.',
        avatar: 'assets/candidate_1.png',
        votes: 12
      },
      {
        id: 'cand-2',
        name: 'Alex Rivera',
        party: 'Youth & Future Alliance',
        role: 'Community Advocate & Environmentalist',
        manifesto: 'Sustainable smart cities, green energy investment, and youth empowerment initiatives.',
        avatar: 'assets/candidate_2.png',
        votes: 18
      },
      {
        id: 'cand-3',
        name: 'Dr. Elena Rostova',
        party: 'Sustainable Growth Movement',
        role: 'Economic Strategist & Healthcare Leader',
        manifesto: 'Universal healthcare modernization, balanced economic reform, and public transparency.',
        avatar: 'assets/candidate_3.png',
        votes: 15
      }
    ];
    updated = true;
  }

  if (updated) {
    writeDB(db);
  }
}

initDatabase();

// --- REST API ENDPOINTS ---

// 1. POST /api/register - User Registration
app.post('/api/register', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password || username.trim().length < 3 || password.trim().length < 4) {
      return res.status(400).json({
        success: false,
        message: 'Username must be at least 3 characters and password at least 4 characters long.'
      });
    }

    const cleanUsername = username.trim();
    const db = readDB();

    const existingUser = db.users.find(u => u.username.toLowerCase() === cleanUsername.toLowerCase());
    if (existingUser) {
      return res.status(400).json({ success: false, message: 'Username is already registered. Please login.' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const newUser = {
      id: 'usr-' + Date.now() + '-' + Math.floor(Math.random() * 1000),
      username: cleanUsername,
      passwordHash,
      role: 'voter',
      hasVoted: false,
      votedCandidateId: null,
      createdAt: new Date().toISOString()
    };

    db.users.push(newUser);
    writeDB(db);

    return res.status(201).json({
      success: true,
      message: 'Account created successfully! Please log in to cast your vote.',
      user: {
        id: newUser.id,
        username: newUser.username,
        role: newUser.role
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error during registration.' });
  }
});

// 2. POST /api/login - User & Admin Login
app.post('/api/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ success: false, message: 'Please provide both username and password.' });
    }

    const cleanUsername = username.trim();
    const db = readDB();

    let user = db.users.find(u => u.username.toLowerCase() === cleanUsername.toLowerCase());

    if (cleanUsername.toLowerCase() === 'admin' && password === 'admin123') {
      if (!user) {
        user = {
          id: 'usr-admin',
          username: 'admin',
          role: 'admin',
          hasVoted: false,
          votedCandidateId: null
        };
      }
    } else {
      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid username or password.' });
      }

      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        return res.status(401).json({ success: false, message: 'Invalid username or password.' });
      }
    }

    const tokenPayload = {
      id: user.id,
      username: user.username,
      role: user.role
    };

    const token = jwt.sign(tokenPayload, SECRET_KEY, { expiresIn: '24h' });

    return res.json({
      success: true,
      message: `Welcome back, ${user.username}!`,
      token,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        hasVoted: user.hasVoted || false,
        votedCandidateId: user.votedCandidateId || null
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({ success: false, message: 'Internal server error during login.' });
  }
});

// 3. GET /api/candidates - Retrieve candidate list
app.get('/api/candidates', (req, res) => {
  try {
    const db = readDB();
    const candidates = (db.candidates || []).map(c => ({
      id: c.id,
      name: c.name,
      party: c.party,
      role: c.role,
      manifesto: c.manifesto,
      avatar: c.avatar,
      votes: c.votes || 0
    }));

    return res.json({
      success: true,
      candidates
    });
  } catch (error) {
    console.error('Fetch candidates error:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch candidate list.' });
  }
});

// 4. POST /api/vote - Submit a vote
app.post('/api/vote', authenticateToken, (req, res) => {
  try {
    const { candidateId } = req.body;
    const userId = req.user.id;

    if (!candidateId) {
      return res.status(400).json({ success: false, message: 'Candidate selection is required.' });
    }

    const db = readDB();
    const userIndex = db.users.findIndex(u => u.id === userId);

    if (userIndex === -1) {
      return res.status(404).json({ success: false, message: 'User account not found.' });
    }

    const user = db.users[userIndex];

    if (user.hasVoted) {
      return res.status(400).json({
        success: false,
        message: 'Vote rejected! You have already cast your vote in this election.'
      });
    }

    const candidate = db.candidates.find(c => c.id === candidateId);
    if (!candidate) {
      return res.status(404).json({ success: false, message: 'Selected candidate does not exist.' });
    }

    candidate.votes = (candidate.votes || 0) + 1;
    user.hasVoted = true;
    user.votedCandidateId = candidateId;

    const newVoteRecord = {
      id: 'vote-' + Date.now(),
      userId: user.id,
      username: user.username,
      candidateId: candidate.id,
      candidateName: candidate.name,
      timestamp: new Date().toISOString()
    };

    if (!db.votes) db.votes = [];
    db.votes.push(newVoteRecord);

    writeDB(db);

    return res.json({
      success: true,
      message: 'Your vote has been securely recorded!',
      votedCandidate: {
        id: candidate.id,
        name: candidate.name,
        party: candidate.party,
        avatar: candidate.avatar
      },
      user: {
        id: user.id,
        username: user.username,
        hasVoted: true,
        votedCandidateId: candidate.id
      }
    });
  } catch (error) {
    console.error('Vote submission error:', error);
    return res.status(500).json({ success: false, message: 'Failed to record vote.' });
  }
});

// 5. GET /api/user/status - Check voter status
app.get('/api/user/status', authenticateToken, (req, res) => {
  try {
    const db = readDB();
    const user = db.users.find(u => u.id === req.user.id);

    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    return res.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        hasVoted: user.hasVoted || false,
        votedCandidateId: user.votedCandidateId || null
      }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Error checking status.' });
  }
});

// 6. GET /api/admin/dashboard - Fetch live election stats
app.get('/api/admin/dashboard', authenticateToken, (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Access denied. Admin privileges required.' });
    }

    const db = readDB();
    const totalUsers = (db.users || []).length;
    const candidates = db.candidates || [];
    
    const totalVotes = candidates.reduce((sum, c) => sum + (c.votes || 0), 0);

    let leadingCandidate = null;
    let maxVotes = -1;

    candidates.forEach(c => {
      if (c.votes > maxVotes) {
        maxVotes = c.votes;
        leadingCandidate = c;
      }
    });

    const candidatesWithPercentages = candidates.map(c => {
      const percentage = totalVotes > 0 ? ((c.votes / totalVotes) * 100).toFixed(1) : '0.0';
      return {
        ...c,
        percentage: parseFloat(percentage)
      };
    });

    const recentVotes = (db.votes || []).slice(-10).reverse();

    return res.json({
      success: true,
      stats: {
        totalUsers,
        totalVotes,
        leadingCandidate: leadingCandidate ? {
          id: leadingCandidate.id,
          name: leadingCandidate.name,
          party: leadingCandidate.party,
          avatar: leadingCandidate.avatar,
          votes: leadingCandidate.votes,
          percentage: totalVotes > 0 ? ((leadingCandidate.votes / totalVotes) * 100).toFixed(1) : '0.0'
        } : null,
        candidates: candidatesWithPercentages,
        recentVotes
      }
    });
  } catch (error) {
    console.error('Admin dashboard error:', error);
    return res.status(500).json({ success: false, message: 'Failed to fetch admin stats.' });
  }
});

// 7. POST /api/admin/reset - Reset election data
app.post('/api/admin/reset', authenticateToken, (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin privileges required.' });
    }

    const db = readDB();
    db.candidates.forEach(c => { c.votes = 0; });
    db.users.forEach(u => {
      u.hasVoted = false;
      u.votedCandidateId = null;
    });
    db.votes = [];

    writeDB(db);

    return res.json({ success: true, message: 'Election data reset successfully!' });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Reset failed.' });
  }
});

// Catch-all route to serve SPA frontend
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../frontend/index.html'));
});

// Start express server
app.listen(PORT, () => {
  console.log(`=================================================`);
  console.log(`🚀 Online Voting System running at: http://localhost:${PORT}`);
  console.log(`=================================================`);
});
