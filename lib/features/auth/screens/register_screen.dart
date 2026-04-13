import 'package:digital_delta/core/services/auth_service.dart';
import 'package:digital_delta/core/utils/helper.dart';
import 'package:digital_delta/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Controllers for form data
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // M1.3: RBAC Role selection state
  String _selectedRole = 'User';
  final List<String> _roles = [
    'Field Volunteer',
    'Supply Manager',
    'Drone Operator',
    'Camp Commander',
    'Sync Admin',
    'User',
  ];
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // 3. The Registration Logic
  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final mobile = _mobileController.text.trim();
    final pass = _passController.text.trim();

    if (username.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calls M1.1 (OTP), M1.2 (Keys), and M1.4 (Audit Log)
      final String? errorMessage = await _authService.registerUser(
        username,
        mobile,
        pass,
        _selectedRole,
      );

      if (mounted) {
        if (errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Account created!"),
            ),
          );
          // Navigate to Login after registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.red, content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

                    const Text(
                      "Tactical Role",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF0B1F33),
                          ),
                          items: _roles.map((String role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRole = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    /// FULL USERNAME
                    _inputField(
                      controller: _usernameController,
                      hint: "Enter Username",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 14),

                    /// PASSWORD
                    _inputField(
                      controller: _mobileController,
                      hint: "Enter Mobile No.",
                      icon: Icons.phone,
                      isPassword: false,
                    ),
                    const SizedBox(height: 14),

                    /// PASSWORD
                    _inputField(
                      controller: _passController,
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
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Create Account →",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
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
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
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
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool isPassword = false,
}) {
  return TextField(
    controller: controller,
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

  const _StatItem({required this.title, required this.subtitle});

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
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}
