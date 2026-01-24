import 'dart:io';
import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote_model.dart';
import '../services/api_service.dart';

class QuoteImageGenerator extends StatefulWidget {
  final Quote quote;
  final VoidCallback onClose; // Callback to close the overlay

  const QuoteImageGenerator({
    super.key, 
    required this.quote,
    required this.onClose,
  });

  @override
  State<QuoteImageGenerator> createState() => _QuoteImageGeneratorState();
}

class _QuoteImageGeneratorState extends State<QuoteImageGenerator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ApiService _apiService = ApiService();

  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchNewImage();
  }

  Future<void> _fetchNewImage() async {
    String query = widget.quote.category.isEmpty || widget.quote.category == 'General'
        ? 'nature,inspirational'
        : widget.quote.category;

    String url = await _apiService.fetchQuoteBackgroundImage(widget.quote.text, query);
    if (url.contains('loremflickr')) {
      url += '?random=${DateTime.now().millisecondsSinceEpoch}';
    }

    if (mounted) {
      setState(() {
        _imageUrl = url;
      });
    }
  }

  Future<void> _shareImage() async {
    final Uint8List? imageBytes = await _screenshotController.capture();
    if (imageBytes != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/quote_share.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(imagePath.path)],
          text: 'Check out this quote!',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              // Relax height constraint to fit buttons below without squeezing image too much
              maxHeight: MediaQuery.of(context).size.height * 0.85, 
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1) The Image Card
                    Flexible( // Use Flexible instead of Expanded to let it shrink if needed
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Screenshot(
                            controller: _screenshotController,
                            child: AspectRatio(
                              aspectRatio: 4/5, // Enforce a nice portrait aspect ratio
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF667eea),
                                      Color(0xFF764ba2),
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Background Image
                                    if (_imageUrl != null)
                                      Image.network(
                                        _imageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                      ),

                                    // Frosted glass effect layer base
                                    BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Dark overlay for contrast
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.1),
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Quote Content Card
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(25),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                            child: Container(
                                              padding: const EdgeInsets.all(30),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(25),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.2),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.format_quote,
                                                      color: Colors.white.withOpacity(0.8),
                                                      size: 40,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      widget.quote.text,
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.montserrat(
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w300,
                                                        color: Colors.white,
                                                        height: 1.4,
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius: 15.0,
                                                            color: Colors.black.withOpacity(0.3),
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 25),
                                                    Container(
                                                      width: 50,
                                                      height: 3,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.6),
                                                        borderRadius: BorderRadius.circular(2),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                      '— ${widget.quote.author.toUpperCase()}',
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.lato(
                                                        fontSize: 11,
                                                        letterSpacing: 2.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.white.withOpacity(0.95),
                                                        shadows: [
                                                          Shadow(
                                                            blurRadius: 10.0,
                                                            color: Colors.black.withOpacity(0.2),
                                                            offset: const Offset(0, 1),
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

                    // 2) Bottom Action Buttons
                    const SizedBox(height: 20), // Spacing between card and buttons
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      // No decoration, transparent background
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _fetchNewImage,
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              label: const Text(
                                'New Image',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.9), // Semi-transparent white for button
                                foregroundColor: Colors.black87,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareImage,
                              icon: const Icon(Icons.share_rounded, size: 20),
                              label: const Text(
                                'Share',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea), // Keep primary color for share
                                foregroundColor: Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 3) Close Button
                Positioned(
                  top: 0, 
                  right: 0,
                  child: GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}