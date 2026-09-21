import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voting_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final votingService = Provider.of<VotingService>(context);
    final user = votingService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.how_to_vote, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'VotePulse',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          if (user == null) ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
              child: const Text('Register'),
            ),
            const SizedBox(width: 16),
          ] else ...[
            Chip(
              avatar: CircleAvatar(
                backgroundColor: const Color(0xFF3B82F6),
                child: Text(user.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
              ),
              label: Text('${user.username} (${user.role})'),
              backgroundColor: const Color(0xFF1E293B),
              labelStyle: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => votingService.logout(),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                ),
                child: const Text(
                  '✨ Next-Gen Flutter Online Voting',
                  style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Empowering Every Voice With Absolute Security',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cast your vote through a smooth Flutter UI experience with instant verification.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white60),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (user == null) {
                        Navigator.pushNamed(context, '/register');
                      } else {
                        Navigator.pushNamed(context, '/vote');
                      }
                    },
                    icon: const Icon(Icons.how_to_vote),
                    label: Text(user == null ? 'Register to Vote' : 'Go to Ballot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (user != null && user.role == 'admin') {
                        Navigator.pushNamed(context, '/admin');
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('Admin Dashboard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
