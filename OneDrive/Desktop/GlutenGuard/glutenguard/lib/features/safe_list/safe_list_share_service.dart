import 'package:share_plus/share_plus.dart';
import '../../data/database/app_database.dart';

class SafeListShareService {
  static Future<void> share(List<SafeListItem> items) async {
    if (items.isEmpty) return;
    final lines = items.map((i) => '• ${i.productName}').join('\n');
    final text =
        'My GlutenGuard Safe List\n\n$lines\n\nVerified gluten-free with GlutenGuard.';
    await Share.share(text, subject: 'My Gluten-Free Safe List');
  }
}
