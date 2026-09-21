import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/voting_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    final service = Provider.of<VotingService>(context, listen: false);
    final success = await service.login(username, password);

    setState(() => _isLoading = false);

    if (success && mounted) {
      if (service.currentUser?.role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/vote');
      }
    }
  }

  void _fillDemo(String u, String p) {
    _usernameController.text = u;
    _passwordController.text = p;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            maxWidth: 420,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF161F32),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_open, size: 48, color: Color(0xFF8B5CF6)),
                const SizedBox(height: 12),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Demo Quick Fill Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text('💡 One-Click Demo Credentials', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionChip(
                            label: const Text('Admin (admin / admin123)'),
                            backgroundColor: const Color(0xFF8B5CF6),
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                            onPressed: () => _fillDemo('admin', 'admin123'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ActionChip(
                            label: const Text('Voter (demovoter1 / voter123)'),
                            backgroundColor: const Color(0xFF10B981),
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                            onPressed: () => _fillDemo('demovoter1', 'voter123'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email, color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0F172A),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.key, color: Colors.white54),
                    filled: true,
                    fillColor: Color(0xFF0F172A),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign In → Go to Ballot', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
