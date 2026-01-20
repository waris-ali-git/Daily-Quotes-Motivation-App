import 'package:share_plus/share_plus.dart';

class ShareService {
  // Share quote text using system share sheet
  Future<void> shareQuote(String text, {String? author}) async {
    String shareText = '"$text"';
    if (author != null && author.isNotEmpty) {
      shareText += '\n- $author';
    }
    // ignore: deprecated_member_use
    await Share.share(shareText);
  }
}
