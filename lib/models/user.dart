class User {
  final String id;
  final String username;
  final String role;
  bool hasVoted;
  String? votedCandidateId;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.hasVoted = false,
    this.votedCandidateId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'voter',
      hasVoted: json['hasVoted'] ?? false,
      votedCandidateId: json['votedCandidateId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'hasVoted': hasVoted,
      'votedCandidateId': votedCandidateId,
    };
  }
}
