import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final horizontalPadding = width < 600 ? 16.0 : width * 0.08;
    final maxWidth = 900.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bar_chart, color: Color(0xFF2D6CDF)),
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
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ACTIVE DELIVERIES
                  _responsiveCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "12 Active Deliveries",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Real-time logistics tracking active",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              children: const [
                                _iconBox(Icons.local_shipping),
                                _iconBox(Icons.directions_boat),
                                _iconBox(Icons.flight),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _statusTile(
                          color: const Color(0xFF2EC4B6),
                          icon: Icons.check,
                          title: "ON-TIME",
                          value: "10",
                        ),

                        const SizedBox(height: 10),

                        _statusTile(
                          color: Colors.red,
                          icon: Icons.warning,
                          title: "DELAYED",
                          value: "2",
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SYSTEM ALERTS
                  _responsiveCard(
                    dark: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "System Alerts",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.notifications, color: Colors.orange),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _alertBox(
                          title: "HIGH PRIORITY",
                          subtitle: "Route blocked on B-12",
                          desc: "Detour calculation in progress.",
                          color: Colors.orange,
                          bg: const Color(0xFF5A2D00),
                        ),

                        const SizedBox(height: 12),

                        _alertBox(
                          title: "CONFLICT",
                          subtitle: "Conflict detected in Sync",
                          desc: "Node Delta-4 returning mismatched checksums.",
                          color: Colors.red,
                          bg: const Color(0xFF1C2A3A),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SUPPLY STATUS
                  _responsiveCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Supply Status",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Aggregate inventory levels",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F4F1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "MEDIUM",
                                style: TextStyle(
                                  color: Color(0xFF2EC4B6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _supplyRow("MEDICAL", 0.64),
                        const SizedBox(height: 16),
                        _supplyRow("WATER", 0.42),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// NODE STATUS
                  _responsiveCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Node Status",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Mesh network connectivity",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE6F4F1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.hub,
                                color: Color(0xFF2EC4B6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "18",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("ACTIVE NODES"),
                                ],
                              ),
                            ),
                            Container(height: 40, width: 1, color: Colors.grey),
                            const Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning, color: Colors.red),
                                  SizedBox(width: 6),
                                  Text("2"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HELPERS
////////////////////////////////////////////////////////////

Widget _responsiveCard({required Widget child, bool dark = false}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF071A2F) : Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

class _iconBox extends StatelessWidget {
  final IconData icon;
  const _iconBox(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18),
    );
  }
}

Widget _statusTile({
  required Color color,
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

Widget _alertBox({
  required String title,
  required String subtitle,
  required String desc,
  required Color color,
  required Color bg,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: color)),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(desc, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}

Widget _supplyRow(String label, double value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            "${(value * 100).toInt()}%",
            style: const TextStyle(color: Color(0xFF2EC4B6)),
          ),
        ],
      ),
      const SizedBox(height: 6),
      LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: const Color(0xFFE5E7EB),
        valueColor: const AlwaysStoppedAnimation(Color(0xFF2EC4B6)),
      ),
    ],
  );
}
