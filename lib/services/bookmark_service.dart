import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  // ১. সব জায়গায় এই একই Key ব্যবহার করতে হবে
  static const String _key = "ccna_bookmarks";

  // ২. বুকমার্ক টগল (সেভ থাকলে ডিলিট হবে, না থাকলে নতুন করে সেভ হবে)
  static Future<void> toggleBookmark(Map<String, dynamic> subModule) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_key) ?? [];

    String title = subModule['title'] ?? "Untitled";

    int index = -1;
    for (int i = 0; i < bookmarks.length; i++) {
      Map<String, dynamic> item = json.decode(bookmarks[i]);
      if (item['title'] == title) {
        index = i;
        break;
      }
    }

    if (index >= 0) {
      bookmarks.removeAt(index);
    } else {
      // পুরো ম্যাপটি JSON স্ট্রিং করে সেভ করা
      bookmarks.add(json.encode(subModule));
    }

    // আপডেট হওয়া লিস্টটি লোকাল স্টোরেজে সেভ করা
    await prefs.setStringList(_key, bookmarks);
  }

  // ৩. চেক করা যে কোনো নির্দিষ্ট আইটেম বুকমার্ক করা আছে কি না
  static Future<bool> isBookmarked(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_key) ?? [];
    return bookmarks.any((item) {
      try {
        return json.decode(item)['title'] == title;
      } catch (e) {
        return false;
      }
    });
  }

  // ৪. সব বুকমার্ক লিস্ট হিসেবে নিয়ে আসা (এটি ড্যাশবোর্ড এবং বুকমার্ক স্ক্রিন দুই জায়গাতেই কাজ করবে)
  static Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // getStringList ব্যবহার করা হয়েছে কারণ সেভ করার সময় setStringList ব্যবহার করা হয়
      List<String> bookmarks = prefs.getStringList(_key) ?? [];

      return bookmarks
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching bookmarks: $e");
      return [];
    }
  }

  // ৫. সবগুলো বুকমার্ক এক ক্লিকে ডিলিট করা
  static Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}