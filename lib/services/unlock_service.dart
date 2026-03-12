import 'package:shared_preferences/shared_preferences.dart';

class UnlockService {
  static const String _subKey = "unlocked_sub_";
  static const String _modKey = "unlocked_mod_";

  // সাব-মডিউল আনলক কিনা চেক করা
  static Future<bool> isSubUnlocked(String subId) async {
    // প্রতি মডিউলের প্রথম সাব-মডিউল (যেমন m1_s1) সবসময় খোলা
    if (subId.endsWith('_s1')) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_subKey$subId') ?? false;
  }

  // সাব-মডিউল আনলক করা (পড়া শেষ হলে)
  static Future<void> markSubAsRead(String subId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_subKey$subId', true);
  }

  // মডিউল আনলক কিনা চেক করা
  static Future<bool> isModuleUnlocked(String moduleId) async {
    if (moduleId == 'm1') return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_modKey$moduleId') ?? false;
  }

  // মডিউল আনলক করা (পাস করলে বা অ্যাড দেখলে)
  static Future<void> unlockModule(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_modKey$moduleId', true);
  }

  // সব সাব-মডিউল পড়া হয়েছে কি না চেক (কুইজের আগে দরকার)
  static Future<bool> canTakeQuiz(List<dynamic> subModules) async {
    for (var sub in subModules) {
      if (!await isSubUnlocked(sub['id'])) return false;
    }
    return true;
  }

  // getpassed module and update progress bar for dashboard screen
  static Future<int> getPassedQuizCount() async {
    final prefs = await SharedPreferences.getInstance();
    int totalPassed = 0;

    for (int i = 1; i <= 32; i++) {
      // নিশ্চিত করুন যে সেভ করার সময় 'quiz_passed_m1' এই ফরম্যাটেই সেভ হচ্ছে
      bool isPassed = prefs.getBool('quiz_passed_m$i') ?? false;
      if (isPassed) {
        totalPassed++;
      }
    }
    return totalPassed;
  }

  // last unlocked module

  static Future<String> getLastUnlockedModuleId() async {
    final prefs = await SharedPreferences.getInstance();
    int lastUnlocked = 1;

    for (int i = 1; i <= 32; i++) {
      // আপনার সেভ করা কি (Key) অনুযায়ী চেক করছি
      bool isUnlocked = prefs.getBool('unlocked_mod_m$i') ?? false;

      if (isUnlocked) {
        lastUnlocked = i;
      } else {
        // যদি m1 এবং m2 আনলক থাকে, তবে লুপটি ২ এ এসে থামবে
        break;
      }
    }

    // যেহেতু m1 আনলক মানে ইউজার m1 এর কুইজ দিতে পারে,
    // তাই আমরা সরাসরি m$lastUnlocked রিটার্ন করবো।
    return "m$lastUnlocked";
  }
}