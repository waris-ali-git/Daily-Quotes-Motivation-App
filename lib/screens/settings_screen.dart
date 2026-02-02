import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/voice_service.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isMaleVoice = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _isMaleVoice = prefs.getBool('isMaleVoice') ?? true;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() => _notificationsEnabled = value);

    if (!value) {
      await NotificationService().cancelAll();
      _showSnackbar('Notifications disabled', Icons.notifications_off);
    } else {
      _showSnackbar('Notifications enabled', Icons.notifications_active);
    }
  }

  Future<void> _saveVoiceSetting(bool isMale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMaleVoice', isMale);
    setState(() => _isMaleVoice = isMale);

    final voiceService = VoiceService();
    await voiceService.updateVoiceSettings(isMale);
    await voiceService.speakQuote(isMale ? "Voice set to Deep Male" : "Voice set to Female");
  }

 Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppConstants.richGold,
              onPrimary: Colors.black,
              surface: const Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ) : ThemeData.light().copyWith(
             colorScheme: ColorScheme.light(
              primary: AppConstants.richGold,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      await NotificationService().scheduleNotification(picked.hour, picked.minute);
      if (!context.mounted) return;
       // Format nicely
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final format = TimeOfDay.fromDateTime(dt).format(context);
      
      _showSnackbar("Scheduled for $format", Icons.alarm);
    }
  }

  void _showSnackbar(String message, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppConstants.richGold, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: GoogleFonts.lato(
                color: AppConstants.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.oceanBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Select Theme',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption("Light Mode", !isDark, () {
              themeProvider.toggleTheme(false);
              Navigator.pop(context);
            }),
            _buildDialogOption("Dark Mode", isDark, () {
              themeProvider.toggleTheme(true);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
    final currentSize = fontSizeProvider.fontSizeLabel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Select Font Size',
          style: GoogleFonts.montserrat(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption("Small", currentSize == "Small", () {
              fontSizeProvider.setFontSize("Small");
              Navigator.pop(context);
            }),
            _buildDialogOption("Medium", currentSize == "Medium", () {
              fontSizeProvider.setFontSize("Medium");
              Navigator.pop(context);
            }),
            _buildDialogOption("Large", currentSize == "Large", () {
              fontSizeProvider.setFontSize("Large");
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(String text, bool isSelected, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.lato(
          color: isSelected
              ? AppConstants.richGold
              : (isDark ? Colors.white : Colors.black),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppConstants.richGold) : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        gradient: isDark
            ? const LinearGradient(
                colors: AppConstants.darkModeHomeGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: isDark ? AppConstants.paleGold : AppConstants.darkerGold),
          title: Text(
            'Settings',
            style: GoogleFonts.playfairDisplay(
              color: isDark ? AppConstants.white : AppConstants.deepBlue,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.alarm, color: AppConstants.paleGold),
              tooltip: 'Schedule Notification',
              onPressed: () => _pickTime(context),
            )
          ]
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // Section 1: General
            _buildSectionHeader("GENERAL"),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.notifications_active_rounded,
              title: "Daily Notifications",
              subtitle: "Get inspired every day",
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppConstants.richGold,
                activeTrackColor: AppConstants.richGold.withOpacity(0.3),
                inactiveThumbColor: AppConstants.mediumGray,
                inactiveTrackColor: Colors.white.withOpacity(0.1),
                onChanged: _saveNotificationSetting,
              ),
            ),
            
            _buildSettingCard(
              icon: Icons.record_voice_over_rounded,
              title: "Voice Preference",
              subtitle: _isMaleVoice ? "Deep Male" : "Female",
              trailing: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Male Toggle
                    InkWell(
                      onTap: () => _saveVoiceSetting(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isMaleVoice ? AppConstants.richGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text("Male", 
                          style: GoogleFonts.lato(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: _isMaleVoice ? Colors.black : AppConstants.mediumGray
                          )
                        ),
                      ),
                    ),
                    // Female Toggle
                    InkWell(
                      onTap: () => _saveVoiceSetting(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_isMaleVoice ? AppConstants.richGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text("Female", 
                           style: GoogleFonts.lato(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: !_isMaleVoice ? Colors.black : AppConstants.mediumGray
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section 2: Appearance
            _buildSectionHeader("APPEARANCE"),
             const SizedBox(height: 12),
             
             _buildSettingCard(
              icon: Icons.palette_outlined,
              title: "Theme",
              subtitle: themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppConstants.paleGold,
              ),
              onTap: _showThemeDialog,
            ),
            
             _buildSettingCard(
              icon: Icons.text_fields_rounded,
              title: "Font Size",
              subtitle: fontSizeProvider.fontSizeLabel,
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppConstants.paleGold,
              ),
              onTap: _showFontSizeDialog,
            ),


            const SizedBox(height: 32),

            // Section 3: About
            _buildSectionHeader("ABOUT"),
            const SizedBox(height: 12),
            
            _buildSettingCard(
              icon: Icons.star_rounded,
              title: "Rate Us",
              subtitle: "Show some love on Play Store",
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppConstants.paleGold,
              ),
              onTap: () {
                _showDialog(
                  title: 'Rate Us',
                  content: 'Thank you for using Smart Quotes!\n\n'
                      'If you enjoy the app, please consider rating us on the Play Store.\n\n'
                      'Your feedback helps us improve!',
                  icon: Icons.star_rounded,
                );
              },
            ),

            _buildSettingCard(
              icon: Icons.privacy_tip_rounded,
              title: "Privacy Policy",
              subtitle: "How we protect your data",
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppConstants.paleGold,
              ),
              onTap: () {
                _showDialog(
                  title: 'Privacy Policy',
                  content: 'Smart Quotes Privacy Policy\n\n'
                      '1. Data Collection: We collect minimal data necessary for app functionality.\n\n'
                      '2. Local Storage: Your favorites and preferences are stored locally on your device.\n\n'
                      '3. Third-Party Services: We use Google AdMob for advertisements.\n\n'
                      '4. No Personal Data: We do not collect or share personal information.',
                  icon: Icons.privacy_tip_rounded,
                  scrollable: true,
                );
              },
            ),

            const SizedBox(height: 40),

            // Version
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  "Version 1.0.0",
                  style: GoogleFonts.lato(
                    color: AppConstants.mediumGray,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    // Rely on Theme.of(context).brightness for consistent UI rendering 
    // regardless of whether themeMode is System, Dark, or Light.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: isDark ? AppConstants.richGold : AppConstants.darkerGold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    // Rely on Theme.of(context).brightness for consistent UI rendering
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.skyBlue.withOpacity(0.3),
                        AppConstants.skyBlue.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.skyBlue.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppConstants.skyBlue,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          color: isDark ? AppConstants.white : AppConstants.deepBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.lato(
                          color: isDark ? AppConstants.lightGray : AppConstants.mediumGray,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Trailing
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog({
    required String title,
    required String content,
    required IconData icon,
    bool scrollable = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppConstants.richGold, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: scrollable
            ? SingleChildScrollView(
                child: Text(
                  content,
                  style: GoogleFonts.lato(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppConstants.lightGray
                        : Colors.black87,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              )
            : Text(
                content,
                style: GoogleFonts.lato(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppConstants.lightGray
                      : Colors.black87,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.montserrat(
                color: AppConstants.richGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
