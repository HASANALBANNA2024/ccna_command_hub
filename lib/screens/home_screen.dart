import 'dart:convert';
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
                      // card of modules name
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            module.isUnlocked ? Icons.lock_open_rounded : Icons.lock_clock_outlined,
                            color: module.isUnlocked ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            module.name,
                            style: const TextStyle(
                              fontWeight:  FontWeight.bold, fontSize: 16
                            ),
                          ),
                          subtitle: Text(module.desc),
                          trailing: const Icon(Icons.arrow_forward_ios,size: 14,),

                          onTap: (){
                            // locked unlocked all side sub module open but after sub module not access content

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