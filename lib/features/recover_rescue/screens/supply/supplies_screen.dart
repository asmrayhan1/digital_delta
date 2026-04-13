import 'package:digital_delta/features/recover_rescue/screens/supply/create_supply_post.dart';
import 'package:flutter/material.dart';

class RationsSuppliesScreen extends StatelessWidget {
  const RationsSuppliesScreen({super.key});

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
              builder: (_) => const CreateSupplyPostScreen(),
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

              const SizedBox(height: 15),
              /// TOP STATS
              Row(
                children: [
                  Expanded(
                    child: _topCard(
                      title: "ACTIVE ASSETS",
                      value: "142",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _alertCard(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// SEARCH
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      "FILTER INVENTORY...",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "MAIN INVENTORY",
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Updated 04:00 Zulu",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// ITEMS
              _inventoryItem(
                title: "Tactical Ration Pack",
                category: "SUSTENANCE",
                units: "12,400",
                status: "AVAILABLE",
              ),

              _inventoryItem(
                title: "Medical Field Kit",
                category: "TRAUMA",
                units: "42",
                status: "LOW",
              ),

              _inventoryItem(
                title: "Hydration Reservoirs",
                category: "FLUIDS",
                units: "850",
                status: "AVAILABLE",
              ),

              _inventoryItem(
                title: "Plasma Batteries",
                category: "ENERGY",
                units: "0",
                status: "OUT OF STOCK",
              ),

              _inventoryItem(
                title: "Thermal Blankets",
                category: "SHELTER",
                units: "2,100",
                status: "AVAILABLE",
              ),

              const SizedBox(height: 30),

              /// ADD BUTTON
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// TOP CARD
////////////////////////////////////////////////////////////
Widget _topCard({required String title, required String value}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

////////////////////////////////////////////////////////////
/// ALERT CARD
////////////////////////////////////////////////////////////
Widget _alertCard() {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ALERT STATUS",
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 6),
            Text(
              "CRITICAL",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        )
      ],
    ),
  );
}

////////////////////////////////////////////////////////////
/// INVENTORY ITEM (UPDATED STATUS COLORS)
////////////////////////////////////////////////////////////
Widget _inventoryItem({
  required String title,
  required String category,
  required String units,
  required String status,
}) {
  final isAvailable = status == "AVAILABLE";
  final isLow = status == "LOW";
  final isOut = status == "OUT OF STOCK";

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                "CATEGORY: $category",
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            /// STATUS COLOR LOGIC
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isAvailable
                    ? const Color(0xFFE8F5E9) // green bg
                    : isLow
                    ? const Color(0xFFFFF8E1) // yellow bg
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isOut
                    ? Border.all(color: Colors.red) // red border
                    : null,
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAvailable
                      ? Colors.green
                      : isLow
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "$units UNITS",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        )
      ],
    ),
  );
}