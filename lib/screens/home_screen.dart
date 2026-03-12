import 'dart:convert';
import 'package:ccna_command_hub/widgets/main_drawer.dart';
import 'package:ccna_command_hub/widgets/search_Delegate.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/models/module_model.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
import 'package:ccna_command_hub/widgets/search_Delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // module list for save appbar Icon search
  List<ModuleModel> allModules = [];

  Future<List<ModuleModel>> loadModules() async {
    final String response = await rootBundle.loadString('assets/data/modules.json');
    final List<dynamic> data = json.decode(response);
    // return data.map((json) => ModuleModel.fromJson(json)).toList();
// ডাটা লোড করে লিস্টে রূপান্তর করা
    List<ModuleModel> modules = data.map((json) => ModuleModel.fromJson(json)).toList();

    // ২. ডাটাগুলো allModules ভেরিয়েবলে রেখে দেওয়া হচ্ছে
    allModules = modules;

    return modules;

  }

  @override
  Widget build(BuildContext context) {
    // ডার্ক মোড চেক করার জন্য লজিক
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ডার্ক মোডে মিডনাইট ব্লু এবং লাইট মোডে হালকা গ্রে ব্যাকগ্রাউন্ড
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text("CCNA Modules", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        // অ্যাপবারে হালকা গ্রাডিয়েন্ট ইফেক্ট (ঐচ্ছিক, আপনার থিমের সাথে মিলবে)
        backgroundColor: isDark ? Colors.transparent : Colors.blueAccent,

        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: GlobalSearchDelegate(allModules));
          }, icon: Icon(Icons.search))
        ],
      ),

      drawer: const MainDrawer(),

      body: FutureBuilder<List<ModuleModel>>(
        future: loadModules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error Loading"));
          } else {
            final modules = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                bool isDark = Theme.of(context).brightness == Brightness.dark;

                return FutureBuilder<bool>(
                  // UnlockService থেকে রিয়েল-টাইম স্ট্যাটাস চেক করা হচ্ছে
                  future: UnlockService.isModuleUnlocked(module.id),
                  builder: (context, snapshot) {
                    // ডাটা না আসা পর্যন্ত ডিফল্ট বা JSON এর ডাটা দেখাবে
                    bool isUnlocked = snapshot.data ?? (module.id == "m1");

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                        // ১. বাম পাশের আইকন ডিজাইন (রিয়েল-টাইম আনলক চেক)
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                            color: isUnlocked ? Colors.blueAccent : Colors.grey,
                            size: 24,
                          ),
                        ),

                        // ২. মাঝখানের কন্টেন্ট (UI একই আছে)
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MODULE ${index + 1 < 10 ? '0' : ''}${index + 1}",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              module.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            module.desc,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),

                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: isDark ? Colors.blueGrey : Colors.grey,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubModuleScreen(
                                moduleId: module.id,
                                moduleName: module.name,
                                subModules: module.subModules,
                              ),
                            ),
                          ).then((_) {
                            // কুইজ স্ক্রিন বা সাব-মডিউল থেকে ব্যাক করলে যাতে আইকন আপডেট হয়
                            setState(() {});
                          });
                        },
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}