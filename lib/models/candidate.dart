class Candidate {
  final String id;
  final String name;
  final String party;
  final String role;
  final String manifesto;
  final String avatar;
  int votes;

  Candidate({
    required this.id,
    required this.name,
    required this.party,
    required this.role,
    required this.manifesto,
    required this.avatar,
    this.votes = 0,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      party: json['party'] ?? '',
      role: json['role'] ?? '',
      manifesto: json['manifesto'] ?? '',
      avatar: json['avatar'] ?? '',
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'party': party,
      'role': role,
      'manifesto': manifesto,
      'avatar': avatar,
      'votes': votes,
    };
  }
}
