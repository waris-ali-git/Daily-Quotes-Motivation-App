import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry_model.dart';
import '../utils/constants.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  static const String _prefsKeyEntries = 'journal_entries';

  final TextEditingController _controller = TextEditingController();
  String _selectedMood = 'Motivated';
  bool _loading = true;
  List<JournalEntry> _entries = [];

  final List<String> _moods = const [
    'Motivated',
    'Happy',
    'Calm',
    'Grateful',
    'Sad',
    'Stressed',
    'Angry',
    'Tired',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    _entries = decoded.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList()
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

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      content: text,
      mood: _selectedMood,
    );

    setState(() {
      _entries.insert(0, entry);
      _controller.clear();
      _selectedMood = 'Motivated';
    });

    await _saveEntries();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry saved')),
    );
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
    await _saveEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Journal',
          style: GoogleFonts.playfairDisplay(color: AppConstants.secondaryColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppConstants.secondaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntries,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.secondaryColor))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                      boxShadow: AppConstants.cardShadow,
                      border: Border.all(color: AppConstants.white.withOpacity(0.06)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('New entry', style: GoogleFonts.montserrat(color: AppConstants.paleGold, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _controller,
                            maxLines: 4,
                            style: GoogleFonts.lato(color: AppConstants.white),
                            decoration: InputDecoration(
                              hintText: 'Write your thoughts...',
                              hintStyle: GoogleFonts.lato(color: AppConstants.lightGray.withOpacity(0.7)),
                              filled: true,
                              fillColor: AppConstants.surfaceColor.withOpacity(0.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                borderSide: BorderSide(color: AppConstants.white.withOpacity(0.10)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                borderSide: BorderSide(color: AppConstants.white.withOpacity(0.10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                borderSide: const BorderSide(color: AppConstants.secondaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedMood,
                                  dropdownColor: AppConstants.cardColor,
                                  iconEnabledColor: AppConstants.secondaryColor,
                                  decoration: InputDecoration(
                                    labelText: 'Mood',
                                    labelStyle: GoogleFonts.lato(color: AppConstants.paleGold),
                                    filled: true,
                                    fillColor: AppConstants.surfaceColor.withOpacity(0.35),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                      borderSide: BorderSide(color: AppConstants.white.withOpacity(0.10)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                      borderSide: BorderSide(color: AppConstants.white.withOpacity(0.10)),
                                    ),
                                  ),
                                  items: _moods
                                      .map((m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(m, style: GoogleFonts.lato(color: AppConstants.white)),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() => _selectedMood = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _addEntry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.secondaryColor,
                                  foregroundColor: AppConstants.deepBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
                                ),
                                icon: const Icon(Icons.save),
                                label: Text('Save', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _entries.isEmpty
                      ? Center(
                          child: Text(
                            AppConstants.emptyJournal,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(color: AppConstants.lightGray),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _entries.length,
                          itemBuilder: (context, i) {
                            final e = _entries[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppConstants.cardColor,
                                borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                border: Border.all(color: AppConstants.white.withOpacity(0.06)),
                                boxShadow: AppConstants.cardShadow,
                              ),
                              child: ListTile(
                                title: Text(
                                  e.content,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.lato(color: AppConstants.white, height: 1.35),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '${_fmtDate(e.date)} • ${e.mood}',
                                    style: GoogleFonts.lato(color: AppConstants.paleGold.withOpacity(0.9)),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: AppConstants.errorColor,
                                  onPressed: () => _deleteEntry(e),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _fmtDate(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }
}
