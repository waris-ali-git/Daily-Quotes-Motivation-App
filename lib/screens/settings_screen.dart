import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme Colors
  final Color _royalBlue = const Color(0xFF0F172A);
  final Color _gold = const Color(0xFFA39551);
  final Color _darkBackground = const Color(0xFFD8DDE8);

  // Dummy State for Toggles (Connect these to SharedPreferences later)
  bool _notificationsEnabled = true;
  bool _soundEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        backgroundColor: _darkBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(color: _gold, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _royalBlue,
                  child: Icon(Icons.person, size: 40, color: _gold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Premium Member",
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Unlock all features",
                  style: GoogleFonts.lato(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Section 1: General
          _buildSectionHeader("GENERAL"),
          _buildSettingsTile(
            icon: Icons.notifications_active_outlined,
            title: "Daily Notifications",
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: _royalBlue,
              activeTrackColor: _gold,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade800,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                // Call NotificationService here
              },
            ),
          ),
          _buildSettingsTile(
            icon: Icons.volume_up_outlined,
            title: "App Sounds",
            trailing: Switch(
              value: _soundEnabled,
              activeColor: _royalBlue,
              activeTrackColor: _gold,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade800,
              onChanged: (val) {
                setState(() => _soundEnabled = val);
              },
            ),
          ),

          const SizedBox(height: 25),

          // Section 2: Appearance
          _buildSectionHeader("APPEARANCE"),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: "Theme",
            trailing: Text("Royal Blue", style: GoogleFonts.lato(color: _gold)),
          ),
          _buildSettingsTile(
            icon: Icons.text_fields,
            title: "Font Size",
            trailing: Text("Medium", style: GoogleFonts.lato(color: _gold)),
          ),

          const SizedBox(height: 25),

          // Section 3: Support
          _buildSectionHeader("SUPPORT"),
          _buildSettingsTile(
            icon: Icons.star_outline,
            title: "Rate Us",
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _gold),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _gold),
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "Version 1.0.0",
              style: GoogleFonts.lato(color: Colors.grey.withOpacity(0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: _gold,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slightly lighter than bg
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _royalBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _gold, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}