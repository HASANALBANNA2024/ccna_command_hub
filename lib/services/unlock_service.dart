import 'package:shared_preferences/shared_preferences.dart';

class UnlockService {
  // ১. ফিক্সড ইউজার আইডি (যেহেতু এখন অফলাইন, তাই Firebase এর দরকার নেই)
  static const String _userPrefix = "guest_user_";

  // কী (Keys)
  static const String _subKey = "unlocked_sub_";
  static const String _modKey = "unlocked_mod_";
  static const String _quizKey = "quiz_passed_";

  // ২. সাব-মডিউল আনলক কিনা চেক করা
  static Future<bool> isSubUnlocked(String subId) async {
    // প্রথম সাব-মডিউল সবসময় আনলক থাকবে (যেমন: m1_s1)
    if (subId.contains('_s1')) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_userPrefix}${_subKey}$subId') ?? false;
  }

  // ৩. সাব-মডিউল পড়া শেষ হলে মার্ক করা
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

  // ৬. কুইজ আনলক করার লজিক (সব সাব-মডিউল পড়া হয়েছে কি না)
  static Future<bool> canTakeQuiz(String moduleId, List<dynamic> subModules) async {
    final prefs = await SharedPreferences.getInstance();

    // লুপ চালিয়ে চেক করা হচ্ছে সব সাব-মডিউল পড়া হয়েছে কি না
    for (var sub in subModules) {
      String subId = sub['id'].toString();
      bool isRead = prefs.getBool('${_userPrefix}${_subKey}$subId') ?? false;

      // যদি কোনো একটি পড়া না হয়, তবে কুইজ লক থাকবে
      if (!isRead) return false;
    }
    return true; // সব পড়া শেষ হলে কুইজ আনলক
  }

  // ৭. কুইজ পাস করলে মার্ক করা
  static Future<void> markQuizAsPassed(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_userPrefix}${_quizKey}$moduleId', true);
  }

  // ৮. কুইজ পাস হয়েছে কি না চেক
  static Future<bool> isQuizPassed(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_userPrefix}${_quizKey}$moduleId') ?? false;
  }

  // ৯. পাস করা মডিউলের সংখ্যা (ড্যাশবোর্ড প্রগ্রেসের জন্য)
  static Future<int> getPassedModulesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int passedCount = 0;
    for (int i = 1; i <= 32; i++) {
      bool isUnlocked = prefs.getBool('${_userPrefix}${_modKey}m$i') ?? false;
      if (isUnlocked) {
        passedCount = i;
      } else {
        break;
      }
    }
    return passedCount;
  }
  static Future<String> getLastUnlockedModuleId() async {
    final prefs = await SharedPreferences.getInstance();
    int lastUnlocked = 1;
    for (int i = 1; i <= 32; i++) {
      bool isUnlocked = prefs.getBool('guest_user_unlocked_mod_m$i') ?? false;
      if (isUnlocked) lastUnlocked = i; else break;
    }
    return "m$lastUnlocked";
  }
}