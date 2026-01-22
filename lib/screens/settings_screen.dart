import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/voice_service.dart';
import '../providers/theme_provider.dart';
import '../providers/font_size_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme Colors
  final Color _royalBlue = const Color(0xFF0F172A);
  final Color _gold = const Color(0xFFA39551);
  final Color _darkBackground = const Color(0xFFFFFFFF);

  bool _notificationsEnabled = true;
  bool _soundEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _soundEnabled = prefs.getBool('soundEnabled') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() => _notificationsEnabled = value);
    
    if (!value) {
      // Cancel all notifications if disabled
      await NotificationService().cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications disabled')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications enabled. Schedule a time from home screen.')),
        );
      }
    }
  }

  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    setState(() => _soundEnabled = value);
    
    // Test sound if enabled
    if (value) {
      final voiceService = VoiceService();
      await voiceService.speakQuote("App sounds enabled");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App sounds enabled')),
        );
      }
    } else {
      final voiceService = VoiceService();
      await voiceService.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App sounds disabled')),
        );
      }
    }
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
        title: Text(
          'Select Theme',
          style: GoogleFonts.lato(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption("Light Mode", false, isDark),
            _buildThemeOption("Dark Mode", true, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, bool isDark, bool currentIsDark) {
    final isSelected = (isDark && currentIsDark) || (!isDark && !currentIsDark);
    return ListTile(
      title: Text(
        theme,
        style: GoogleFonts.lato(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: _gold) : null,
      onTap: () {
        final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
        themeProvider.toggleTheme(isDark);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Theme changed to $theme')),
        );
      },
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
        title: Text(
          'Select Font Size',
          style: GoogleFonts.lato(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeOption("Small", currentSize),
            _buildFontSizeOption("Medium", currentSize),
            _buildFontSizeOption("Large", currentSize),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(String size, String currentSize) {
    final isSelected = currentSize == size;
    // Calculate font size for preview
    double previewSize = 16.0;
    switch (size) {
      case "Small":
        previewSize = 14.0;
        break;
      case "Medium":
        previewSize = 16.0;
        break;
      case "Large":
        previewSize = 20.0;
        break;
    }
    
    return ListTile(
      title: Row(
        children: [
          Text(
            size,
            style: GoogleFonts.lato(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
              fontSize: previewSize,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Aa',
            style: TextStyle(
              fontSize: previewSize,
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white70 
                  : Colors.black87,
            ),
          ),
        ],
      ),
      trailing: isSelected ? Icon(Icons.check, color: _gold) : null,
      onTap: () {
        final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: false);
        fontSizeProvider.setFontSize(size);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Font size changed to $size')),
        );
      },
    );
  }

  void _rateUs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.white,
        title: Text(
          'Rate Us',
          style: GoogleFonts.lato(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Thank you for using Daily Quotes Motivation App!\n\n'
          'If you enjoy the app, please consider rating us on the Play Store.\n\n'
          'Your feedback helps us improve!',
          style: GoogleFonts.lato(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white70 
                : Colors.black87,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.lato(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you! Please rate us on Play Store.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: Text(
              'Rate Now',
              style: GoogleFonts.lato(color: _gold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[900] 
            : Colors.white,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.lato(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Daily Quotes Motivation App Privacy Policy\n\n'
            'Last Updated: ${DateTime.now().year}\n\n'
            '1. Data Collection\n'
            'We collect minimal data necessary for app functionality. Your favorite quotes are stored locally on your device.\n\n'
            '2. Personal Information\n'
            'We do not collect, store, or share any personal information.\n\n'
            '3. Third-Party Services\n'
            'We use Google AdMob for advertisements. Please refer to Google\'s privacy policy for ad-related data collection.\n\n'
            '4. Local Storage\n'
            'Your favorite quotes and app preferences are stored locally on your device using SharedPreferences.\n\n'
            '5. Contact\n'
            'For any questions about this privacy policy, please contact us through the app store listing.',
            style: GoogleFonts.lato(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white70 
                  : Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.lato(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
          const SizedBox(height: 20),

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
              onChanged: _saveNotificationSetting,
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
              onChanged: _saveSoundSetting,
            ),
          ),

          const SizedBox(height: 25),

          // Section 2: Appearance
          _buildSectionHeader("APPEARANCE"),
          _buildSettingsTile(
            icon: Icons.palette_outlined,
            title: "Theme",
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  themeProvider.isDarkMode ? "Dark Mode" : "Light Mode",
                  style: GoogleFonts.lato(color: _gold),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: _gold),
              ],
            ),
            onTap: _showThemeDialog,
          ),
          _buildSettingsTile(
            icon: Icons.text_fields,
            title: "Font Size",
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fontSizeProvider.fontSizeLabel,
                  style: GoogleFonts.lato(color: _gold),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 16, color: _gold),
              ],
            ),
            onTap: _showFontSizeDialog,
          ),

          const SizedBox(height: 25),

          // Section 3: Support
          _buildSectionHeader("SUPPORT"),
          _buildSettingsTile(
            icon: Icons.star_outline,
            title: "Rate Us",
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _gold),
            onTap: _rateUs,
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _gold),
            onTap: _showPrivacyPolicy,
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
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.withOpacity(0.2),
        ),
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 16,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
