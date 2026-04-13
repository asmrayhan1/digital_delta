import 'package:digital_delta/features/recover_rescue/screens/camp/camp_location_screen.dart';
import 'package:digital_delta/features/recover_rescue/screens/proof_delivary/proof_delivery_screen.dart';
import 'package:digital_delta/features/recover_rescue/screens/recovery/recovery_update_screen.dart';
import 'package:digital_delta/features/recover_rescue/screens/rescue/rescue_update_screen.dart';
import 'package:digital_delta/features/recover_rescue/screens/supply/supplies_screen.dart';
import 'package:digital_delta/features/recover_rescue/screens/volunteer/volunteer_location_screen.dart';
import 'package:flutter/material.dart';

class RecoveryRescueScreen extends StatelessWidget {
  const RecoveryRescueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 600 ? 16.0 : width * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bar_chart,
                          color: Color(0xFF2D6CDF)),
                      const SizedBox(width: 8),
                      Text(
                        "Digital Delta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width < 400 ? 16 : 18,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "SYNCING • 2M AGO",
                    style:
                    TextStyle(color: Colors.grey, fontSize: 12),
                  )
                ],
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// LEFT SIDE (STATUS)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2ECC71), // live green
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "OPERATIONAL STATUS",
                              style: TextStyle(
                                letterSpacing: 1.5,
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          "ACTIVE",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text(
                          "NODES",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2EC4B6), // accent color
                          ),
                        ),
                      ],
                    ),

                    /// RIGHT SIDE (PRIORITY)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "RESPONSE LEVEL",
                          style: TextStyle(
                            letterSpacing: 1.5,
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2EC4B6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "PRIORITY",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2EC4B6),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "ALPHA",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              /// GRID (CLICKABLE)
              Expanded(
                child: GridView.count(
                  crossAxisCount: width < 600 ? 2 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    _HubItem(
                      icon: Icons.campaign,
                      color: const Color(0xFFC62828),
                      title: "Rescue Updates",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RescueUpdatesScreen(),
                            ),
                          );
                        },
                    ),
                    _HubItem(
                      icon: Icons.people,
                      color: const Color(0xFF3A86FF),
                      title: "Volunteers Location",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VolunteerLocationScreen(),
                          ),
                        );
                      },
                    ),
                    _HubItem(
                      icon: Icons.terrain,
                      color: const Color(0xFFFF9F1C),
                      title: "Camp Locations",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CampScreen(),
                          ),
                        );
                      },
                    ),
                    _HubItem(
                      icon: Icons.inventory,
                      color: const Color(0xFF6C63FF),
                      title: "Rations / Supplies",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RationsSuppliesScreen(),
                          ),
                        );
                      },
                    ),
                    _HubItem(
                      icon: Icons.verified,
                      color: const Color(0xFF2EC4B6),
                      title: "Proof of Delivery",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProofOfDeliveryScreen(),
                          ),
                        );
                      },
                    ),

                    _HubItem(
                      icon: Icons.build,
                      color: const Color(0xFF2ECC71),
                      title: "Recovery Updates",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecoveryUpdateScreen(),
                          ),
                        );
                      },
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
/// CLICKABLE GRID ITEM
////////////////////////////////////////////////////////////
class _HubItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _HubItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}