import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UnlockService {
  // ১. ইউজার প্রিফিক্স
  static String get _userPrefix {
    final User? user = FirebaseAuth.instance.currentUser;
    return user != null ? "${user.uid}_" : "guest_";
  }

  // কী (Keys)
  static const String _subKey = "unlocked_sub_";
  static const String _modKey = "unlocked_mod_";
  static const String _quizKey = "quiz_passed_";

  // ২. সাব-মডিউল আনলক কিনা চেক করা (আইকন এবং এক্সেস এর জন্য)
  static Future<bool> isSubUnlocked(String subId) async {
    // প্রথম সাব-মডিউল সবসময় আনলক থাকবে
    if (subId.endsWith('_s1')) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_userPrefix}${_subKey}$subId') ?? false;
  }

  // ৩. সাব-মডিউল পড়া শেষ হলে মার্ক করা
  static Future<void> markSubAsRead(String subId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_userPrefix}${_subKey}$subId', true);
  }

  // ৪. মডিউল আনলক কিনা চেক করা
  static Future<bool> isModuleUnlocked(String moduleId) async {
    if (moduleId == 'm1') return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_userPrefix}${_modKey}$moduleId') ?? false;
  }

  // ৫. নতুন মডিউল আনলক করা
  static Future<void> unlockModule(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_userPrefix}${_modKey}$moduleId', true);
  }

  // ৬. কুইজ পাস করলে মার্ক করা
  static Future<void> markQuizAsPassed(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_userPrefix}${_quizKey}$moduleId', true);
  }

  // ৭. নির্দিষ্ট কুইজ পাস হয়েছে কি না চেক
  static Future<bool> isQuizPassed(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_userPrefix}${_quizKey}$moduleId') ?? false;
  }

  // ৮. ড্যাশবোর্ডের জন্য কুইজ পাসের মোট সংখ্যা
  static Future<int> getPassedQuizCount() async {
    final prefs = await SharedPreferences.getInstance();
    int totalPassed = 0;
    for (int i = 1; i <= 32; i++) {
      bool isPassed = prefs.getBool('${_userPrefix}${_quizKey}m$i') ?? false;
      if (isPassed) totalPassed++;
    }
    return totalPassed;
  }

  // ৯. কুইজ দেওয়ার আগে সব পড়া হয়েছে কি না চেক (আপনার বর্তমান সমস্যা সমাধান করবে)
  static Future<bool> canTakeQuiz(String moduleId, List<dynamic> subModules) async {
    final prefs = await SharedPreferences.getInstance();
    // গুরুত্বপূর্ণ: আপনি markSubAsRead এ যে Key ব্যবহার করেছেন, এখানেও তাই হতে হবে
    for (var sub in subModules) {
      String subId = sub['id'].toString();
      bool isRead = prefs.getBool('${_userPrefix}${_subKey}$subId') ?? false;
      if (!isRead) return false;
    }
    return true;
  }

  // ১০. সর্বশেষ আনলক হওয়া মডিউল আইডি বের করা
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

  static Future<int> getPassedModulesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int passedCount = 0;

    // আপনার লজিক অনুযায়ী ৩২টি মডিউল লুপ চালিয়ে চেক করা হচ্ছে
    for (int i = 1; i <= 32; i++) {
      // এখানে আপনার প্রিফিক্স এবং কী (Key) ঠিক থাকলে এটি কাজ করবে
      // আমরা ধরে নিচ্ছি পাস করা মডিউলগুলো true হিসেবে সেভ আছে
      bool isUnlocked = prefs.getBool('${_userPrefix}${_modKey}m$i') ?? false;

      if (isUnlocked) {
        passedCount = i;
      } else {
        break; // যেখানে false পাবে সেখানেই লুপ থেমে যাবে
      }
    }
    return passedCount;
  }
}