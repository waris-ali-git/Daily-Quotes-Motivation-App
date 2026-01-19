import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_fonts/google_fonts.dart'; // Make sure to add this dependency if we want cool fonts, otherwise standard. 
// For now using standard TextStyle to assume no extra deps unless asked.
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote_model.dart';
import '../services/api_service.dart';

class QuoteImageGenerator extends StatefulWidget {
  final Quote quote;

  const QuoteImageGenerator({Key? key, required this.quote}) : super(key: key);

  @override
  State<QuoteImageGenerator> createState() => _QuoteImageGeneratorState();
}

class _QuoteImageGeneratorState extends State<QuoteImageGenerator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final ApiService _apiService = ApiService();
  
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewImage();
  }

  Future<void> _fetchNewImage() async {
    setState(() => _isLoading = true);
    // Use category or a default "nature" keyword if category is generic
    String query = widget.quote.category.isEmpty || widget.quote.category == 'General' 
        ? 'nature,inspirational' 
        : widget.quote.category;
        
    String url = await _apiService.fetchQuoteBackgroundImage(widget.quote.text, query);
    // Add a random parameter to force refresh if it's the same URL base
    if (url.contains('loremflickr')) {
      url += '?random=${DateTime.now().millisecondsSinceEpoch}';
    }
    
    if (mounted) {
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });
    }
  }

  Future<void> _shareImage() async {
    final Uint8List? imageBytes = await _screenshotController.capture();
    if (imageBytes != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/quote_share.png').create();
      await imagePath.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(imagePath.path)], text: 'Check out this quote!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Image')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 1.5, // Portrait aspect ratio roughly
                  color: Colors.black, // Fallback color
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image with Low Saturation
                      if (_imageUrl != null)
                        ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.7, 0.15, 0.15, 0, 0, // Red
                            0.15, 0.7, 0.15, 0, 0, // Green
                            0.15, 0.15, 0.7, 0, 0, // Blue
                            0, 0, 0, 1, 0,         // Alpha
                          ]), // Reduces saturation slightly
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            },
                          ),
                        ),

                      // Gradient Overlay for better text contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2), // Lighter at top
                              Colors.black.withOpacity(0.7), // Darker at bottom
                            ],
                          ),
                        ),
                      ),

                      // Quote Text with Elegant Typography
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Quote Icon
                            const  Icon(Icons.format_quote, color: Colors.white70, size: 40),
                            const SizedBox(height: 20),
                            Text(
                              widget.quote.text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                            Divider(color: Colors.white.withOpacity(0.5), endIndent: 80, indent: 80),
                            const SizedBox(height: 10),
                            Text(
                              widget.quote.author.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
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
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _fetchNewImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('New Image'),
                ),
                ElevatedButton.icon(
                  onPressed: _shareImage,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

