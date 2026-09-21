import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voting_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<VotingService>(context, listen: false).fetchAdminStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final votingService = Provider.of<VotingService>(context);
    final stats = votingService.adminStats;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text('Election Admin Dashboard'),
        backgroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => votingService.fetchAdminStats(),
          ),
        ],
      ),
      body: stats == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Analytics Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),

                  // KPI Cards Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _kpiCard('Total Registered Voters', '${stats['totalUsers'] ?? 25}', Icons.people, const Color(0xFF3B82F6)),
                      _kpiCard('Total Votes Cast', '${stats['totalVotes'] ?? 0}', Icons.how_to_vote, const Color(0xFF10B981)),
                      _kpiCard('Leading Candidate', '${stats['leadingCandidate']?['name'] ?? 'N/A'}', Icons.emoji_events, const Color(0xFF8B5CF6)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('Live Candidate Tallies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161F32),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: ((stats['candidates'] as List<dynamic>?) ?? []).map((c) {
                        final String name = c['name'] ?? '';
                        final int votes = c['votes'] ?? 0;
                        final String pctStr = c['percentage']?.toString() ?? '0.0';
                        final double pct = double.tryParse(pctStr) ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('$votes votes ($pctStr%)', style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: pct / 100.0,
                                backgroundColor: const Color(0xFF0F172A),
                                color: const Color(0xFF3B82F6),
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _kpiCard(String title, String val, IconData icon, Color col) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161F32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: col.withOpacity(0.2),
            child: Icon(icon, color: col),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
