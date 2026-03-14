import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // UID ব্যবহারের জন্য

class SearchService {
  // ১. ডাইনামিক প্রিফিক্স (Prefix) জেনারেটর
  static String get _userPrefix {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? "${user.uid}_" : "guest_";
  }

  // কী (Key) গুলোর মূল নাম
  static const String _recentBaseKey = "recent_searches";
  static const String _countBaseKey = "search_counts";

  // ২. ডাইনামিক কি (Key) গেটার
  static String get _recentKey => "${_userPrefix}$_recentBaseKey";
  static String get _countKey => "${_userPrefix}$_countBaseKey";

  static Future<void> saveSearch(String fullName) async {
    if (fullName.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    // ১. Recent Search (ইউজার ভিত্তিক আলাদা লিস্ট)
    List<String> recent = prefs.getStringList(_recentKey) ?? [];
    recent.remove(fullName);
    recent.insert(0, fullName);
    if (recent.length > 10) recent = recent.sublist(0, 10);
    await prefs.setStringList(_recentKey, recent);

    // ২. Popularity Count Update (ইউজার ভিত্তিক আলাদা কাউন্ট)
    String countsJson = prefs.getString(_countKey) ?? "{}";
    Map<String, dynamic> counts = json.decode(countsJson);
    counts[fullName] = (counts[fullName] ?? 0) + 1;
    await prefs.setString(_countKey, json.encode(counts));
  }

  static Future<Map<String, List<String>>> getSearchData() async {
    final prefs = await SharedPreferences.getInstance();

    // বর্তমান ইউজারের Recent Data
    List<String> recent = prefs.getStringList(_recentKey) ?? [];

    // বর্তমান ইউজারের Popular Data Sorting Logic
    String countsJson = prefs.getString(_countKey) ?? "{}";
    Map<String, dynamic> counts = json.decode(countsJson);

    List<String> popular = counts.keys.toList();
    // যার কাউন্ট বেশি সে উপরে থাকবে
    popular.sort((a, b) => (counts[b] as int).compareTo(counts[a] as int));

    // ফিল্টার: কমপক্ষে ৫ বার সার্চ এবং সর্বোচ্চ ১০টি আইটেম
    popular = popular.where((key) => (counts[key] as int) >= 5).toList();
    if (popular.length > 10) popular = popular.sublist(0, 10);

    return {'recent': recent, 'popular': popular};
  }

  static Future<void> clearRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }

  static Future<void> clearPopular() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countKey);
  }
}