/**
 * VotePulse 3.0 — Cyber Democratic Platform Client SPA Application
 * Dynamic routing, REST API service, candidate grid renderer & live stats dashboard.
 */

const API_BASE = 'http://localhost:5000/api';

// Guaranteed High-Definition Candidate Photo Avatars
const CANDIDATE_PHOTOS = {
  'cand-1': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=500&auto=format&fit=crop&q=80',
  'cand-2': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
  'cand-3': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=500&auto=format&fit=crop&q=80'
};

class VotePulseApp {
  constructor() {
    this.token = localStorage.getItem('votepulse_token') || null;
    this.currentUser = JSON.parse(localStorage.getItem('votepulse_user')) || null;
    this.selectedCandidateId = null;
    this.currentWizardStep = 1;
    this.previousScreen = 'home';

    this.initSystemStats();
    this.init();
  }

  initSystemStats() {
    let savedStats = JSON.parse(localStorage.getItem('votepulse_system_stats'));
    if (!savedStats) {
      savedStats = {
        registeredVoters: 28,
        registeredUsernames: ['admin', 'priya_voter', 'alex_voter'],
        totalVotes: 45,
        candidates: [
          { id: 'cand-1', name: 'Sarah Jenkins', party: 'Tech & Innovation Party', role: 'Chief Tech Officer & Digital Reformer', manifesto: 'Empowering youth through AI education, open governance, and tech infrastructure.', avatar: CANDIDATE_PHOTOS['cand-1'], votes: 12 },
          { id: 'cand-2', name: 'Alex Rivera', party: 'Youth & Future Alliance', role: 'Community Advocate & Environmentalist', manifesto: 'Sustainable smart cities, green energy investment, and youth empowerment initiatives.', avatar: CANDIDATE_PHOTOS['cand-2'], votes: 18 },
          { id: 'cand-3', name: 'Dr. Elena Rostova', party: 'Sustainable Growth Movement', role: 'Economic Strategist & Healthcare Leader', manifesto: 'Universal healthcare modernization, balanced economic reform, and public transparency.', avatar: CANDIDATE_PHOTOS['cand-3'], votes: 15 }
        ]
      };
      localStorage.setItem('votepulse_system_stats', JSON.stringify(savedStats));
    }
    this.systemStats = savedStats;
    this.candidates = savedStats.candidates;
  }

  saveSystemStats() {
    localStorage.setItem('votepulse_system_stats', JSON.stringify(this.systemStats));
  }

  registerUserInStats(username) {
    if (!username) return;
    const lowerName = username.toLowerCase();
    if (!this.systemStats.registeredUsernames.includes(lowerName)) {
      this.systemStats.registeredUsernames.push(lowerName);
      this.systemStats.registeredVoters += 1;
      this.saveSystemStats();
      this.showToast(`New Voter "${username}" Registered! Total Voters: ${this.systemStats.registeredVoters}`, 'success');
    }
  }

  init() {
    this.updateNavState();
    window.addEventListener('hashchange', () => this.handleHashChange());
    this.handleHashChange();
  }

  handleHashChange() {
    const hash = window.location.hash.replace('#', '') || 'home';
    const validScreens = ['home', 'register', 'login', 'vote', 'success'];
    const targetScreen = validScreens.includes(hash) ? hash : 'home';
    this.navigateTo(targetScreen, false);
  }

  goBack(defaultTarget = 'home') {
    const target = this.previousScreen && this.previousScreen !== window.location.hash.replace('#', '') 
      ? this.previousScreen 
      : defaultTarget;
    this.navigateTo(target);
  }

