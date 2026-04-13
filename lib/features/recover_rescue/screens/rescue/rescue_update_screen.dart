import 'package:flutter/material.dart';

import 'create_rescue_post_screen.dart';

class RescueUpdatesScreen extends StatelessWidget {
  const RescueUpdatesScreen({super.key});

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
              builder: (_) => const CreateRescuePostScreen(),
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
              /// BACK BUTTON ONLY
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
                "Rescue Updates",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828)
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: 40,
                height: 3,
                color: Color(0xFFC62828),
              ),

              const SizedBox(height: 20),

              /// CARD 1
              _updateCard(
                sector: "SECTOR 07 // DELTA",
                time: "14:22 UTC",
                title: "Perimeter Breach Contained",
                desc:
                "Tactical units successfully neutralized the structural instability in the northern quadrant. All personnel accounted for. Emergency shoring complete."
              ),

              const SizedBox(height: 16),

              /// CARD 2
              _updateCard(
                sector: "SECTOR 02 // ECHO",
                time: "11:05 UTC",
                title: "Evacuation Route 4 Re-opened",
                desc:
                "Debris clearing completed by automated units. Route 4 is now designated as the primary extraction artery for civilians.",
              ),

              const SizedBox(height: 16),

              /// CARD 3
              _updateCard(
                sector: "LOGISTICS // GAMMA",
                time: "09:15 UTC",
                title: "Supply Drop Successful",
                desc:
                "Medical kits and thermal blankets delivered to the central transit station.",
              ),

              const SizedBox(height: 16),

              /// CARD 5
              _updateCard(
                sector: "ENVIRONMENT // ZETA",
                time: "YESTERDAY",
                title: "Atmospheric Stabilization",
                desc:
                "Toxicity levels have dropped below the threshold. Masks are no longer required.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// NORMAL CARD
////////////////////////////////////////////////////////////
Widget _updateCard({
  required String sector,
  required String time,
  required String title,
  required String desc,
  String? person,
  String? role,
  bool trailingIcon = false,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TOP ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sector,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /// TITLE
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (trailingIcon)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory, color: Colors.white),
              ),
          ],
        ),

        const SizedBox(height: 10),

        /// DESCRIPTION
        Text(
          desc,
          style: const TextStyle(color: Colors.black54, height: 1.5),
        )
      ],
    ),
  );
}