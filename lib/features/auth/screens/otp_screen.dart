import 'dart:async';
import 'package:digital_delta/core/services/auth_service.dart';
import 'package:digital_delta/core/services/mesh_service.dart';
import 'package:digital_delta/core/services/encryption_service.dart';
import 'package:digital_delta/features/mesh/screens/mesh_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  const OtpScreen({super.key, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _auth = AuthService();

  late Timer _timer;
  int _secondsRemaining = 60;
  String _currentGeneratedOtp = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateNewOtp();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          // Window expired: Re-generate and reset timer
          _generateNewOtp();
          _secondsRemaining = 30;
        }
      });
    });
  }

  void _generateNewOtp() async {
    // In a real app, you fetch the secret from SecureStorage
    // For the demo, we use the mobile-based secret logic
    final otpSecret = OTP.randomSecret(); // Base32 string
    setState(() {
      _currentGeneratedOtp = _auth.generateOTP(otpSecret);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndSubmit() async {
    setState(() => _isLoading = true);

    // M1.1: Verification logic
    bool isValid = await _auth.verifyOTP(
      widget.mobile,
      _currentGeneratedOtp,
      _otpController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Access Granted"),
            backgroundColor: Colors.green,
          ),
        );

        // Initialize E2E encryption keys
        await EncryptionService.generateAndStoreKeyPair(widget.mobile);
        // Create mesh manager
        final meshManager = MeshSyncManager(
          userId: widget.mobile,
          deviceName:
              'Device_${widget.mobile.substring(widget.mobile.length - 4)}',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MeshDashboardScreen(meshManager: meshManager),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid or Expired Code"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 48, color: Color(0xFF0B1F33)),
                const SizedBox(height: 16),
                const Text(
                  "TWO-STEP VERIFICATION",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter the code from your hardware token",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 30),

                /// DISPLAY GENERATED OTP (DEMO MODE)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2EC4B6),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentGeneratedOtp,
                        style: const TextStyle(
                          fontSize: 32,
                          letterSpacing: 8,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Color(0xFF0B1F33),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Expires in: ${_secondsRemaining}s",
                        style: TextStyle(
                          color: _secondsRemaining < 10
                              ? Colors.red
                              : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// INPUT FIELD
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "Enter 6-digit code",
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
                    onPressed: _isLoading ? null : _verifyAndSubmit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Authorize Access →",
                            style: TextStyle(color: Colors.white),
                          ),
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
