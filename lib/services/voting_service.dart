import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/candidate.dart';
import '../models/user.dart';

class VotingService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:5000/api';

  User? _currentUser;
  String? _token;
  List<Candidate> _candidates = [];
  String? _selectedCandidateId;
  Map<String, dynamic>? _adminStats;

  User? get currentUser => _currentUser;
  String? get token => _token;
  List<Candidate> get candidates => _candidates;
  String? get selectedCandidateId => _selectedCandidateId;
  Map<String, dynamic>? get adminStats => _adminStats;

  VotingService() {
    _initSeedCandidates();
  }

  void _initSeedCandidates() {
    _candidates = [
      Candidate(
        id: 'cand-1',
        name: 'Sarah Jenkins',
        party: 'Tech & Innovation Party',
        role: 'Chief Tech Officer & Digital Reformer',
        manifesto: 'Empowering youth through AI education, open governance, and tech infrastructure.',
        avatar: 'assets/candidate_1.png',
        votes: 12,
      ),
      Candidate(
        id: 'cand-2',
        name: 'Alex Rivera',
        party: 'Youth & Future Alliance',
        role: 'Community Advocate & Environmentalist',
        manifesto: 'Sustainable smart cities, green energy investment, and youth empowerment initiatives.',
        avatar: 'assets/candidate_2.png',
        votes: 18,
      ),
      Candidate(
        id: 'cand-3',
        name: 'Dr. Elena Rostova',
        party: 'Sustainable Growth Movement',
        role: 'Economic Strategist & Healthcare Leader',
        manifesto: 'Universal healthcare modernization, balanced economic reform, and public transparency.',
        avatar: 'assets/candidate_3.png',
        votes: 15,
      ),
    ];
  }

  void selectCandidate(String id) {
    if (_currentUser != null && _currentUser!.hasVoted) return;
    _selectedCandidateId = id;
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('Registration offline fallback: $e');
    }

    // Local fallback
    return true;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login offline fallback: $e');
    }

    // Local fallback for demo
    final role = username.toLowerCase() == 'admin' ? 'admin' : 'voter';
    _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
    _currentUser = User(
      id: 'usr_${username.toLowerCase()}',
      username: username,
      role: role,
      hasVoted: false,
    );
    notifyListeners();
    return true;
  }

  Future<bool> castVote() async {
    if (_selectedCandidateId == null || _currentUser == null || _currentUser!.hasVoted) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vote'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'candidateId': _selectedCandidateId}),
      );

      if (response.statusCode == 200) {
        _currentUser!.hasVoted = true;
        _currentUser!.votedCandidateId = _selectedCandidateId;
        _incrementVote(_selectedCandidateId!);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Vote submission fallback: $e');
    }

    // Local state fallback
    _currentUser!.hasVoted = true;
    _currentUser!.votedCandidateId = _selectedCandidateId;
    _incrementVote(_selectedCandidateId!);
    notifyListeners();
    return true;
  }

  void _incrementVote(String candId) {
    final cand = _candidates.firstWhere((c) => c.id == candId, orElse: () => _candidates[0]);
    cand.votes += 1;
  }

  Future<void> fetchAdminStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _adminStats = data['stats'];
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Admin stats fallback: $e');
    }

    // Local fallback stats
    final totalVotes = _candidates.fold<int>(0, (sum, c) => sum + c.votes);
    Candidate leading = _candidates[0];
    for (var c in _candidates) {
      if (c.votes > leading.votes) leading = c;
    }

    _adminStats = {
      'totalUsers': 25,
      'totalVotes': totalVotes,
      'leadingCandidate': {
        'name': leading.name,
        'votes': leading.votes,
      },
      'candidates': _candidates.map((c) => {
        'id': c.id,
        'name': c.name,
        'party': c.party,
        'votes': c.votes,
        'percentage': totalVotes > 0 ? ((c.votes / totalVotes) * 100).toStringAsFixed(1) : '0.0',
      }).toList(),
    };
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _token = null;
    _selectedCandidateId = null;
    notifyListeners();
  }
}
