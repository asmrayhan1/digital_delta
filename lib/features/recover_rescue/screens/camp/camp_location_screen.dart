import 'package:digital_delta/features/recover_rescue/screens/camp/create_campt_post.dart';
import 'package:flutter/material.dart';

class CampScreen extends StatelessWidget {
  const CampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 600 ? 16.0 : width * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      /// ADD BUTTON (FAB)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF000000),
        elevation: 4,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCampPostScreen(),
            ),
          );

          if (result != null) {
            // TODO: Add to feed or refresh
            print(result);
          }
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
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
                "Camp Locations",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// LIST
              _campCard(
                name: "Camp Alpha",
                location: "Sector 7 - Northern Zone",
                total_fill: "1200",
                capacity: "1200",
              ),
              const SizedBox(height: 10),

              _campCard(
                name: "Camp Bravo",
                location: "East Wing - Relief Area",
                total_fill: "484",
                capacity: "850",
              ),
              const SizedBox(height: 10),
              _campCard(
                name: "Camp Delta",
                location: "Supply Depot B",
                total_fill: "118",
                capacity: "600",
              ),
              const SizedBox(height: 10),

              _campCard(
                name: "Camp Echo",
                location: "Zone Delta - Grid 4",
                total_fill: "325",
                capacity: "400",
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CAMP CARD
////////////////////////////////////////////////////////////
Widget _campCard({
  required String name,
  required String location,
  required String total_fill,
  required String capacity,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        /// CAMP ICON
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF2EC4B6).withOpacity(0.2),
          child: const Icon(Icons.cabin, color: Color(0xFF2EC4B6)),
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

              /// ✅ Fill
              Text(
                "Seat Fill: $total_fill",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),
              /// ✅ CAPACITY
              Text(
                "Capacity: $capacity",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              /// ✅ available
              Text(
                "Available seat: ${int.parse(capacity) - int.parse(total_fill)}",                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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

        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    ),
  );
}