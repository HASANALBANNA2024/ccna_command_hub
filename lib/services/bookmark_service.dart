import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _key = "ccna_bookmarks";

  // ১. বুকমার্ক টগল (সেভ থাকলে ডিলিট হবে, না থাকলে নতুন করে সেভ হবে)
  static Future<void> toggleBookmark(Map<String, dynamic> subModule) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList(_key) ?? [];

    // টাইটেল দিয়ে চেক করা হচ্ছে (unique identifier হিসেবে)
    String title = subModule['title'] ?? "Untitled";
    int index = bookmarks.indexWhere((item) {
      final decoded = json.decode(item);
      return decoded['title'] == title;
    });

    if (index >= 0) {
      // যদি আগে থেকেই থাকে, তবে রিমুভ করো
      bookmarks.removeAt(index);
    } else {
      // না থাকলে পুরো ম্যাপটি (ID, Title, Theory, Desc) JSON করে সেভ করো
      bookmarks.add(json.encode(subModule));
    }

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