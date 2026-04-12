import 'package:digital_delta/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// TOP LOGO
              Row(
                children: const [
                  Icon(Icons.shield, color: Color(0xFF0B1F33)),
                  SizedBox(width: 8),
                  Text(
                    "DIGITAL DELTA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B1F33), Color(0xFF102A43)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// BADGE
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C3D5A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "SECURE INFRASTRUCTURE",
                        style:
                        TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// TITLE
                    const Text(
                      "Command the",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),

                    const Text(
                      "Tactical Edge.",
                      style: TextStyle(
                        color: Color(0xFF2EC4B6),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// DESCRIPTION
                    const Text(
                      "Join the next generation of disaster logistics. "
                          "Real-time data, verified security, and absolute reliability "
                          "for mission-critical operations.",
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// STATS
                    Row(
                      children: const [
                        _StatItem(
                          title: "256-bit",
                          subtitle: "AES ENCRYPTION",
                        ),
                        SizedBox(width: 24),
                        _StatItem(
                          title: "99.9%",
                          subtitle: "MISSION UPTIME",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// FORM CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Join Digital Delta",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Provision your tactical account to access the command center.",
                      style: TextStyle(color: Colors.black54),
                    ),

                    const SizedBox(height: 20),

                    /// FULL NAME
                    _inputField(
                      hint: "Enter Name",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 14),

                    /// EMAIL
                    _inputField(
                      hint: "Enter Email",
                      icon: Icons.email,
                    ),

                    const SizedBox(height: 14),

                    /// PASSWORD
                    _inputField(
                      hint: "Enter Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 14),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1F33),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implement registration logic 
                        },
                        child: const Text(
                          "Create Account →",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// LOGIN TEXT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xFF2EC4B6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// INPUT FIELD
////////////////////////////////////////////////////////////
Widget _inputField({
  required String hint,
  required IconData icon,
  bool isPassword = false,
}) {
  return TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

////////////////////////////////////////////////////////////
/// STAT ITEM
////////////////////////////////////////////////////////////
class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatItem({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}