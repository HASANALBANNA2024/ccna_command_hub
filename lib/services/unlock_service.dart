import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // UID ব্যবহারের জন্য

class UnlockService {
  // ১. ডাইনামিক প্রিফিক্স (Prefix) তৈরি করা
  static String get _userPrefix {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? "${user.uid}_" : "guest_";
  }

  // কী (Key) গুলোর নাম আগের মতোই থাকছে, শুধু তার আগে UID বসবে
  static const String _subKey = "unlocked_sub_";
  static const String _modKey = "unlocked_mod_";
  static const String _quizKey = "quiz_passed_";

  // সাব-মডিউল আনলক কিনা চেক করা
  static Future<bool> isSubUnlocked(String subId) async {
    if (subId.endsWith('_s1')) return true;
    final prefs = await SharedPreferences.getInstance();
    // UID অনুযায়ী আলাদা কী চেক করা হচ্ছে
    return prefs.getBool('${_userPrefix}${_subKey}$subId') ?? false;
  }

  // সাব-মডিউল আনলক করা (পড়া শেষ হলে)
  static Future<void> markSubAsRead(String subId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_userPrefix}${_subKey}$subId', true);
  }

  // মডিউল আনলক কিনা চেক করা
  static Future<bool> isModuleUnlocked(String moduleId) async {
    if (moduleId == 'm1') return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_userPrefix}${_modKey}$moduleId') ?? false;
  }

  // মডিউল আনলক করা (পাস করলে বা অ্যাড দেখলে)
  static Future<void> unlockModule(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_userPrefix}${_modKey}$moduleId', true);
  }

  // সব সাব-মডিউল পড়া হয়েছে কি না চেক (কুইজের আগে দরকার)
  static Future<bool> canTakeQuiz(List<dynamic> subModules) async {
    for (var sub in subModules) {
      if (!await isSubUnlocked(sub['id'])) return false;
    }
    return true;
  }

  // কুইজ পাসের সংখ্যা এবং ড্যাশবোর্ড প্রগ্রেস আপডেট
  static Future<int> getPassedQuizCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ১. বর্তমান ইউজারের UID নেওয়া (এটি static মেথড তাই সরাসরি FirebaseAuth থেকে নেওয়া নিরাপদ)
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

      // ২. আপনার কুইজ কি (Key) যদি অন্য কোথাও ডিফাইন করা থাকে তবে সেটি এখানে ব্যবহার করুন
      // অন্যথায় সরাসরি '_quiz_passed_' স্ট্রিংটি ব্যবহার করা ভালো
      const String quizKey = "_quiz_passed_";

      int totalPassed = 0;

      // ৩. ১ থেকে ৩২ পর্যন্ত লুপ চালিয়ে চেক করা
      for (int i = 1; i <= 32; i++) {
        // এখানে কী (Key) টি তৈরি হচ্ছে এইভাবে: UserID_quiz_passed_m1
        bool isPassed = prefs.getBool('${uid}${quizKey}m$i') ?? false;

        if (isPassed) {
          totalPassed++;
        }
      }

      print("Total Passed Quizzes for $uid: $totalPassed");
      return totalPassed;

    } catch (e) {
      print("Error in getPassedQuizCount: $e");
      return 0;
    }
  }

  // সর্বশেষ আনলক হওয়া মডিউল আইডি বের করা
  static Future<String> getLastUnlockedModuleId() async {
    final prefs = await SharedPreferences.getInstance();
    int lastUnlocked = 1;

    for (int i = 1; i <= 32; i++) {
      bool isUnlocked = prefs.getBool('${_userPrefix}${_modKey}m$i') ?? false;
      if (isUnlocked) {
        lastUnlocked = i;
      } else {
        break;
      }
    }
    return "m$lastUnlocked";
  }
}