import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // এই লাইনটি এরর দিচ্ছিল, তাই রিমুভ করা হয়েছে

class BookmarkService {

  // ১. ডাইনামিক কি (Key) তৈরি করার মেথড
  // অফলাইন মোডের জন্য আমরা ফিক্সড গেস্ট কি ব্যবহার করব
  static String get _userSpecificKey {
    // ফায়ারবেস ইউজার চেকিং বাদ দিয়ে সরাসরি অফলাইন কি ব্যবহার করা হয়েছে
    return "bookmarks_guest";
  }

  // ২. বুকমার্ক টগল (সেভ থাকলে ডিলিট হবে, না থাকলে নতুন করে সেভ হবে)
  static Future<void> toggleBookmark(Map<String, dynamic> subModule) async {
    final prefs = await SharedPreferences.getInstance();

    // ডাইনামিক কি ব্যবহার করছি
    List<String> bookmarks = prefs.getStringList(_userSpecificKey) ?? [];

    String title = subModule['title'] ?? "Untitled";

    int index = -1;
    for (int i = 0; i < bookmarks.length; i++) {
      try {
        Map<String, dynamic> item = json.decode(bookmarks[i]);
        if (item['title'] == title) {
          index = i;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (index >= 0) {
      bookmarks.removeAt(index);
    } else {
      // পুরো ম্যাপটি JSON স্ট্রিং করে সেভ করা
      bookmarks.add(json.encode(subModule));
    }

    // আপডেট হওয়া লিস্টটি ইউজারের নির্দিষ্ট কি-তে সেভ করা
    await prefs.setStringList(_userSpecificKey, bookmarks);
  }

  // ৩. চেক করা যে কোনো নির্দিষ্ট আইটেম বুকমার্ক করা আছে কি না
  static Future<bool> isBookmarked(String title) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ডাইনামিক কি ব্যবহার করছি
      List<String> bookmarks = prefs.getStringList(_userSpecificKey) ?? [];

      return bookmarks.any((item) {
        try {
          return json.decode(item)['title'] == title;
        } catch (e) {
          return false;
        }
      });
    } catch (e) {
      // কোনো কারণে এরর হলে অ্যাপ ক্রাশ করবে না, জাস্ট false রিটার্ন করবে
      return false;
    }
  }

  // ৪. সব বুকমার্ক লিস্ট হিসেবে নিয়ে আসা
  static Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ডাইনামিক কি ব্যবহার করছি
      List<String> bookmarks = prefs.getStringList(_userSpecificKey) ?? [];

      return bookmarks
          .map((e) => json.decode(e) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching bookmarks: $e");
      return [];
    }
  }

  // ৫. শুধুমাত্র বর্তমান ইউজারের বুকমার্কগুলো ডিলিট করা
  static Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userSpecificKey);
  }
}