import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // UID পাওয়ার জন্য ইম্পোর্ট

class BookmarkService {

  // ১. ডাইনামিক কি (Key) তৈরি করার মেথড
  // এটি ইউজারের UID অনুযায়ী আলাদা আলাদা কি (Key) রিটার্ন করবে
  static String get _userSpecificKey {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return "bookmarks_${user.uid}"; // যেমন: bookmarks_abc123
    }
    return "bookmarks_guest"; // যদি লগইন না থাকে তবে গেস্ট হিসেবে থাকবে
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