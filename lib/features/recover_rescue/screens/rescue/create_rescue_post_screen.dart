import 'package:flutter/material.dart';

class CreateRescuePostScreen extends StatefulWidget {
  const CreateRescuePostScreen({super.key});

  @override
  State<CreateRescuePostScreen> createState() => _CreateRescuePostScreenState();
}

class _CreateRescuePostScreenState extends State<CreateRescuePostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedLevel = "standard";
  bool _isSubmitting = false;

  final List<String> levels = ["critical", "high", "standard", "low"];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      /// 🔥 MOCK USER DATA (replace later with Supabase auth)
      final userName = "Demo User";
      final phone = "+8801XXXXXXXXX";

      final data = {
        "user_name": userName,
        "phone": phone,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "level": _selectedLevel,
        "created_at": DateTime.now().toIso8601String(),
      };

      /// TODO: send to Supabase
      /// await supabase.from('rescue_posts').insert(data);

      if (!mounted) return;

      Navigator.pop(context, data); // return created post
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case "critical":
        return const Color(0xFFD32F2F);
      case "high":
        return const Color(0xFFF57C00);
      case "standard":
        return const Color(0xFF1976D2);
      case "low":
        return const Color(0xFF388E3C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Rescue Post",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE FIELD
            const Text(
              "Title",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter rescue title...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION FIELD
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the situation...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LEVEL SELECTOR
            const Text(
              "Urgency Level",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              children: levels.map((level) {
                final isSelected = _selectedLevel == level;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedLevel = level);
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _levelColor(level)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _levelColor(level),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      level.toUpperCase(),
                      style: TextStyle(
                        color:
                        isSelected ? Colors.white : _levelColor(level),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000000),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Submit Rescue Post",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}