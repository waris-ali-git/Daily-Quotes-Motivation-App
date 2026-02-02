import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/journal_entry_model.dart';
import '../utils/constants.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> with SingleTickerProviderStateMixin {
  static const String _prefsKeyEntries = 'journal_entries';

  final TextEditingController _controller = TextEditingController();
  String _selectedMood = 'Motivated';
  bool _loading = true;
  List<JournalEntry> _entries = [];
  late AnimationController _saveAnimationController;

  final List<Map<String, dynamic>> _moods = const [
    {'label': 'Motivated', 'icon': Icons.bolt, 'color': Color(0xFF10B981)},
    {'label': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Color(0xFFFFD700)},
    {'label': 'Calm', 'icon': Icons.spa, 'color': Color(0xFF5AB9EA)},
    {'label': 'Grateful', 'icon': Icons.favorite, 'color': Color(0xFFFDB833)},
    {'label': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Color(0xFF6B7280)},
    {'label': 'Stressed', 'icon': Icons.psychology, 'color': Color(0xFFEF4444)},
    {'label': 'Angry', 'icon': Icons.local_fire_department, 'color': Color(0xFFDC2626)},
    {'label': 'Tired', 'icon': Icons.bedtime, 'color': Color(0xFF8D99AE)},
  ];

  @override
  void initState() {
    super.initState();
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKeyEntries);
    if (raw == null) {
      _entries = [];
      setState(() => _loading = false);
      return;
    }
    final decoded = json.decode(raw) as List<dynamic>;
    _entries = decoded
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    setState(() => _loading = false);
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKeyEntries, encoded);
  }

  Future<void> _addEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _saveAnimationController.forward().then((_) => _saveAnimationController.reverse());

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      content: text,
      mood: _selectedMood,
    );

    setState(() {
      _entries.insert(0, entry);
      _controller.clear();
    });

    await _saveEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppConstants.richGold, size: 20),
            const SizedBox(width: 12),
            Text(
              'Entry saved successfully',
              style: GoogleFonts.lato(color: AppConstants.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: AppConstants.oceanBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
    await _saveEntries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Entry deleted',
          style: GoogleFonts.lato(color: AppConstants.white),
        ),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> _getMoodData(String mood) {
    return _moods.firstWhere(
          (m) => m['label'] == mood,
      orElse: () => _moods[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          title: Text(
            'Journal',
            style: GoogleFonts.inter(
              color: isDark ? AppConstants.white : AppConstants.deepBlue,
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: IconThemeData(color: isDark ? AppConstants.paleGold : AppConstants.darkerGold),
        ),
        body: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppConstants.richGold,
            strokeWidth: 3,
          ),
        )
            : ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildNewEntrySection(),
          if (_entries.isEmpty)
             _buildEmptyState()
          else
            ..._entries.map((entry) {
               final moodData = _getMoodData(entry.mood);
               return Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16),
                 child: _buildEntryCard(entry, moodData),
               );
            }).toList(),
            const SizedBox(height: 20),
        ],
      ),
      ),
    );
  }

  Widget _buildNewEntrySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.15) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: isDark ? AppConstants.richGold : AppConstants.darkerGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'New Entry',
                style: GoogleFonts.montserrat(
                  color: isDark ? AppConstants.white : AppConstants.deepBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Text Field
          TextField(
            controller: _controller,
            maxLines: 4,
            style: GoogleFonts.lato(
              color: isDark ? AppConstants.white : Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'How are you feeling today?',
              hintStyle: GoogleFonts.lato(
                color: isDark ? AppConstants.lightGray.withOpacity(0.5) : AppConstants.mediumGray,
                fontSize: 15,
              ),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: const BorderSide(
                  color: AppConstants.richGold,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),

          // Mood Selector
          Text(
            'How do you feel?',
            style: GoogleFonts.lato(
              color: isDark ? AppConstants.lightGray : AppConstants.mediumGray,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              return _buildMoodChip(
                label: mood['label'] as String,
                icon: mood['icon'] as IconData,
                color: mood['color'] as Color,
                isSelected: isSelected,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Save Button
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.95).animate(_saveAnimationController),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppConstants.pureGoldGradient,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.richGold.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addEntry,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: AppConstants.deepBlue,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Save Entry',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppConstants.deepBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChip({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Material(
       color: Colors.transparent,
       child: InkWell(
         onTap: () => setState(() => _selectedMood = label),
         borderRadius: BorderRadius.circular(20),
         child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
           decoration: BoxDecoration(
             color: isSelected
                 ? color.withOpacity(0.2)
                 : Colors.white.withOpacity(0.05),
             borderRadius: BorderRadius.circular(20),
             border: Border.all(
               color: isSelected
                   ? color.withOpacity(0.5)
                   : Colors.white.withOpacity(0.1),
               width: 1.5,
             ),
           ),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Icon(icon, size: 16, color: isSelected ? color : AppConstants.lightGray),
               const SizedBox(width: 6),
               Text(
                 label,
                 style: GoogleFonts.lato(
                   fontSize: 13,
                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                   color: isSelected ? color : (Theme.of(context).brightness == Brightness.dark ? AppConstants.lightGray : AppConstants.mediumGray),
                 ),
               ),
             ],
           ),
         ),
       ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConstants.skyBlue.withOpacity(0.1),
              border: Border.all(
                color: AppConstants.skyBlue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: AppConstants.skyBlue.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your journal is empty',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? AppConstants.white : AppConstants.deepBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing your thoughts above',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: AppConstants.lightGray,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEntryCard(JournalEntry entry, Map<String, dynamic> moodData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (moodData['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (moodData['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        moodData['icon'] as IconData,
                        size: 14,
                        color: moodData['color'] as Color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        moodData['label'] as String,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: moodData['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatRelativeDate(entry.date),
                  style: GoogleFonts.lato(
                    color: AppConstants.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.content,
              style: GoogleFonts.lato(
                color: isDark ? AppConstants.lightGray : Colors.black87,
                fontSize: 15,
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(entry.date),
                  style: GoogleFonts.lato(
                    color: AppConstants.paleGold.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDeleteDialog(entry),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: AppConstants.errorColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.montserrat(
            color: AppConstants.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This action cannot be undone.',
          style: GoogleFonts.lato(color: AppConstants.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: AppConstants.lightGray),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteEntry(entry);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.lato(
                color: AppConstants.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}