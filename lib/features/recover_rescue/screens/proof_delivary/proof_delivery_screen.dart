import 'package:flutter/material.dart';

class ProofOfDeliveryScreen extends StatelessWidget {
  const ProofOfDeliveryScreen({super.key});

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

              /// TOP SUMMARY
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "ACTIVE CYCLE",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "OCT_24_DEPLOYMENT",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _Stat(label: "DELIVERED", value: "142"),
                        SizedBox(width: 30),
                        _Stat(label: "PENDING", value: "08"),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DELIVERY LIST
              _deliveryCard(
                title: "Tactical Hardware MK-IV",
                receiver: "Cmdr. Jameson, Site B",
                date: "24 OCT 2023",
                time: "14:32:05",
                delivered: true,
              ),

              _deliveryCard(
                title: "Neural Interface Module",
                receiver: "Logistics Hub 09",
                date: "25 OCT 2023",
                time: "ETA 09:00",
                delivered: false,
              ),

              _deliveryCard(
                title: "Class-A Rations (Bulk)",
                receiver: "Quartermaster Sarah Chen",
                date: "24 OCT 2023",
                time: "11:15:22",
                delivered: true,
              ),

              _deliveryCard(
                title: "Encrypted Storage Unit",
                receiver: "Restricted Sector 7",
                date: "23 OCT 2023",
                time: "21:00:15",
                delivered: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// DELIVERY CARD (UPDATED COLORS)
////////////////////////////////////////////////////////////
Widget _deliveryCard({
  required String title,
  required String receiver,
  required String date,
  required String time,
  required bool delivered,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        /// RECEIVER
        Text(
          "Receiver: $receiver",
          style: const TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 12),

        /// DATE + TIME
        Row(
          children: [
            _tag(date),
            const SizedBox(width: 8),
            _tag(time),
          ],
        ),

        const SizedBox(height: 14),

        /// ✅ UPDATED STATUS COLORS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: delivered
                ? const Color(0xFFE8F5E9) // green bg
                : const Color(0xFFFFF8E1), // yellow bg
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            delivered ? "DELIVERED" : "PENDING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: delivered ? Colors.green : Colors.orange,
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// ACTION TEXT
        Text(
          delivered ? "VIEW RECEIPT" : "UPDATE STATUS",
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 1,
            color: Colors.grey,
          ),
        )
      ],
    ),
  );
}

////////////////////////////////////////////////////////////
/// TAG
////////////////////////////////////////////////////////////
Widget _tag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFE5E7EB),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11),
    ),
  );
}

////////////////////////////////////////////////////////////
/// STAT
////////////////////////////////////////////////////////////
class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            )),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}