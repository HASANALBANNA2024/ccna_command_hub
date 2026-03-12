import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _key = "ccna_bookmarks";

  // ১. বুকমার্ক টগল (সেভ থাকলে ডিলিট হবে, না থাকলে নতুন করে সেভ হবে)
  static Future<void> toggleBookmark(Map<String, dynamic> subModule) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_key) ?? [];

    // ১. সাব-মডিউলের টাইটেলটি বের করা (এটিই আমাদের ইউনিক আইডি)
    String title = subModule['title'] ?? "Untitled";

    // ২. অলরেডি এই টাইটেলটি বুকমার্ক লিস্টে আছে কি না চেক করা
    int index = -1;
    for (int i = 0; i < bookmarks.length; i++) {
      Map<String, dynamic> item = json.decode(bookmarks[i]);
      if (item['title'] == title) {
        index = i;
        break;
      }
    }

    if (index >= 0) {
      // ৩. যদি অলরেডি থাকে, তবে সেটি রিমুভ করে দাও (Un-bookmark)
      bookmarks.removeAt(index);
    } else {
      // ৪. যদি না থাকে, তবে পুরো ম্যাপটি (full_content সহ) সেভ করো
      // এখানে আমরা পুরো ম্যাপটিকে কপি করে নিচ্ছি যাতে ডাটা লস না হয়
      bookmarks.add(json.encode(subModule));
    }

    // ৫. আপডেট হওয়া লিস্টটি লোকাল স্টোরেজে সেভ করা
    await prefs.setStringList(_key, bookmarks);
  }

  // ২. চেক করা যে কোনো আইটেম বুকমার্ক করা আছে কি না
  static Future<bool> isBookmarked(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_key) ?? [];
    return bookmarks.any((item) => json.decode(item)['title'] == title);
  }

  // ৩. সব বুকমার্ক লিস্ট হিসেবে নিয়ে আসা
  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_key) ?? [];

    // JSON স্ট্রিং থেকে পুনরায় Map এ কনভার্ট করা
    return bookmarks.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  // ৪. সবগুলো বুকমার্ক এক ক্লিকে ডিলিট করা (নতুন যোগ করা হয়েছে)
  static Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}