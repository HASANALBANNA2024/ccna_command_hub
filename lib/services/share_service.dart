import 'package:share_plus/share_plus.dart';

class ShareService {
  static void shareSubModule(String title, Map<String, dynamic>? details) {
    if (details == null) return;

    String shareContent = "📌 Topic: $title\n";
    shareContent += "==========================\n\n";

    // ১. থিওরি থাকলে যোগ করবে
    if (details['theory'] != null && details['theory'] != "") {
      shareContent += "📖 Theory:\n${details['theory']}\n\n";
    }

    // ২. ডায়নামিক লিস্ট চেক (types, devices, topologies, media, details ইত্যাদি)
    // এখানে ম্যাপের ভেতরে থাকা সব লিস্টগুলো চেক করা হচ্ছে
    List<String> listKeys = ['types', 'devices', 'topologies', 'media', 'details'];

    for (var key in listKeys) {
      if (details[key] != null && details[key] is List) {
        String sectionTitle = key[0].toUpperCase() + key.substring(1); // Key টাকে সুন্দর করে টাইটেল করবে
        shareContent += "📝 $sectionTitle:\n";

        for (var item in details[key]) {
          shareContent += "• ${item['name'] ?? ''}: ${item['desc'] ?? ''}\n";
        }
        shareContent += "\n";
      }
    }

    // ৩. এক্সাম্পল থাকলে যোগ করবে
    if (details['example'] != null && details['example'] != "") {
      shareContent += "💡 Example:\n${details['example']}\n\n";
    }

    shareContent += "--------------------------\n";
    shareContent += "Shared from: CCNA Command Hub App";

    // সিস্টেম শেয়ার ডায়ালগ ওপেন
    Share.share(shareContent);
  }

  // বুকমার্ক থেকে শেয়ার করার সময় যাতে সব ডাটা যায়
  static void shareBookmark(Map<String, dynamic> item) {
    String title = item['title'] ?? "CCNA Topic";

    // যদি আপনি 'full_content' কী-তে সব ডাটা সেভ করে থাকেন
    if (item['full_content'] != null) {
      shareSubModule(title, item['full_content']);
    } else {
      // ব্যাকআপ লজিক যদি ডাটা সরাসরি থাকে
      shareSubModule(title, item);
    }
  }
}