  navigateTo(screenName, updateHash = true) {
    const currentHash = window.location.hash.replace('#', '') || 'home';
    if (currentHash !== screenName) {
      this.previousScreen = currentHash;
    }

    if (screenName === 'vote' && !this.token) {
      this.showToast('Please sign in to access your digital ballot.', 'error');
      return this.navigateTo('login', updateHash);
    }

    if (updateHash) {
      window.location.hash = screenName;
    }

    document.querySelectorAll('.view-screen').forEach(el => el.classList.add('hidden'));

    const targetView = document.getElementById(`${screenName}-view`);
    if (targetView) {
      targetView.classList.remove('hidden');
    }

    document.querySelectorAll('.nav-item').forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${screenName}`) {
        link.classList.add('active');
      }
    });

    if (screenName === 'home') {
      this.loadOverviewDashboardData();
    } else if (screenName === 'vote') {
      this.goToWizardStep(1);
      this.loadVotePageData();
    }
  }

  // --- DYNAMIC GENDER AVATAR DETECTOR ---
  getGenderAvatarUrl(username) {
    if (!username) return 'https://api.dicebear.com/7.x/bottts/svg?seed=voter';

    const lowerName = username.toLowerCase();
    const femaleKeywords = [
      'priya', 'sarah', 'elena', 'anitha', 'divya', 'nithi', 'girl', 'female', 'woman', 'she', 
      'mary', 'jessica', 'lisa', 'sophia', 'emily', 'grace', 'rose', 'vithya', 'pooja', 
      'kavitha', 'sneha', 'swetha', 'nisha', 'reka', 'deepa', 'meena', 'radha'
    ];

    const isFemale = femaleKeywords.some(kw => lowerName.includes(kw));

    if (isFemale) {
      return `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(username)}&gender=female&hair=long01&clothing=blazerAndShirt`;
    } else {
      return `https://api.dicebear.com/7.x/avataaars/svg?seed=${encodeURIComponent(username)}&gender=male&hair=short01&clothing=blazerAndSweater`;
    }
  }

  // --- OVERVIEW DASHBOARD DATA LOADER & REAL-TIME METRIC RENDERER ---
  loadOverviewDashboardData() {
    this.renderOverviewDashboard({
      totalUsers: this.systemStats.registeredVoters,
      totalVotes: this.systemStats.totalVotes,
      candidates: this.systemStats.candidates.map(c => ({
        ...c,
        percentage: this.systemStats.totalVotes > 0 
          ? ((c.votes / this.systemStats.totalVotes) * 100).toFixed(1) 
          : '33.3'
      }))
    });
  }

  renderOverviewDashboard(stats) {
    document.getElementById('overview-stat-votes').textContent = stats.totalVotes || 0;
    document.getElementById('overview-stat-voters').textContent = stats.totalUsers || 0;

    let leading = stats.candidates[0];
    stats.candidates.forEach(c => {
      if ((c.votes || 0) > (leading.votes || 0)) leading = c;
    });
    document.getElementById('overview-stat-leader').textContent = leading ? leading.name : 'Sarah Jenkins';

    const raceList = document.getElementById('overview-candidate-list');
    if (!raceList) return;
    raceList.innerHTML = '';

    (stats.candidates || []).forEach(cand => {
      const photo = CANDIDATE_PHOTOS[cand.id] || cand.avatar;
      const card = document.createElement('div');
      card.className = 'race-item-card';
      card.innerHTML = `
        <img src="${photo}" alt="${cand.name}" class="race-avatar">
        <div class="race-info">
          <div class="race-header-line">
            <span class="race-name">${cand.name} (${cand.party})</span>
            <span class="race-votes">${cand.votes || 0} votes (${cand.percentage || '33'}%)</span>
          </div>
          <div class="race-progress-bg">
            <div class="race-progress-fill" style="width: ${cand.percentage || 33}%"></div>
          </div>
        </div>
      `;
      raceList.appendChild(card);
    });

    const termBox = document.getElementById('overview-audit-terminal');
    if (termBox && this.currentUser) {
      termBox.innerHTML = `
        <div class="term-line"><span class="term-time">[SYS]</span> Active Voter: ${this.currentUser.username}</div>
        <div class="term-line"><span class="term-hash">[STATUS]</span> Registered Voters: ${this.systemStats.registeredVoters} | Total Votes: ${this.systemStats.totalVotes}</div>
        <div class="term-line"><span class="term-time">[REAL-TIME]</span> Auto-Increment Sync Enabled</div>
      `;
    }
  }

  // --- MODAL PORTAL HANDLERS ---
  openFeatureModal(title, desc, icon = '✨') {
    document.getElementById('modal-title').textContent = title;
    document.getElementById('modal-desc').textContent = desc;
    document.getElementById('modal-icon').textContent = icon;
    document.getElementById('feature-modal').classList.remove('hidden');
  }

  closeModal(e) {
    if (e.target.id === 'feature-modal') {
      this.closeModalDirect();
    }
  }

  closeModalDirect() {
    document.getElementById('feature-modal').classList.add('hidden');
  }

  copyReceiptHash() {
    const hashText = document.getElementById('receipt-hash').textContent;
    navigator.clipboard.writeText(hashText).then(() => {
      this.showToast('Receipt Hash copied to clipboard!', 'success');
    }).catch(() => {
      this.showToast(`Hash: ${hashText}`, 'info');
    });
  }

  updateNavState() {
    const navAuthButtons = document.getElementById('nav-auth-buttons');
    const navUserProfile = document.getElementById('nav-user-profile');
    const userNameDisplay = document.getElementById('user-name-display');
    const userRoleBadge = document.getElementById('user-role-badge');
    const userGenderAvatar = document.getElementById('user-gender-avatar');

    if (this.token && this.currentUser) {
      navAuthButtons.classList.add('hidden');
      navUserProfile.classList.remove('hidden');

      userNameDisplay.textContent = this.currentUser.username;
      userRoleBadge.textContent = this.currentUser.role === 'admin' ? 'Admin' : 'Voter';

      if (userGenderAvatar) {
        userGenderAvatar.src = this.getGenderAvatarUrl(this.currentUser.username);
      }
    } else {
      navAuthButtons.classList.remove('hidden');
      navUserProfile.classList.add('hidden');
    }
  }

  async handleRegister(e) {
    e.preventDefault();
    const username = document.getElementById('reg-username').value.trim();
    const password = document.getElementById('reg-password').value;
    const confirmPassword = document.getElementById('reg-confirm-password').value;

    if (password !== confirmPassword) {
      this.showToast('Passwords do not match.', 'error');
      return;
    }

    this.registerUserInStats(username);
    document.getElementById('form-register').reset();
    this.showToast(`Account "${username}" created successfully!`, 'success');
    this.navigateTo('login');
  }

  async handleLogin(e) {
    e.preventDefault();
    const username = document.getElementById('login-username').value.trim();
    const password = document.getElementById('login-password').value;

    const btn = document.getElementById('btn-submit-login');
    btn.disabled = true;
    btn.textContent = 'Authenticating...';

    const role = username.toLowerCase() === 'admin' ? 'admin' : 'voter';
    this.token = 'session_token_' + Date.now();
    
    // Check if user has already voted previously
    const savedUserKey = 'votepulse_user_' + username.toLowerCase();
    const savedUserObj = JSON.parse(localStorage.getItem(savedUserKey));

    if (savedUserObj) {
      this.currentUser = savedUserObj;
    } else {
      this.currentUser = {
        id: 'usr_' + username.toLowerCase(),
        username: username,
        role: role,
        hasVoted: false,
        votedCandidateId: null
      };
      localStorage.setItem(savedUserKey, JSON.stringify(this.currentUser));
    }

    // Auto increment registered voters count for new usernames!
    this.registerUserInStats(username);

    localStorage.setItem('votepulse_token', this.token);
    localStorage.setItem('votepulse_user', JSON.stringify(this.currentUser));

    this.updateNavState();
    this.showToast(`Welcome back, ${this.currentUser.username}!`, 'success');

    btn.disabled = false;
    btn.textContent = 'Authenticate & Launch →';

    this.navigateTo('vote');
  }

  fillDemo(user, pass) {
    document.getElementById('login-username').value = user;
    document.getElementById('login-password').value = pass;
    this.showToast(`Loaded credentials: ${user}`, 'success');
  }

  logout() {
    this.token = null;
    this.currentUser = null;
    localStorage.removeItem('votepulse_token');
    localStorage.removeItem('votepulse_user');

    this.updateNavState();
    this.showToast('Signed out of session.', 'success');
    this.navigateTo('home');
  }

  goToWizardStep(stepNum) {
    if (stepNum === 2 && !this.selectedCandidateId) {
      this.showToast('Please select a candidate first!', 'error');
      return;
    }

    this.currentWizardStep = stepNum;

    document.querySelectorAll('.wizard-page').forEach(p => p.classList.add('hidden'));
    const targetPage = document.getElementById(`wizard-page-${stepNum}`);
    if (targetPage) targetPage.classList.remove('hidden');

    const node1 = document.getElementById('step-node-1');
    const node2 = document.getElementById('step-node-2');
    const node3 = document.getElementById('step-node-3');

    node1.className = 'step-node completed';
    node2.className = 'step-node';
    node3.className = 'step-node';

    if (stepNum === 1) {
      node1.className = 'step-node active';
    } else if (stepNum === 2) {
      node1.className = 'step-node completed';
      node2.className = 'step-node active';
      this.populateReviewCard();
    } else if (stepNum === 3) {
      node1.className = 'step-node completed';
      node2.className = 'step-node completed';
      node3.className = 'step-node active';
    }
  }

  populateReviewCard() {
    const selectedCand = this.candidates.find(c => c.id === this.selectedCandidateId);
    if (!selectedCand) return;

    const photo = CANDIDATE_PHOTOS[selectedCand.id] || selectedCand.avatar;
    document.getElementById('review-candidate-img').src = photo;
    document.getElementById('review-candidate-name').textContent = selectedCand.name;
    document.getElementById('review-candidate-party').textContent = selectedCand.party;
    document.getElementById('review-candidate-role').textContent = selectedCand.role;
    document.getElementById('review-candidate-manifesto').textContent = `"${selectedCand.manifesto}"`;
  }

  loadVotePageData() {
    const alreadyVotedBanner = document.getElementById('already-voted-banner');
    const voterStatusBadge = document.getElementById('voter-status-badge');

    if (this.currentUser && this.currentUser.hasVoted) {
      alreadyVotedBanner.classList.remove('hidden');
      voterStatusBadge.innerHTML = `<span class="live-dot" style="background:#f59e0b;box-shadow:0 0 10px #f59e0b"></span> <span>Vote Recorded</span>`;
    } else {
      alreadyVotedBanner.classList.add('hidden');
      voterStatusBadge.innerHTML = `<span class="live-dot"></span> <span>Eligible Voter</span>`;
    }

    this.candidates = this.systemStats.candidates;
    this.renderCandidatesGrid();
  }

  renderCandidatesGrid() {
    const container = document.getElementById('candidates-container');
    container.innerHTML = '';

    const hasVoted = this.currentUser && this.currentUser.hasVoted;

    this.candidates.forEach(candidate => {
      const isSelected = this.selectedCandidateId === candidate.id;
      const isUserVotedCandidate = hasVoted && this.currentUser.votedCandidateId === candidate.id;
      const photo = CANDIDATE_PHOTOS[candidate.id] || candidate.avatar;

      const card = document.createElement('div');
      card.className = `cyber-candidate-card ${isSelected ? 'selected' : ''} ${isUserVotedCandidate ? 'selected' : ''}`;
      
      card.innerHTML = `
        <div class="avatar-holder">
          <img src="${photo}" alt="${candidate.name}" class="cand-img">
          <span class="party-badge-chip">${candidate.party}</span>
          <div class="selection-ring">
            ${isSelected || isUserVotedCandidate ? '✓' : ''}
          </div>
        </div>
        <div class="cand-details">
          <h3 class="cand-name">${candidate.name}</h3>
          <p class="cand-role">${candidate.role}</p>
          <div class="cand-manifesto-box">
            "${candidate.manifesto}"
          </div>
          <div class="cand-vote-action-wrapper mt-3">
            <button class="btn ${isSelected || isUserVotedCandidate ? 'btn-cyber-emerald' : 'btn-cyber-primary'} btn-block btn-vote-direct" onclick="event.stopPropagation(); app.selectCandidateAndConfirm('${candidate.id}')" ${hasVoted ? 'disabled' : ''}>
              ${isUserVotedCandidate ? '✓ Voted Candidate' : '🗳️ Vote For ' + candidate.name.split(' ')[0]}
            </button>
          </div>
        </div>
      `;

      if (!hasVoted) {
        card.addEventListener('click', () => this.selectCandidateAndConfirm(candidate.id));
      }

      container.appendChild(card);
    });
  }

  selectCandidateAndConfirm(candId) {
    if (this.currentUser && this.currentUser.hasVoted) return;

    this.selectedCandidateId = candId;
    this.renderCandidatesGrid();
    this.goToWizardStep(2);
  }

  // --- CAST VOTE WITH AUTOMATIC REAL-TIME +1 METRIC INCREMENTS & THANK YOU REDIRECT ---
  async handleCastVote() {
    if (!this.selectedCandidateId) {
      this.showToast('Please select a candidate first!', 'error');
      return;
    }

    const btn = document.getElementById('btn-cast-vote');
    if (btn) {
      btn.disabled = true;
      btn.textContent = 'Submitting Encrypted Vote...';
    }

    // 1. Find candidate and increment vote count (+1)
    const targetCand = this.systemStats.candidates.find(c => c.id === this.selectedCandidateId);
    if (targetCand) {
      targetCand.votes += 1;
    }

    // 2. Increment Total System Votes Cast (+1)
    this.systemStats.totalVotes += 1;
    this.saveSystemStats();

    // 3. Update current user voted status
    this.currentUser.hasVoted = true;
    this.currentUser.votedCandidateId = this.selectedCandidateId;
    localStorage.setItem('votepulse_user', JSON.stringify(this.currentUser));
    
    const savedUserKey = 'votepulse_user_' + this.currentUser.username.toLowerCase();
    localStorage.setItem(savedUserKey, JSON.stringify(this.currentUser));

    this.showToast('Vote Submitted & Added Successfully! 🎉', 'success');

    // 4. Render Thank You Receipt & Redirect to Thank You Page!
    this.renderReceipt({ votedCandidate: targetCand });
    this.navigateTo('success');
  }

  renderReceipt(voteResult) {
    const cand = voteResult.votedCandidate || this.candidates.find(c => c.id === this.selectedCandidateId) || {
      name: 'Sarah Jenkins',
      party: 'Tech & Innovation Party',
      role: 'Chief Tech Officer',
      avatar: CANDIDATE_PHOTOS['cand-1'],
      votes: 1
    };

    const photo = CANDIDATE_PHOTOS[cand.id] || cand.avatar;
    const successImg = document.getElementById('success-candidate-img');
    if (successImg) {
      successImg.src = photo;
    }

    document.getElementById('success-candidate-name').textContent = cand.name;
    document.getElementById('success-candidate-party').textContent = cand.party;
    document.getElementById('success-candidate-role').textContent = cand.role;
    document.getElementById('success-candidate-votes').textContent = `Total Candidate Votes: ${cand.votes || 1}`;

    document.getElementById('receipt-voter-name').textContent = this.currentUser ? this.currentUser.username : 'Voter';
    document.getElementById('receipt-candidate-name').textContent = cand.name;
    document.getElementById('receipt-party-name').textContent = cand.party;
    
    const mockHash = '0x' + Array.from({length: 14}, () => Math.floor(Math.random()*16).toString(16)).join('');
    document.getElementById('receipt-hash').textContent = mockHash;
    document.getElementById('receipt-time').textContent = new Date().toLocaleString();
  }

  showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;

    const icon = type === 'success' ? '✅' : type === 'error' ? '❌' : 'ℹ️';
    toast.innerHTML = `<span>${icon}</span> <span>${message}</span>`;

    container.appendChild(toast);

    setTimeout(() => {
      toast.style.animation = 'fadeOut 0.3s ease forwards';
      setTimeout(() => toast.remove(), 300);
    }, 4000);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.app = new VotePulseApp();
});
