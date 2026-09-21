import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voting_service.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    final votingService = Provider.of<VotingService>(context);
    final candidates = votingService.candidates;
    final selectedId = votingService.selectedCandidateId;
    final user = votingService.currentUser;
    final hasVoted = user?.hasVoted ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        title: const Text('Official Digital Ballot'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Stepper Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepCircle(1, 'Select Candidate', _currentStep == 1),
                Container(width: 40, height: 2, color: Colors.white24),
                _buildStepCircle(2, 'Review Selection', _currentStep == 2),
              ],
            ),
            const SizedBox(height: 24),

            if (hasVoted)
              Container(
                margin: const EdgeInsets.bottom(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have already cast your vote in this election! Duplicate votes are blocked.',
                        style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            if (_currentStep == 1) ...[
              // Candidate Grid
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: candidates.map((cand) {
                  final isSelected = selectedId == cand.id;
                  return GestureDetector(
                    onTap: hasVoted ? null : () => votingService.selectCandidate(cand.id),
                    child: Container(
                      width: 320,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161F32),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF10B981) : Colors.white12,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.4),
                                  blurRadius: 15,
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              image: DecorationImage(
                                image: NetworkImage(cand.avatar),
                                fit: BoxFit.cover,
                                onError: (_, __) {},
                              ),
                            ),
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.all(12),
                            child: CircleAvatar(
                              backgroundColor: isSelected ? const Color(0xFF10B981) : Colors.black54,
                              child: Icon(
                                isSelected ? Icons.check : Icons.circle_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cand.name,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  cand.party,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF60A5FA), fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cand.role,
                                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '"${cand.manifesto}"',
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: (selectedId == null || hasVoted)
                    ? null
                    : () => setState(() => _currentStep = 2),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Review Selection →'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ] else if (_currentStep == 2) ...[
              // Review Step
              Container(
                maxWidth: 500,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161F32),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: Column(
                  children: [
                    const Text('Confirm Candidate Choice', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 16),
                    Text(
                      candidates.firstWhere((c) => c.id == selectedId).name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                    Text(
                      candidates.firstWhere((c) => c.id == selectedId).party,
                      style: const TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () => setState(() => _currentStep = 1),
                          child: const Text('← Change Choice', style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final success = await votingService.castVote();
                            if (success && mounted) {
                              Navigator.pushReplacementNamed(context, '/success');
                            }
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Submit Vote ✓'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, String title, bool isActive) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: isActive ? const Color(0xFF3B82F6) : Colors.white24,
          child: Text('$step', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
