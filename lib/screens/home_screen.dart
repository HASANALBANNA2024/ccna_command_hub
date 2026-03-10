import 'dart:convert';
import 'package:ccna_command_hub/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:ccna_command_hub/models/module_model.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget
{
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
  // json call
  Future<List<ModuleModel>> loadModules() async
  {
    final String response = await rootBundle.loadString('assets/data/modules.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => ModuleModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CCNA Modules"),
        centerTitle: true,
      ),

      // call to drawer
      drawer: const MainDrawer(),
      // body

      body: FutureBuilder<List<ModuleModel>>(
          future: loadModules(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting)
              {
                return const Center(child: CircularProgressIndicator());
              }
            else if(snapshot.hasError)
              {
                return const Center(child: Text("Error Loading"));
              }
            else
              {
                final modules = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                    itemCount: modules.length,
                    itemBuilder: (context, index)
                    {
                      final module = modules[index];
                      // card design
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          // ১. বাম পাশের আইকন (লক/আনলক)
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: module.isUnlocked ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              module.isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                              color: module.isUnlocked ? Colors.blue : Colors.grey,
                              size: 24,
                            ),
                          ),

                          // ২. মাঝখানের কন্টেন্ট (নম্বর + নাম + বর্ণনা)
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Module Number
                              Text(
                                "MODULE ${index + 1 < 10 ? '0' : ''}${index + 1}",
                                style: TextStyle(
                                  color: module.isUnlocked ? Colors.blueAccent : Colors.grey,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Module name
                              Text(
                                module.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          // module description
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              module.desc,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),

                          // arrow icon
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),

                          onTap: () {

                            debugPrint("Opening Module: ${module.name}");
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => SubModuleScreen(module: module)));
                          },
                        ),
                      );

                    }
                );
              }
          }
      ),




    );
  }
}