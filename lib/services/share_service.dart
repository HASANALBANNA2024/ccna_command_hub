import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  // মেইন শেয়ার ফাংশন (DetailsScreen থেকে কল হয়)
  static Future<void> shareSubModule(String title, dynamic details) async {
    if (details == null) return;

    StringBuffer shareContent = StringBuffer();
    shareContent.writeln("📌 Topic: $title");
    shareContent.writeln("==========================\n");

    String? imagePath;

    if (details is List) {
      for (var section in details) {
        if (section is Map) {
          shareContent.writeln("🔹 ${section['title']}:\n${section['content']}\n");
        }
      }
    }
    else if (details is Map<String, dynamic>) {
      if (details.containsKey('image') && details['image'] != null && details['image'] != "") {
        imagePath = await _prepareImageFile(details['image']);
      }

      details.forEach((key, value) {
        if (key == 'id' || key == 'title' || key == 'image' || value == null || value == "") return;
        String sectionTitle = key[0].toUpperCase() + key.substring(1);
        if (value is List) {
          shareContent.writeln("📂 $sectionTitle:");
          for (var item in value) {
            if (item is Map) {
              item.forEach((subKey, subValue) => shareContent.writeln("  - ${subKey.toUpperCase()}: $subValue"));
              shareContent.writeln("");
            } else {
              shareContent.writeln("  • ${item.toString()}");
            }
          }
        } else {
          shareContent.writeln("📖 $sectionTitle:\n${value.toString()}\n");
        }
      });
    }

    shareContent.writeln("--------------------------");
    shareContent.writeln("Shared from: CCNA Command Hub App");

    if (imagePath != null) {
      await Share.shareXFiles([XFile(imagePath)], text: shareContent.toString());
    } else {
      await Share.share(shareContent.toString());
    }
  }

  // এই ফাংশনটি আপনার এরর ফিক্স করবে (BookmarkScreen থেকে কল হয়)
  static void shareBookmark(Map<String, dynamic> item) {
    String title = item['title'] ?? "CCNA Topic";
    // বুকমার্ক আইটেমটি সরাসরি আমাদের মেইন শেয়ার ফাংশনে পাঠিয়ে দিচ্ছি
    shareSubModule(title, item);
  }

  // এসেট ইমেজকে ফাইলে রূপান্তর
  static Future<String?> _prepareImageFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes
      ));
      return file.path;
    } catch (e) {
      return null;
    }
  }


  // Share App
  static void shareApp() {
    const String appLink = "https://play.google.com/store/apps/details?id=com.your.package.name";
    const String message = "Hey! Check out CCNA Command Hub. 🚀\n"
        "It's an amazing app for CCNA students with Subnetting tools, Quiz Crush game, and Networking commands!\n\n"
        "Download now: $appLink";

    Share.share(message);
  }
}