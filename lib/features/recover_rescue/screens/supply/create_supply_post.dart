import 'package:flutter/material.dart';

class CreateSupplyPostScreen extends StatefulWidget {
  const CreateSupplyPostScreen({super.key});

  @override
  State<CreateSupplyPostScreen> createState() => _CreateSupplyPostScreenState();
}

class _CreateSupplyPostScreenState extends State<CreateSupplyPostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _unitsController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final units = _unitsController.text.trim();

    if (title.isEmpty || desc.isEmpty || units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        "title": title,
        "description": desc,
        "units": int.tryParse(units) ?? 0,
        "created_at": DateTime.now().toIso8601String(),
      };

      /// TODO: Supabase insert
      /// await supabase.from('supply_posts').insert(data);

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
          "Create Supply Post",
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
              decoration: _input("Supply Title"),
            ),
            const SizedBox(height: 12),

            /// DESCRIPTION
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _input("Short Description"),
            ),
            const SizedBox(height: 12),

            /// UNITS
            TextField(
              controller: _unitsController,
              keyboardType: TextInputType.number,
              decoration: _input("Units Available"),
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
                  "Publish Supply",
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