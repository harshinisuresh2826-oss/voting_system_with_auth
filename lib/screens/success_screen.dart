import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voting_service.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final votingService = Provider.of<VotingService>(context);
    final user = votingService.currentUser;
    final candidates = votingService.candidates;
    final votedCand = candidates.firstWhere(
      (c) => c.id == user?.votedCandidateId,
      orElse: () => candidates[0],
    );

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            maxWidth: 480,
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFF161F32),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF10B981), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.check, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vote Successfully Submitted! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your choice has been encrypted and recorded in the database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Receipt Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('OFFICIAL VOTE RECEIPT', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text('VERIFIED ✓', style: TextStyle(color: Colors.white, fontSize: 10)),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12),
                      _receiptRow('Voter Account', user?.username ?? 'Voter'),
                      _receiptRow('Candidate Voted', votedCand.name, isHighlight: true),
                      _receiptRow('Party Alliance', votedCand.party),
                      _receiptRow('Receipt Hash', '0x8F9B2A109C4'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                      child: const Text('Return Home', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/admin'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                      child: const Text('View Live Results'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String val, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            val,
            style: TextStyle(
              color: isHighlight ? const Color(0xFF10B981) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
