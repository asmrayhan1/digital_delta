import 'package:flutter/material.dart';

class CreateCampPostScreen extends StatefulWidget {
  const CreateCampPostScreen({super.key});

  @override
  State<CreateCampPostScreen> createState() => _CreateCampPostScreenState();
}

class _CreateCampPostScreenState extends State<CreateCampPostScreen> {
  final _titleController = TextEditingController();
  final _filledController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _filledController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final filled = _filledController.text.trim();
    final capacity = _capacityController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty ||
        filled.isEmpty ||
        capacity.isEmpty ||
        location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        "camp_title": title,
        "seats_filled": int.tryParse(filled) ?? 0,
        "capacity": int.tryParse(capacity) ?? 0,
        "location": location,
        "created_at": DateTime.now().toIso8601String(),
      };

      /// TODO: insert into Supabase
      /// await supabase.from('camp_posts').insert(data);

      if (!mounted) return;

      Navigator.pop(context, data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Camp Post",
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
          children: [
            /// TITLE
            TextField(
              controller: _titleController,
              decoration: _input("Camp Title"),
            ),
            const SizedBox(height: 12),

            /// SEATS FILLED
            TextField(
              controller: _filledController,
              keyboardType: TextInputType.number,
              decoration: _input("Seats Filled"),
            ),
            const SizedBox(height: 12),

            /// CAPACITY
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: _input("Total Capacity"),
            ),
            const SizedBox(height: 12),

            /// LOCATION
            TextField(
              controller: _locationController,
              decoration: _input("Location"),
            ),

            const SizedBox(height: 30),

            /// SUBMIT
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
                  "Publish Camp",
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