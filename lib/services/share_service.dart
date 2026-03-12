import 'package:share_plus/share_plus.dart';

class ShareService {
  static void shareSubModule(String title, dynamic details) {
    if (details == null) return;

    String shareContent = "📌 Topic: $title\n";
    shareContent += "==========================\n\n";

    // ১. যদি ডাটাটি List ফরম্যাটে থাকে (AppBar Full Bookmark এর ডাটা)
    if (details is List) {
      for (var section in details) {
        if (section is Map) {
          shareContent += "🔹 ${section['title']}:\n${section['content']}\n\n";
        }
      }
    }
    // ২. যদি ডাটাটি Map ফরম্যাটে থাকে (Normal Details বা Individual Bookmark)
    else if (details is Map<String, dynamic>) {
      // থিওরি যোগ করা
      if (details['theory'] != null && details['theory'] != "") {
        shareContent += "📖 Theory:\n${details['theory']}\n\n";
      }

      // ডায়নামিক লিস্ট চেক (types, devices, topologies, media, details ইত্যাদি)
      List<String> listKeys = ['types', 'devices', 'topologies', 'media', 'details'];

      for (var key in listKeys) {
        if (details[key] != null && details[key] is List) {
          String sectionTitle = key[0].toUpperCase() + key.substring(1);
          shareContent += "📝 $sectionTitle:\n";

          for (var item in details[key]) {
            shareContent += "• ${item['name'] ?? ''}: ${item['desc'] ?? ''}\n";
          }
          shareContent += "\n";
        }
      }

      // এক্সাম্পল যোগ করা
      if (details['example'] != null && details['example'] != "") {
        shareContent += "💡 Example:\n${details['example']}\n\n";
      }
    }

    shareContent += "--------------------------\n";
    shareContent += "Shared from: CCNA Command Hub App";

    // সিস্টেম শেয়ার ডায়ালগ ওপেন
    Share.share(shareContent);
  }

  // বুকমার্ক থেকে শেয়ার করার সময় যাতে সব ডাটা যায়
  static void shareBookmark(Map<String, dynamic> item) {
    String title = item['title'] ?? "CCNA Topic";

    // full_content থাকলে সেটি পাঠাবে (সেটি List বা Map যাই হোক)
    if (item['full_content'] != null) {
      shareSubModule(title, item['full_content']);
    } else {
      // ব্যাকআপ লজিক যদি ডাটা সরাসরি থাকে (ইন্ডিভিজুয়াল বুকমার্ক)
      shareSubModule(title, item);
    }
  }
}