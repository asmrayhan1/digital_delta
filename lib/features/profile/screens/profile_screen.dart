import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP BAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: Color(0xFF2D6CDF)),
                      SizedBox(width: 8),
                      Text(
                        "Digital Delta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Syncing • 2m ago",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// PROFILE CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF071A2F), Color(0xFF0D2A47)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    /// AVATAR
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2D6CDF),
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(
                              "https://i.pravatar.cc/150?img=3",
                            ),
                          ),
                        ),

                        /// VERIFIED BADGE
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2EC4B6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// NAME
                    const Text(
                      "Commander Sarah Chen",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// ROLE
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EC4B6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "MANAGER",
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// DESCRIPTION
                    const Text(
                      "Strategic Operations Lead for Southern Sector Logistics & Field Response.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DEVICE CARD
              _infoCard(
                icon: Icons.devices,
                title: "DEVICE ID",
                value: "DD - 0912",
              ),

              const SizedBox(height: 12),

              /// PUBLIC KEY
              _infoCard(
                icon: Icons.key,
                title: "PUBLIC KEY",
                value: "0x4f...2a1",
              ),

              const SizedBox(height: 20),

              /// PERMISSIONS HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Active Permissions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("3 Total", style: TextStyle(color: Colors.grey)),
                ],
              ),

              const SizedBox(height: 12),

              /// PERMISSIONS LIST
              _permissionItem(
                icon: Icons.remove_red_eye,
                title: "View All Assets",
                subtitle: "Real-time global inventory access",
              ),
              _permissionItem(
                icon: Icons.alt_route,
                title: "Approve Routes",
                subtitle: "Logistical override and authorization",
              ),
              _permissionItem(
                icon: Icons.sync,
                title: "Initiate Sync",
                subtitle: "Global database reconciliation",
              ),

              const SizedBox(height: 20),

              /// SECURITY SETTINGS
              const Text(
                "Security Settings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _securityItem(
                icon: Icons.fingerprint,
                title: "Biometric Authentication",
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),

              _securityItem(
                icon: Icons.history,
                title: "Audit Logs",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),

              const SizedBox(height: 24),

              /// LOGOUT BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Logout from Terminal",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// FOOTER
              const Center(
                child: Text(
                  "ENCRYPTION SESSION ENDS IN 04:59",
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
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
/// INFO CARD
////////////////////////////////////////////////////////////
Widget _infoCard({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

////////////////////////////////////////////////////////////
/// PERMISSION ITEM
////////////////////////////////////////////////////////////
Widget _permissionItem({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2A47),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

////////////////////////////////////////////////////////////
/// SECURITY ITEM
////////////////////////////////////////////////////////////
Widget _securityItem({
  required IconData icon,
  required String title,
  required Widget trailing,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        trailing,
      ],
    ),
  );
}

////////////////////////////////////////////////////////////
/// BOTTOM NAV
////////////////////////////////////////////////////////////
Widget _bottomNav() {
  return Container(
    height: 70,
    decoration: const BoxDecoration(
      color: Color(0xFF071A2F),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Icon(Icons.grid_view, color: Colors.white54),
        const Icon(Icons.inventory, color: Colors.white54),
        const Icon(Icons.map, color: Colors.white54),
        const Icon(Icons.sync, color: Colors.white54),

        /// ACTIVE PROFILE
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2A47),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    ),
  );
}
