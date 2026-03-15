import 'package:shared_preferences/shared_preferences.dart';

class UnlockService {
  // ✅ Firebase নির্ভরতা সরিয়ে সরাসরি লোকাল প্রিফিক্স সেট করা হয়েছে
  static String get userPrefix => "local_user_";

  static const String _subKey = "unlocked_sub_";
  static const String _modKey = "unlocked_mod_";
  static const String _quizKey = "quiz_passed_";

  // --- সাব-মডিউল লজিক ---
  static Future<bool> isSubUnlocked(String subId) async {
    // যেকোনো মডিউলের প্রথম সাব-মডিউল (যেমন m1s1, m2s1) সবসময় খোলা থাকবে
    if (subId.endsWith('s1')) return true;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${userPrefix}${_subKey}$subId') ?? false;
  }

  static Future<void> markSubAsRead(String subId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${userPrefix}${_subKey}$subId', true);
  }

  // --- মডিউল লজিক ---
  static Future<bool> isModuleUnlocked(String moduleId) async {
    // মডিউল ১ (m1) সবসময় খোলা থাকবে
    if (moduleId == 'm1') return true;

    final prefs = await SharedPreferences.getInstance();
    // অন্য মডিউলগুলো (m2, m3...) তখনই খুলবে যদি আগেরটার কুইজ পাস করা থাকে
    return prefs.getBool('${userPrefix}${_modKey}$moduleId') ?? false;
  }

  // কুইজ পাস করলে বর্তমান মডিউল পাস মার্ক হবে এবং পরের মডিউলটি পার্মানেন্টলি আনলক হবে
  static Future<void> markQuizAsPassed(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    // বর্তমান মডিউলটিকে 'পাস' হিসেবে মার্ক করা
    await prefs.setBool('${userPrefix}${_quizKey}$moduleId', true);

    // পরের মডিউলের আইডি জেনারেট করে সেটি আনলক করা
    try {
      int currentNum = int.parse(moduleId.replaceAll('m', ''));
      String nextModuleId = "m${currentNum + 1}";
      await prefs.setBool('${userPrefix}${_modKey}$nextModuleId', true);
    } catch (e) {
      print("Error generating next module ID: $e");
    }
  }

  static Future<int> getPassedModulesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int passedCount = 0;
    // আপনার ৩২টি মডিউলের ওপর ভিত্তি করে লুপ
    for (int i = 1; i <= 32; i++) {
      if (prefs.getBool('${userPrefix}${_quizKey}m$i') ?? false) passedCount++;
    }
    return passedCount;
  }

  static Future<bool> canTakeQuiz(String moduleId, List<dynamic> subModules) async {
    final prefs = await SharedPreferences.getInstance();
    // প্রথম সাব-মডিউল বাদে বাকিগুলো পড়া হয়েছে কি না চেক
    for (var sub in subModules) {
      String subId = sub['id'].toString();
      // প্রথম সাব-মডিউল তো সবসময়ই খোলা, তাই ওটা চেক করার দরকার নেই
      if (subId.endsWith('s1')) continue;

      bool isRead = prefs.getBool('${userPrefix}${_subKey}$subId') ?? false;
      if (!isRead) return false;
    }
    return true;
  }

  // মডিউল সরাসরি আনলক করার জন্য (যেমন ফ্ল্যাশকার্ড গেম শেষ করলে)
  static Future<void> unlockModule(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${userPrefix}${_modKey}$moduleId', true);
  }
}