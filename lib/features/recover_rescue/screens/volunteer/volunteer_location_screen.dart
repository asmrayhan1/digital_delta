import 'package:flutter/material.dart';

class VolunteerLocationScreen extends StatefulWidget {
  const VolunteerLocationScreen({super.key});

  @override
  State<VolunteerLocationScreen> createState() => _VolunteerLocationScreenState();
}

class _VolunteerLocationScreenState extends State<VolunteerLocationScreen> {

  /// ✅ CONTROLLER ADDED
  final TextEditingController _locationController = TextEditingController();

  void _submitLocation() {
    final value = _locationController.text.trim();

    if (value.isEmpty) return;

    final data = {
      "location": value,
      "created_at": DateTime.now().toIso8601String(),
    };

    print(data); // TODO: send to backend

    /// clear field after submit
    _locationController.clear();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 600 ? 16.0 : width * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// BACK BUTTON
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              const Text(
                "Volunteer Locations",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// ✅ UPDATED QUICK LOCATION POST
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "Enter location...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _submitLocation(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// ✅ WORKING POST BUTTON
                  GestureDetector(
                    onTap: _submitLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A86FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Post",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// LIST
              _volunteerCard(
                name: "Sarah Chen",
                role: "Field Medic",
                phone: "01612345678",
                location: "Sector 7 - Northern Zone",
              ),

              const SizedBox(height: 12),

              _volunteerCard(
                name: "David Kumar",
                role: "Rescue Operator",
                phone: "01612345679",
                location: "Camp Alpha - East Wing",
              ),

              const SizedBox(height: 12),

              _volunteerCard(
                name: "Maria Lopez",
                role: "Logistics Coordinator",
                phone: "01612345674",
                location: "Supply Depot B",
              ),

              const SizedBox(height: 12),

              _volunteerCard(
                name: "John Carter",
                role: "Search Specialist",
                phone: "01612345672",
                location: "Zone Delta - Grid 4",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// VOLUNTEER CARD
////////////////////////////////////////////////////////////
Widget _volunteerCard({
  required String name,
  required String role,
  required String phone,
  required String location,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        /// AVATAR
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2EC4B6).withOpacity(0.2),
          child: const Icon(Icons.person, color: Color(0xFF2EC4B6)),
        ),

        const SizedBox(width: 14),

        /// INFO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 6),

              /// Phone
              Row(
                children: [
                  const Icon(Icons.phone,
                      size: 16, color: Color(0xFF3A86FF)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              /// LOCATION
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Color(0xFF3A86FF)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
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
  );
}